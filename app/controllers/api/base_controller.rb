module API
  class BaseController < ApplicationController
    # protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    before_action :resource_set, only: [:destroy, :show, :update, :edit]
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound,       with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid,        with: :record_invalid
    rescue_from ActionController::ParameterMissing, with: :bad_request

    def create
      resource_set(resource_class.new(resource_params))

      if resource_get.save
        render :show, status: :created
      else
        render json: resource_get.errors, status: :unprocessable_entity
      end
    end

    def destroy
      resource_get.destroy
      head :no_content
    end

    def index(resource_scope = resource_class.all)
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = resource_scope.where(query_params)
                                .page(page_params[:page])
                                .per(page_params[:page_size])

      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    def show
      respond_with resource_get
    end

    def update
      if resource_get.update(resource_params)
        render :show
      else
        render json: resource_get.errors, status: :unprocessable_entity
      end
    end

    def lookup
      if resource_class.respond_to? :lookup
        respond_with resource_class.lookup(params[:q]).to_json
      else
        respond_with([{id: 0, text: 'not implemented'}].to_json)
      end
    end

    protected

    def record_not_found
      head :not_found
    end

    def record_invalid
      head :unprocessable_entity
    end

    def bad_request
      head :bad_request
    end

    def page_params
      params.permit(:page, :page_size)
    end

    private

    def csrf_token
      session['_csrf_token'] ||= form_authenticity_token
    end

    def resource_get
      instance_variable_get("@#{resource_name}")
    end

    def query_params
      {}
    end

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    def resource_name
      @resource_name ||= controller_name.singularize
    end

    def resource_params
      @resource_params ||= send("#{resource_name}_params")
    end

    def resource_set(resource = nil)
      resource ||= resource_class.find(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end
  end
end
