require 'spec_helper'

describe "Grape::Rabl layout" do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::Rabl
    subject.before do
      env["api.tilt.root"] = "#{File.dirname(__FILE__)}/views/layout_test"
    end
  end

  def app
    subject
  end

  context 'default' do
    it "proper render with default layout" do
      subject.get("/about", :rabl => "user") do
        @user = OpenStruct.new(:name => "LTe")
        @project = OpenStruct.new(:name => "First")
        @status = 200
      end

      get("/about")
      last_response.body.should ==
        %Q!{"status":200,"result":{"user":{"name":"LTe","project":{"name":"First"}}}}!
    end
  end

  context 'tilt layout is setup' do
    before do
      subject.before { env["api.tilt.layout"] = "layouts/another" }
    end

    it "proper render with specified layout" do
      subject.get("/about", :rabl => "user") do
        @user = OpenStruct.new(:name => "LTe")
        @project = OpenStruct.new(:name => "First")
        @status = 200
      end

      get("/about")
      puts last_response.body
      last_response.body.should ==
        %Q!{"result":{"user":{"name":"LTe","project":{"name":"First"}}}}!
    end
  end
end