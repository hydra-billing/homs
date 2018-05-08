class UsersController < ApplicationController
  self.hbw_available = true

  PARAMS_ATTRIBUTES = [:name, :last_name, :middle_name, :company, :department,
                       :email, :role, :password, :password_confirmation]

  before_action :authenticate_user!
  before_action :admin_only, except: [:show, :lookup]
  before_action :find_user, except: [:new, :add, :index, :lookup]

  def index
    @users = User.all
  end

  def show
    redirect_to :back, alert: t('access_denied') unless
      @user == current_user || current_user.admin?
  end

  def update
    attributes = secure_params
    if attributes[:password].blank?
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end
    if @user.update_attributes(attributes)
      redirect_to users_path, notice: t('user_updated')
    else
      render action: :edit
    end
  end

  def destroy
    user.destroy
    redirect_to users_path, notice: t('user_deleted')
  end

  def edit
  end

  def new
    @user = User.new
  end

  def add
    @user = User.new(secure_params)

    if @user.save
      flash[:success] = t('.added')
      redirect_to users_path
    else
      render action: :new
    end
  end

  def generate_api_token
    @user.generate_api_token
    render action: 'show'
  end

  def clear_api_token
    @user.clear_api_token
    render action: 'show'
  end

  def lookup
    render json: User.lookup(params.require(:q)).to_json
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def secure_params
    params.require(:user).permit(*PARAMS_ATTRIBUTES)
  end
end
