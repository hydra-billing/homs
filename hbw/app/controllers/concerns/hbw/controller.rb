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

    def csrf_token
      session['_csrf_token'] ||= form_authenticity_token
    end
  end
end
