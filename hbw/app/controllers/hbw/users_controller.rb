module HBW
  class UsersController < BaseController
    def index
      @users = widget.users
    end

    def lookup
      @users = widget.users_lookup(query)

      render :index
    end

    private

    def query
      params.require(:q)
    end
  end
end
