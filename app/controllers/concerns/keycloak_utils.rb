module KeycloakUtils
  extend ActiveSupport::Concern

  Dry::Schema.load_extensions(:monads)

  UserDataSchema = Dry::Schema.JSON do
    required(:email).filled(:string)
    required(:name).filled(:string)
    optional(:last_name).filled(:string)
    optional(:company).filled(:string)
    optional(:department).filled(:string)
    required(:role).filled(:string)
  end

  def validate_user_data(user_data)
    UserDataSchema.call(
      email:      user_data[:email],
      name:       user_data[:name],
      last_name:  user_data[:last_name],
      company:    user_data[:company],
      department: user_data[:department],
      role:       user_data[:role]
    )
                  .to_monad
  end
end
