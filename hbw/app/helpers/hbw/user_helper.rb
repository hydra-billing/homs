module HBW
  module UserHelper
    def with_user(email)
      user = ::HBW::BPMUser.fetch(email)

      unless user.nil?
        yield(user)
      end
    end
  end
end
