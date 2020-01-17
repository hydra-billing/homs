module HBW
  class ButtonsController < BaseController
    def index
      render json: buttons.to_json
    end

    def create
      widget.start_bp(current_user_identifier,
                      bp_code,
                      entity_identifier,
                      entity_class,
                      initial_variables)

      render json: buttons.to_json
    end

    private

    def buttons
      widget.bp_buttons(entity_identifier, entity_type, entity_class, current_user_identifier)
    end

    def bp_code
      params.require(:bp_code)
    end
  end
end
