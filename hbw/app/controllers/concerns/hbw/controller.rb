module HBW
  module Controller
    extend ActiveSupport::Concern

    included { helper_method(:widget) }

    def widget
      @widget ||= HBW::Widget.new
    end

    def user_identifier
      params[:user_identifier]
    end

    def entity_identifier
      params[:entity_code]
    end

    def entity_type
      params[:entity_type]
    end

    def entity_class
      params[:entity_class].to_sym
    end

    def initial_variables
      params[:initial_variables].to_h
    end

    def autorun_process_key
      params[:autorun_process_key]
    end

    def process_key
      params.require(:process_key)
    end
  end
end
