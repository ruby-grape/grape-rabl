require 'spec_helper'

describe Grape::Rabl do
  subject { Class.new(Grape::API) }
  before { subject.default_format :json }
  def app; subject end

  it 'should work without rabl template' do
    subject.get("/home") {"Hello World"}
    get "/home"
    last_response.body.should == "Hello World"
  end

  it "should raise error about root directory" do
    subject.get("/home", :rabl => true){}
    lambda{ get "/home" }.should raise_error("Use Rack::Config to set 'api.tilt.root' in config.ru")
  end

  context "titl root is setup"  do
    before do
      subject.before { env["api.tilt.root"] = "#{File.dirname(__FILE__)}/views" }
    end

    it "should not raise error about root directory" do
      subject.get("/home", :rabl => true){}
      lambda{ get "/home" }.should_not raise_error("Use Rack::Config to set 'api.tilt.root' in config.ru")
    end

    it "should render rabl template" do
      subject.get("/home", :rabl => "user.rabl") do
        @user = OpenStruct.new(:name => "LTe", :email => "email@example.com")
        @project = OpenStruct.new(:name => "First")
      end

      get "/home"
      last_response.body.should == '{"user":{"name":"LTe","email":"email@example.com","project":{"name":"First"}}}'
    end
  end
end
