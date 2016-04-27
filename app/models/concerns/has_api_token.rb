module HasApiToken
  extend ActiveSupport::Concern

  def api_token?
    !!api_token
  end

  def generate_api_token
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(api_token: random_token)
    end

    update_column :api_token, api_token
  end

  def clear_api_token
    update_column :api_token, nil
  end
end
