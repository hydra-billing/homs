require_relative '../../../lib/config'

class TestConfig < Config
  def self.base_path
    Rails.root.join('config', 'test.default.yml')
  end

  def self.custom_path
    Rails.root.join('config', 'test.yml')
  end
end

RSpec.describe TestConfig do
  before do
    allow(Rails.root).to receive(:join).with('config', 'test.default.yml').and_return('fixtures/config/test.default.yml')
    allow(Rails.root).to receive(:join).with('config', 'test.yml').and_return('fixtures/config/test.yml')
    allow(File).to receive(:exist?).with('fixtures/config/test.yml').and_return(true)
  end

  describe '.config' do
    it 'loads configuration from base and custom files' do
      expect(TestConfig.config['pool']).to eq(10)
      expect(TestConfig.config['test_var']).to eq('foo')
    end
  end
end
