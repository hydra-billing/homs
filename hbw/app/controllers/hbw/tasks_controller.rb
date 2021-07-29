require 'minio'

module HBW
  class TasksController < ApiController
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
      file_fields.each do |file_field|
        file_list_name = file_field['fileListName']
        file_list = JSON.parse(data[file_list_name])

        saved_files = minio_adapter.save_files(file_field['files'])

        file_list += saved_files

        data[file_list_name] = file_list.to_json
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

    def file_fields
      form_data.map { |_key, value| parse_json_silent(value) }.compact
               .map { |el| el.slice('files', 'fileListName') if el.respond_to?(:key) }
               .select { |el| el.present? && el['files'].present? }
    end

    def parse_json_silent(json)
      JSON.parse(json)
    rescue StandardError
      nil
    end

    def fields_for_save
      fields = form_data.map do |key, value|
        JSON.parse(value)['files'] ? nil : key
      rescue StandardError
        key
      end

      fields.compact
    end
  end
end
