describe 'Events::Tasks', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:order_type) { FactoryBot.create(:order_type, :support_request) }
  let(:user)       { FactoryBot.create(:user) }
  let(:widget)     { instance_double(HBW::Widget) }

  before(:each) do
    # patch for predictable cache_key
    allow(Time).to receive(:now).and_return(Time.new(2023))
    allow(SecureRandom).to receive(:hex).and_return('a1')
  end

  describe 'Events' do
    describe 'Tasks' do
      it 'assignment event success' do
        expect(widget).to receive(:get_task_by_id).with('12345').and_return(
          {id:                  '12345',
           name:                'Tasks events test form',
           assignee:            nil,
           created:             '2016-06-30T12:07:59.000+03:00',
           due:                 nil,
           followUp:            nil,
           delegationState:     nil,
           description:         nil,
           executionId:         '11122',
           owner:               nil,
           parentTaskId:        nil,
           priority:            50,
           processDefinitionId: 'testProcess:123:11122',
           processInstanceId:   11122,
           taskDefinitionKey:   'usertask10',
           caseExecutionId:     nil,
           caseInstanceId:      nil,
           caseDefinitionId:    nil,
           suspended:           false,
           formKey:             'test_form.yml',
           tenantId:            nil}
        )

        expect(widget).to receive(:get_form_by_task_id).with('12345').and_return(
          'form: \
            name: Tasks events test form \
            css_class: col-xs-12 col-sm-6 col-md-5 col-lg-4 \
            fields: \
              - name: group1 \
                type: group \
                label: Choose option \
                css_class: col-xs-12 \
                fields: \
                  - name: homsOrderDataStatic \
                    type: static \
                    label: TEST \
                    css_class: col-xs-12 col-sm-6 col-md-4 \
                    html: "<h4> $wrongBPVariable TEST STATIC $wrongBPVariable </h4>"'
        )

        allow_any_instance_of(HBW::Events::TasksController).to receive(:widget).and_return(widget)

        expect(ActionCable).to receive_message_chain('server.broadcast').with('task_channel_user@example.com',
                                                                              {task_id:        '12345',
                                                                               event_name:     'assignment',
                                                                               version:        '1',
                                                                               cache_key:      '12345_1672531200000_a1',
                                                                               assigned_to_me: true}.to_json)

        sign_in user

        event_params = {id:         '12345',
                        event_name: 'assignment',
                        assignee:   'user@example.com',
                        version:    '1',
                        users:      ['user@example.com']}

        put "/widget/events/tasks/#{event_params[:id]}", params: event_params

        expect(response).to have_http_status(:success)
      end

      it 'complete event success' do
        expect(widget).not_to receive(:get_task_by_id)
        expect(widget).not_to receive(:get_form_by_task_id)

        allow_any_instance_of(HBW::Events::TasksController).to receive(:widget).and_return(widget)

        expect(ActionCable).to receive_message_chain('server.broadcast').with('task_channel_user@example.com',
                                                                              {task_id:        '12345',
                                                                               event_name:     'complete',
                                                                               version:        '1',
                                                                               assigned_to_me: true}.to_json)

        sign_in user

        event_params = {id:         '12345',
                        event_name: 'complete',
                        assignee:   'user@example.com',
                        version:    '1',
                        users:      ['user@example.com']}

        put "/widget/events/tasks/#{event_params[:id]}", params: event_params

        expect(response).to have_http_status(:success)
      end
    end
  end
end
