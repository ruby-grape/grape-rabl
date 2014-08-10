require 'spec_helper'

describe 'Grape::Rabl layout' do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::Rabl
    subject.before do
      env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views/layout_test"
    end
  end

  def app
    subject
  end

  context 'default' do
    it 'proper render with default layout' do
      subject.get('/about', rabl: 'user') do
        @user = OpenStruct.new(name: 'LTe')
        @project = OpenStruct.new(name: 'First')
        @status = 200
      end

      get('/about')
      last_response.body.should ==
        %Q({"status":200,"result":{"user":{"name":"LTe","project":{"name":"First"}}}})
    end
  end

  context 'tilt layout is setup' do
    before do
      subject.before { env['api.tilt.layout'] = 'layouts/another' }
    end

    it 'proper render with specified layout' do
      subject.get('/about', rabl: 'user') do
        @user = OpenStruct.new(name: 'LTe')
        @project = OpenStruct.new(name: 'First')
        @status = 200
      end

      get('/about')
      puts last_response.body
      last_response.body.should ==
        %Q({"result":{"user":{"name":"LTe","project":{"name":"First"}}}})
    end
  end
  
  context 'layout cache' do
    before do
      @layout = "#{File.dirname(__FILE__)}/views/layout_test/layouts/application_cached.rabl"
      FileUtils.cp("#{File.dirname(__FILE__)}/views/layout_test/layouts/application.rabl", @layout)
      subject.before { env['api.tilt.layout'] = 'layouts/application_cached' }
      subject.get('/home', rabl: 'user') do
        @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
        @project = OpenStruct.new(name: 'First')
        @status = 200
      end
    end
    
    after do
      Grape::Rabl.reset_configuration!
      FileUtils.rm(@layout)
    end

    it 'should serve from cache if cache_template_loading' do
      Grape::Rabl.configure do |config|
        config.cache_template_loading = true
      end
      get '/home'
      old_response = last_response.body
      open(@layout, 'a') { |f| f << 'node(:test) { "test" }' }
      get '/home'
      new_response = last_response.body
      old_response.should == new_response
    end

    it 'should serve new template if cache_template_loading' do
      get '/home'
      old_response = last_response.body
      open(@layout, 'a') { |f| f << 'node(:test) { "test" }' }
      get '/home'
      new_response = last_response.body
      old_response.should_not == new_response
    end
  end
end
