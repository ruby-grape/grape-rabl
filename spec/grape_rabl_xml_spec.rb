# frozen_string_literal: true

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

  context 'with xml format' do
    before do
      subject.before do
        env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views"
        env['api.format'] = :xml
      end
    end

    it 'should respond with proper content-type' do
      subject.get('/home', rabl: 'user') { nil }
      get('/home')
      expect(last_response.headers['Content-Type']).to eq('application/xml')
    end

    ['user', 'user.rabl'].each do |rabl_option|
      it "should render rabl template (#{rabl_option})" do
        subject.get('/home', rabl: rabl_option) do
          @user = Struct.new(:name, :email).new('LTe', 'email@example.com')
          @project = Struct.new(:name).new('First')
        end

        get '/home'

        expect(last_response.body).to eq(%(<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>LTe</name>
  <email>email@example.com</email>
  <project>
    <name>First</name>
  </project>
</user>
))
      end
    end
  end
end
