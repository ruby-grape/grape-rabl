require 'spec_helper'

describe 'Grape::Rabl configuration' do
  context 'configuration' do
    it 'returns default values' do
      Grape::Rabl.configuration.cache_template_loading.should == false
    end

    it 'should set and reset configuration' do
      Grape::Rabl.configure do |config|
        config.cache_template_loading = true
      end
      Grape::Rabl.configuration.cache_template_loading.should be == true
      Grape::Rabl.reset_configuration!
      Grape::Rabl.configuration.cache_template_loading.should == false
    end
  end
end
