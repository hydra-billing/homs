class User < ActiveRecord::Base
  class << self
    def id_from_email(email)
      select(:id).find_by(email: email).try(:id)
    end

    def lookup(q, limit = 10)
      s = q.mb_chars.downcase.to_s

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
end
