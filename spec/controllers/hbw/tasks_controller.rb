describe HBW::TasksController, type: :controller do
  describe 'Get' do
    before(:all) do
      container = Dry::Container.new
      container.register(:activiti_api, -> { TestingActivitiAPI.build })
      container.register(:adapter_class, -> { HBW::Activiti::Adapter })

      HBW.container = container

      HBW.inject = Dry::Injection.new(container, {type: :hash})
    end

    it 'tasks list' do
    end
  end
end
