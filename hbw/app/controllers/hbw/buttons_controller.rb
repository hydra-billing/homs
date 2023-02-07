module HBW
  class ButtonsController < ApiController
    def index
      if autorun_process_key.nil?
        render json: buttons.to_json
      else
        widget.try_to_start_bp(current_user_identifier,
                               autorun_process_key,
                               entity_identifier,
                               entity_class,
                               initial_variables)

        render json: {buttons: [], bp_running: true}.to_json
      end
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
      user_identifier = if sso_enabled?
                          token_user_identifier || current_user_identifier
                        else
                          current_user_identifier
                        end
      widget.bp_buttons(entity_identifier, entity_type, entity_class, user_identifier)
    end

    def bp_code
      params.require(:bp_code)
    end
  end
end
