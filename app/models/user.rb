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
      user = where(email: user_data[:email]).first_or_create do |new_user|
        new_user.email = user_data[:email]
        new_user.name = user_data[:name]
        new_user.last_name = user_data[:last_name] || '-'
        new_user.company = user_data[:company] || '-'
        new_user.department = user_data[:department] || '-'
        new_user.password = Devise.friendly_token
        new_user.role = user_data[:role]
      end

      user.update_attribute(:role, user_data[:role])
      user
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
