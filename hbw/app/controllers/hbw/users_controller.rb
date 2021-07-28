module HBW
  class UsersController < BaseController
    def index
      @users = widget.users
    end

    def lookup
      @users = widget.users_lookup(query)

      render :index
    end

    def check_user
      render json: {user_exists: widget.user_exists?(current_user_identifier)}
    end

    private

    def query
      params.require(:q)
    end
  end
end
