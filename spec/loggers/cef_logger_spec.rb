require 'cef_logger'

RSpec.describe CEFLogger do
  subject(:logger) { described_class.new(enabled: true) }

  before(:each) do
    allow(Time).to receive(:now).and_return(Time.parse('2021-10-14'))

    stub_const('HOMS::Application::VERSION', '1.2.3')
  end

  describe '#log_event' do
    context 'app event' do
      specify do
        expect { logger.log_event(:start) }.to output(
          "2021-10-14T00:00:00+00:00 CEF:0|Hydra Billing|HOMS|1.2.3|start|Application start|9|src= dst= shost= suid= suser= msg=Application has been started end=1634169600|\n"
        ).to_stdout
      end
    end

    context 'user event' do
      let(:user) do
        {
          id:    123456,
          email: 'user@example.com'
        }
      end

      let(:headers) do
        {
          'Source-Address'      => '11.11.11.111',
          'Destination-Address' => 'some.domain.test.local',
          'Source-Host-Name'    => 'some.domain.test.local'
        }
      end

      specify do
        expect { logger.log_user_event(:login, user, headers) }.to output(
          "2021-10-14T00:00:00+00:00 CEF:0|Hydra Billing|HOMS|1.2.3|login|System login|6|src=11.11.11.111 dst=some.domain.test.local shost=some.domain.test.local suid=123456 suser=user@example.com msg=Successful login end=1634169600|\n"
        ).to_stdout
      end
    end
  end
end
