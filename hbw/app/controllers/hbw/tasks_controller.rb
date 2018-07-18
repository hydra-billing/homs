require 'minio'

module HBW
  class TasksController < BaseController
    include Minio
    extend Minio::Mixin

    inject['minio_adapter']

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
      data = form_data.select{ |key, value| fields_for_save.include?(key) }

      if files.present?
        file_list = JSON.parse(data['homsOrderDataFileList'])

        saved_files = minio_adapter.save_file(files)

        file_list = file_list + saved_files

        data['homsOrderDataFileList'] = file_list.to_json
      end

      result = widget.submit(current_user.email, entity_class, task_id, data)

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

      render json: variants.map { |id, text| {id: id, text: text} }.to_json
    end

    private

    def find_form(task_id, entity_class)
      widget.form(current_user_identifier, entity_class, task_id)
    end

    def task_id
      params.require(:id)
    end

    def form_data
      params[:form_data].to_h
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
