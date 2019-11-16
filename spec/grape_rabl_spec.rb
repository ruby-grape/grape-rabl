require 'spec_helper'

describe Grape::Rabl do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.default_format :json
    subject.formatter :json, Grape::Formatter::Rabl
    subject.formatter :xml, Grape::Formatter::Rabl
    subject.helpers MyHelper
  end

  def app
    subject
  end

  it 'should work without rabl template' do
    subject.get('/home') { 'Hello World' }
    get '/home'
    expect(last_response.body).to eq('"Hello World"')
  end

  it 'should raise error about root directory' do
    begin
      subject.get('/home', rabl: true) {}
      get '/home'
    rescue Exception => e
      expect(e.message).to include "Use Rack::Config to set 'api.tilt.root' in config.ru"
    end
  end

  context 'titl root is setup' do
    let(:parsed_response) { JSON.parse(last_response.body) }

    before do
      subject.before { env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views" }
    end

    describe 'helpers' do
      it 'should execute helper' do
        subject.get('/home', rabl: 'helper') { @user = OpenStruct.new }
        get '/home'
        expect(parsed_response).to eq(JSON.parse('{"user":{"helper":"my_helper"}}'))
      end
    end

    describe '#render' do
      before do
        subject.get('/home', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')
          render rabl: 'admin'
        end

        subject.get('/admin/:id', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe')

          render rabl: 'admin' if params[:id] == '1'
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
        expect(parsed_response).to eq(JSON.parse('{"admin":{"name":"LTe"}}'))
      end

      it 'renders admin template' do
        get('/admin/1')
        expect(parsed_response).to eq(JSON.parse('{"admin":{"name":"LTe"}}'))
      end

      it 'renders user template' do
        get('/admin/2')
        expect(parsed_response).to eq(JSON.parse('{"user":{"name":"LTe","project":null}}'))
      end

      it 'renders template passed as argument to render method with locals' do
        get('/home-detail')
        expect(parsed_response).to eq(JSON.parse('{"admin":{"name":"LTe","details":"amazing detail"}}'))
      end

      it 'renders with locals without overriding template' do
        get('/about-detail')
        expect(parsed_response).to eq(JSON.parse('{"user":{"name":"LTe","details":"just a user","project":null}}'))
      end

      it 'does not save rabl options after called #render method' do
        get('/home')
        get('/about')
        expect(parsed_response).to eq(JSON.parse('{"user":{"name":"LTe","project":null}}'))
      end

      it 'does not modify endpoint options' do
        get '/home'
        expect(last_request.env['api.endpoint'].options[:route_options][:rabl]).to eq 'user'
      end

      context 'fallback rendering' do
        before do
          subject.format :xml
          subject.formatter :xml, Grape::Formatter::Rabl
          subject.default_format :xml
        end

        it 'should fallback to using the default formatter' do
          subject.get('/oops') { { errors: ['bad', 'things', 'happened'] } }
          get '/oops'
          expect(last_response.body).to eq(%(<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <errors type="array">
    <error>bad</error>
    <error>things</error>
    <error>happened</error>
  </errors>
</hash>
))
        end
      end
    end

    it 'should respond with proper content-type' do
      subject.get('/home', rabl: 'user') {}
      get('/home')
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'should not raise error about root directory' do
      subject.get('/home', rabl: 'user') {}
      get '/home'
      expect(last_response.status).to eq 200
      expect(last_response.body).not_to include "Use Rack::Config to set 'api.tilt.root' in config.ru"
    end

    ['user', 'user.rabl'].each do |rabl_option|
      it "should render rabl template (#{rabl_option})" do
        subject.get('/home', rabl: rabl_option) do
          @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
          @project = OpenStruct.new(name: 'First')
        end

        get '/home'
        expect(parsed_response).to eq(JSON.parse('{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'))
      end
    end

    describe 'template cache' do
      before do
        @views_dir = FileUtils.mkdir_p("#{File.expand_path('..', File.dirname(__FILE__))}/tmp")[0]
        @template = "#{@views_dir}/user.rabl"
        FileUtils.cp("#{File.dirname(__FILE__)}/views/user.rabl", @template)
        subject.before { env['api.tilt.root'] = "#{File.expand_path('..', File.dirname(__FILE__))}/tmp" }
        subject.get('/home', rabl: 'user') do
          @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
          @project = OpenStruct.new(name: 'First')
        end
      end

      after do
        Grape::Rabl.reset_configuration!
        FileUtils.rm_r(@views_dir)
      end

      it 'should serve from cache if cache_template_loading' do
        Grape::Rabl.configure do |config|
          config.cache_template_loading = true
        end
        get '/home'
        expect(last_response.status).to eq(200)
        old_response = last_response.body
        open(@template, 'a') { |f| f << 'node(:test) { "test" }' }
        get '/home'
        expect(last_response.status).to eq(200)
        new_response = last_response.body
        expect(old_response).to eq(new_response)
      end

      it 'should maintain different cached templates for different formats' do
        Grape::Rabl.configure do |config|
          config.cache_template_loading = true
        end
        get '/home'
        expect(last_response.status).to eq(200)
        json_response = last_response.body
        get '/home.xml'
        expect(last_response.status).to eq(200)
        xml_response = last_response.body
        expect(json_response).not_to eq(xml_response)
        open(@template, 'a') { |f| f << 'node(:test) { "test" }' }
        get '/home.xml'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(xml_response)
        get '/home.json'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(json_response)
      end

      it 'should serve new template unless cache_template_loading' do
        get '/home'
        expect(last_response.status).to eq(200)
        old_response = last_response.body
        open(@template, 'a') { |f| f << 'node(:test) { "test" }' }
        get '/home'
        expect(last_response.status).to eq(200)
        new_response = last_response.body
        expect(old_response).not_to eq(new_response)
      end
    end
  end
end
