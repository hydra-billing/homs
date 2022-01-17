class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :keycloakopenid

  def keycloakopenid
    Rails.logger.debug(request.env["omniauth.auth"])
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.keycloakopenid_data"] = request.env["omniauth.auth"].select { |k, v| k == "info" }
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
