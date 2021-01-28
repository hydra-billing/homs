class ProfilesController < ApplicationController
  include ::ValidationsArbitraryKeys

  before_action :set_profile, only: :create

  schema do
    required(:label).filled(:str?)
    required(:type).filled(:str?)
    required(:show).filled(:bool?)
  end

  def create
    result = validate_arbitrary_keys(params[:data].to_unsafe_hash)

    if result[0] == :success
      @profile.data = result[1]
      @profile.save

      render json: @profile
    else
      flash[:error] = collect_error_messages(result[1])

      redirect_to request.referer
    end
  end

  def update
    result = validate_arbitrary_keys(params[:data].to_unsafe_hash)

    if result[0] == :success
      profile = Profile.find(params[:id])
      profile.data = result[1]
      profile.save

      render json: profile
    else
      flash[:error] = collect_error_messages(result[1])

      redirect_to request.referer
    end
  end

  private

  def set_profile
    @profile ||= Profile.new(user_id:       params[:user_id] || current_user.id,
                             order_type_id: params[:order_type_id])
  end

  def collect_error_messages(messages)
    messages.map do |field, inner_errors|
      '%s: %s.' % [field, inner_errors.map { |k, v| '%s %s' % [k, v] }.join(', ')]
    end.join("\n")
  end
end
