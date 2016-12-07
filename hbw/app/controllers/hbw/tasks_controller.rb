module HBW
  class TasksController < BaseController
    def index
      if entity_identifier.present?
        @tasks = widget.entity_task_list(current_user_identifier, entity_identifier, entity_class)
      else
        @tasks = widget.task_list(current_user_identifier, entity_class)
      end
    end

    def edit
      form = find_form(task_id, entity_class)
      if form
        form.fetch_fields
        render json: form.as_json.merge(csrf_token: csrf_token).to_json
      else
        record_not_found
      end
    end

    def submit
      result = widget.submit(current_user.email, entity_class, task_id, form_data)
      if result
        head :no_content
      else
        render nothing: true, status: :bad_request
      end
    end

    def lookup
      form = find_form(task_id, entity_class)
      field = form.field(params[:name])
      variants = field.lookup_values(params[:q])

      render json: variants.to_json
    end

    private

    def find_form(task_id, entity_class)
      widget.form(current_user_identifier, entity_class, task_id)
    end

    def task_id
      params.require(:id)
    end

    def form_data
      params.permit(:form_data)
    end
  end
end
