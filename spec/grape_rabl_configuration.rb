require 'spec_helper'

describe 'Grape::Rabl configuration' do
  context 'configuration' do
    it 'returns default values' do
      expect(Grape::Rabl.configuration.cache_template_loading).to eq(false)
    end

    it 'should set and reset configuration' do
      Grape::Rabl.configure do |config|
        config.cache_template_loading = true
      end
      expect(Grape::Rabl.configuration.cache_template_loading).to eq(true)
      Grape::Rabl.reset_configuration!
      expect(Grape::Rabl.configuration.cache_template_loading).to eq(false)
    end
  end
end
