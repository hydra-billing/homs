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

    def from_keycloak(user_data)
      where(email: user_data[:email]).first_or_create do |user|
        user.email = user_data[:email]
        user.name = user_data[:name]
        user.last_name = user_data[:last_name]
        user.company = user_data[:company]
        user.department = user_data[:department]
        user.password = Devise.friendly_token
      end
    end
  end

  include HasRole
  include HasApiToken

  default_scope { order(last_name: :asc, name: :asc, middle_name: :asc) }

  def full_name
    [name, last_name].join ' '
  end

  devise :database_authenticatable, :rememberable, :trackable, :validatable, :encryptable

  validates :name,        presence: true
  validates :last_name,   presence: true
  validates :company,     presence: true
  validates :department,  presence: true

  has_many :profiles, dependent: :destroy
  has_many :orders,   dependent: :restrict_with_exception
end
