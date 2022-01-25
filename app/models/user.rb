class User < ActiveRecord::Base
  class << self
    def id_from_email(email)
      select(:id).find_by(email: email).try(:id)
    end

    def lookup(query, limit = 10)
      s = query.mb_chars.downcase.to_s

      where(<<-SQL, *(["%#{s}%"] * 3))
        lower(name) like ?
          OR lower(last_name) like ?
          OR lower(middle_name) like ?
      SQL
        .select('id, name, middle_name, last_name')
        .order_by_name
        .limit(limit)
        .map { |u| {id: u.id, text: u.full_name} }
    end

    def order_by_name
      order(:name, :id)
    end

    def empty
      @empty ||= Empty.new
    end

    def from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.extra.raw_info.email
        user.name = auth.extra.raw_info.name
        user.last_name = auth.extra.raw_info.last_name
        user.company = auth.extra.raw_info.company
        user.department = auth.extra.raw_info.department
        user.password = Devise.friendly_token[0, 20]
        user.provider = auth.provider
        user.uid = auth.uid
      end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.keycloakopenid_data"]
          user.email = data["raw_info"]["email"] if user.email.blank?
          user.name = data["raw_info"]["name"] if user.name.blank?
          user.last_name = data["raw_info"]["last_name"] if user.last_name.blank?
          user.company = data["raw_info"]["company"] if user.company.blank?
          user.department = data["raw_info"]["department"] if user.department.blank?
        end
      end
    end
  end

  include HasRole
  include HasApiToken

  default_scope { order(last_name: :asc, name: :asc, middle_name: :asc) }

  def full_name
    [name, last_name].join ' '
  end

  devise :database_authenticatable, :rememberable, :trackable, :validatable, :encryptable,
         :registerable, :omniauthable, omniauth_providers: %i[keycloakopenid]

  validates :name,        presence: true
  validates :last_name,   presence: true
  validates :company,     presence: true
  validates :department,  presence: true

  has_many :profiles, dependent: :destroy
  has_many :orders,   dependent: :restrict_with_exception
end
