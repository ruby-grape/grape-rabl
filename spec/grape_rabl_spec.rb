require 'spec_helper'

describe Grape::Rabl do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::Rabl
  end

  def app
    subject
  end

  it 'should work without rabl template' do
    subject.get("/home") {"Hello World"}
    get "/home"
    last_response.body.should == "Hello World"
  end

  it "should raise error about root directory" do
    subject.get("/home", :rabl => true){}
    get "/home"
    last_response.status.should == 500
    last_response.body.should include "Use Rack::Config to set 'api.tilt.root' in config.ru"
  end


  context "titl root is setup"  do
    before do
      subject.before { env["api.tilt.root"] = "#{File.dirname(__FILE__)}/views" }
    end

    describe "#render" do
      before do
        subject.get("/home", :rabl => "user") do
          @user = OpenStruct.new(:name => "LTe")
          render :rabl => "admin"
        end

        subject.get("/about", :rabl => "user") do
          @user = OpenStruct.new(:name => "LTe")
        end
      end

      it "renders template passed as argument to reneder method" do
        get("/home")
        last_response.body.should == '{"admin":{"name":"LTe"}}'
      end

      it "does not save rabl options after called #render method" do
        get("/home")
        get("/about")
        last_response.body.should == '{"user":{"name":"LTe","project":null}}'
      end
    end


    it "should respond with proper content-type" do
      subject.get("/home", :rabl => "user"){}
      get("/home")
      last_response.headers["Content-Type"].should == "application/json"
    end

    it "should not raise error about root directory" do
      subject.get("/home", :rabl => true){}
      get "/home"
      last_response.status.should == 500
      last_response.body.should_not include "Use Rack::Config to set 'api.tilt.root' in config.ru"
    end

    ["user", "user.rabl"].each do |rabl_option|
      it "should render rabl template (#{rabl_option})" do
        subject.get("/home", :rabl => rabl_option) do
          @user = OpenStruct.new(:name => "LTe", :email => "email@example.com")
          @project = OpenStruct.new(:name => "First")
        end

        get "/home"
        last_response.body.should == '{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'
      end
    end
  end
end
