require 'minio'

module HBW
  class TasksController < BaseController
    include Minio
    extend Minio::Mixin

    inject['minio_adapter']

    def index
      @tasks = widget.task_list(current_user_identifier, entity_class)
    end

    def show
      @task = widget.get_task_with_form(task_id, entity_class, cache_key)
    end

    def destroy
      result = widget.cancel_process(params[:id])

      if result
        head :no_content
      else
        head :bad_request
      end
    end

    def submit
      data = form_data.select { |key| fields_for_save.include?(key) }

      if files.present?
        file_list = JSON.parse(data['homsOrderDataFileList'])

        saved_files = minio_adapter.save_file(files)

        file_list += saved_files

        data['homsOrderDataFileList'] = file_list.to_json
      end

      result = widget.submit(entity_class, task_id, data)

      if result
        head :no_content
      else
        head :bad_request
      end
    end

    def lookup
      form = widget.form(task_id, entity_class)
      field = form.field(params[:name])
      variants = field.lookup_values(params[:q])

      render json: variants.map { |id, text| {id: id, text: text} }.to_json
    end

    def claim
      widget.claim_task(current_user_identifier, task_id)
      head :no_content
    end

    def forms
      @forms = widget.get_forms_for_task_list(entity_tasks)
    end

    private

    def task_id
      params.require(:id)
    end

    def form_data
      params[:form_data].to_h
    end

    def max_results
      params[:max_results]
    end

    def assigned
      params[:assigned] == 'true'
    end

    def search_query
      params[:search_query]
    end

    def cache_key
      params[:cache_key]
    end

    def entity_tasks
      params[:entity_tasks]
    end

    def files
      form_data.map { |key, value| JSON.parse(value) rescue nil }
          .compact
          .map { |value| value['files'] if value.respond_to?(:key) }
          .compact.flatten
    end

    def fields_for_save
      fields = form_data.map do |key, value|
        JSON.parse(value)['files'] ? nil : key rescue key
      end

      fields.compact
    end
  end
end
