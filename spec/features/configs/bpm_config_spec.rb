RSpec.describe BPM::ConfigValidator do
  subject { described_class }

  def validate(path)
    subject.(config: YAML.load_file(fixtures_path(path))[Rails.env])
  end

  describe '#call' do
    it 'loads valid config' do
      expect(validate('config/bpm.yml')).to eq(
        [{login:        'kermit',
          name:         'camunda_1',
          password:     'kermit',
          process_keys: %w[pizza_order new_customer],
          url:          'http://localhost:8766/engine-rest/'},
         {login:        'kermit',
          name:         'camunda_2',
          password:     'kermit',
          process_keys: ['relocate_customer'],
          url:          'http://localhost:8767/engine-rest/'}]
      )
    end

    it 'raises errors if config is invalid' do
      expect { validate('config/bpm_failed_validation.yml') }.to raise_error(
        RuntimeError,
        'Application misconfigured: {:config=>["Names must be unique", "URLs must be unique", "Process keys must be unique"]}'
      )
    end
  end
end
