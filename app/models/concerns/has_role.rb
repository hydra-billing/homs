module HasRole
  extend ActiveSupport::Concern

  included do
    enum role: [:user, :vip, :admin]

    after_initialize :set_default_role, if: :new_record?
  end

  def set_default_role
    self.role ||= :user
  end

  def role_i18n_key
    self.class.role_i18n_key(self.role)
  end

  module ClassMethods
    def role_i18n_key(role)
      "user_role.#{role}"
    end

    def roles_list
      roles.keys
    end

    def roles_list_str(separator = ', ')
      roles_list.map { |r| %("#{r}") }.join separator
    end
  end
end
