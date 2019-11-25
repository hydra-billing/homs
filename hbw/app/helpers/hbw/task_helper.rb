module HBW
  module TaskHelper
    def entity_url(task, entity_class)
      entity_url_params = []

      HBW::Widget.config[:entities].fetch(entity_class)[:task_list][:entity_url_params].each do |param|
        entity_url_params.append(task.send(param))
      end

      HBW::Widget.config[:entities].fetch(entity_class)[:task_list][:entity_url] % entity_url_params
    end

    def entity_code_key(entity_class)
      HBW::Widget.config[:entities].fetch(entity_class)[:entity_code_key]
    end

    def bp_name_key(entity_class)
      HBW::Widget.config[:entities].fetch(entity_class)[:bp_name_key]
    end
  end
end
