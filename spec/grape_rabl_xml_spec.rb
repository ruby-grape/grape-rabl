require 'spec_helper'

describe Grape::Rabl do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :xml
    subject.formatter :xml, Grape::Formatter::Rabl
  end

  def app
    subject
  end

  context 'with xml format'  do
    before do
      subject.before do
        env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views"
        env['api.format'] = :xml
      end
    end

    it 'should respond with proper content-type' do
      subject.get('/home', rabl: 'user') {}
      get('/home')
      last_response.headers['Content-Type'].should == 'application/xml'
    end

    ['user', 'user.rabl'].each do |rabl_option|
      it "should render rabl template (#{rabl_option})" do
        subject.get('/home', rabl: rabl_option) do
          @user = OpenStruct.new(name: 'LTe', email: 'email@example.com')
          @project = OpenStruct.new(name: 'First')
        end

        get '/home'

        last_response.body.should == %Q(<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>LTe</name>
  <email>email@example.com</email>
  <project>
    <name>First</name>
  </project>
</user>
)
      end
    end
  end
end
