class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_type

  class << self
    def by_order_type_and_user(order_type_id, user_id)
      find_by(order_type_id:, user_id:)
    end
  end
end
