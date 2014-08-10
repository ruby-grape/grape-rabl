require 'spec_helper'

describe Grape::Rabl do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::Rabl
    subject.helpers MyHelper
  end

  def app
    subject
  end

  it 'should work without rabl template' do
    subject.get('/home') { 'Hello World' }
    get '/home'
    last_response.body.should == "\"Hello World\""
  end

  it 'should raise error about root directory' do
    begin
      subject.get('/home', rabl: true) {}
      get '/home'
    rescue Exception => e
      e.message.should include "Use Rack::Config to set 'api.tilt.root' in config.ru"
    end
  end

  context 'titl root is setup'  do
    before do
      subject.before { env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views" }
    end

    describe 'helpers' do
      it 'should execute helper' do
        subject.get('/home', rabl: 'helper') { @user = OpenStruct.new }
        get '/home'
        last_response.body.should == "{\"user\":{\"helper\":\"my_helper\"}}"
      end
    end

    describe '#render' do
      before do
        subject.get('/home', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')
          render rabl: 'admin'
        end

        subject.get('/home-detail', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')
          render rabl: 'admin', locals: { details: 'amazing detail' }
        end

        subject.get('/about', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')
        end

        subject.get('/about-detail', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')
          render locals: { details: 'just a user' }
        end
      end

      it 'renders template passed as argument to render method' do
        get('/home')
        last_response.body.should == '{"admin":{"name":"LTe"}}'
      end

      it 'renders template passed as argument to render method with locals' do
        get('/home-detail')
        last_response.body.should == '{"admin":{"name":"LTe","details":"amazing detail"}}'
      end

      it 'renders with locals without overriding template' do
        get('/about-detail')
        last_response.body.should == '{"user":{"name":"LTe","details":"just a user","project":null}}'
      end

      it 'does not save rabl options after called #render method' do
        get('/home')
        get('/about')
        last_response.body.should == '{"user":{"name":"LTe","project":null}}'
      end
    end

    it 'should respond with proper content-type' do
      subject.get('/home', rabl: 'user') {}
      get('/home')
      last_response.headers['Content-Type'].should == 'application/json'
    end

    it 'should not raise error about root directory' do
      subject.get('/home', rabl: 'user') {}
      get '/home'
      last_response.status.should eq 200
      last_response.body.should_not include "Use Rack::Config to set 'api.tilt.root' in config.ru"
    end

    ['user', 'user.rabl'].each do |rabl_option|
      it "should render rabl template (#{rabl_option})" do
        subject.get('/home', rabl: rabl_option) do
          @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
          @project = OpenStruct.new(name: 'First')
        end

        get '/home'
        last_response.body.should == '{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'
      end
    end

    describe 'template cache' do
      before do
        @template = "#{File.dirname(__FILE__)}/views/user_cached.rabl"
        FileUtils.cp("#{File.dirname(__FILE__)}/views/user.rabl", @template)
        subject.get('/home', rabl: 'user_cached') do
          @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
          @project = OpenStruct.new(name: 'First')
        end
      end
      
      after do
        Grape::Rabl.reset_configuration!
        FileUtils.rm(@template)
      end

      it 'should serve from cache if cache_template_loading' do
        Grape::Rabl.configure do |config|
          config.cache_template_loading = true
        end
        get '/home'
        old_response = last_response.body
        open(@template, 'a') { |f| f << 'node(:test) { "test" }' }
        get '/home'
        new_response = last_response.body
        old_response.should == new_response
      end

      it 'should serve new template if cache_template_loading' do
        get '/home'
        old_response = last_response.body
        open(@template, 'a') { |f| f << 'node(:test) { "test" }' }
        get '/home'
        new_response = last_response.body
        old_response.should_not == new_response
      end
    end
  end
end
