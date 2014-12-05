require 'spec_helper'

describe 'Grape::Rabl layout' do
  let(:parsed_response) { JSON.parse(last_response.body) }

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
      parsed_response.should ==
        JSON.parse(%Q({"status":200,"result":{"user":{"name":"LTe","project":{"name":"First"}}}}))
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
      parsed_response.should ==
        JSON.parse(%Q({"result":{"user":{"name":"LTe","project":{"name":"First"}}}}))
    end
  end

  context 'layout cache' do
    before do
      @views_dir = FileUtils.mkdir_p("#{File.expand_path("..", File.dirname(__FILE__))}/tmp")[0]
      @layout = "#{@views_dir}/layouts/application.rabl"
      FileUtils.cp_r("#{File.dirname(__FILE__)}/views/layout_test/.", @views_dir)
      subject.before { env['api.tilt.root'] = "#{File.expand_path("..", File.dirname(__FILE__))}/tmp" }
      subject.get('/home', rabl: 'user') do
        @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
        @project = OpenStruct.new(name: 'First')
        @status = 200
      end
    end

    after do
      Grape::Rabl.reset_configuration!
      FileUtils.rm_f(@views_dir)
    end

    it 'should serve from cache if cache_template_loading' do
      Grape::Rabl.configure do |config|
        config.cache_template_loading = true
      end
      get '/home'
      last_response.status.should be == 200
      old_response = last_response.body
      open(@layout, 'a') { |f| f << 'node(:test) { "test" }' }
      get '/home'
      last_response.status.should be == 200
      new_response = last_response.body
      old_response.should == new_response
    end

    it 'should serve new template if cache_template_loading' do
      get '/home'
      last_response.status.should be == 200
      old_response = last_response.body
      open(@layout, 'a') { |f| f << 'node(:test) { "test" }' }
      get '/home'
      last_response.status.should be == 200
      new_response = last_response.body
      old_response.should_not == new_response
    end
  end
end
