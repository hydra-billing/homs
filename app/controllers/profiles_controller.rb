class ProfilesController < ApplicationController
  before_action :set_profile, only: :create

  def create
    @profile.data = params[:data]
    @profile.save

    render json: @profile
  end

  def update
    profile = Profile.find(params[:id])
    profile.data = params[:data]
    profile.save

    render json: profile
  end

  def set_profile
    @profile ||= Profile.new(user_id: params[:user_id] || current_user.id,
                             order_type_id: params[:order_type_id])
  end
end
