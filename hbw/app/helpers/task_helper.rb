module TaskHelper
  def entity_url(task, entity_class)
    entity_url_params = []

    widget.config.fetch(entity_class)[:task_list][:entity_url_params].each do |param|
      entity_url_params.append(task.send(param))
    end

    widget.config.fetch(entity_class)[:task_list][:entity_url] % entity_url_params
  end
end
