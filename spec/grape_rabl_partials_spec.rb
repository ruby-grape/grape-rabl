# frozen_string_literal: true

require 'spec_helper'

describe 'Grape::Rabl partials' do
  let(:parsed_response) { JSON.parse(last_response.body) }

  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::Rabl
    subject.before { env['api.tilt.root'] = "#{File.dirname(__FILE__)}/views" }
  end

  def app
    subject
  end

  it 'proper render partials' do
    subject.get('/home', rabl: 'project') do
      @author   = Struct.new(:author).new('LTe')
      @type     = Struct.new(:type).new('paper')
      @project  = Struct.new(:name, :type, :author).new('First', @type, @author)
    end

    get('/home')
    expect(parsed_response).to eq(
      JSON.parse('{"project":{"name":"First","info":{"type":"paper"},"author":{"author":"LTe"}}}')
    )
  end
end
