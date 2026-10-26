# frozen_string_literal: true

require 'spec_helper'

describe Grape::Rabl::Formatter do
  before do
    hide_const('Tilt::Cache')
    described_class.tilt_cache.clear
  end

  after do
    described_class.tilt_cache.clear
  end

  it 'reuses a cached template without Tilt::Cache' do
    template = described_class.fetch_cached_template(:template) { Object.new }

    expect(described_class.fetch_cached_template(:template) { raise 'recompiled' })
      .to equal(template)
  end

  it 'memoizes missing layouts' do
    expect(described_class.fetch_cached_template(:missing) { nil }).to be_nil
    expect(described_class.fetch_cached_template(:missing) { raise 'looked up again' })
      .to be_nil
  end

  it 'creates one cached template for concurrent requests' do
    threads = 4.times.map do
      Thread.new do
        described_class.fetch_cached_template(:concurrent) do
          sleep 0.01
          Object.new
        end
      end
    end

    expect(threads.map(&:value).map(&:object_id).uniq.size).to eq(1)
  end
end

describe 'Grape::Rabl formatter' do
  subject do
    Class.new(Grape::API)
  end

  let(:xml_render) do
    %(<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <errors type="array">
    <error>bad</error>
    <error>things</error>
    <error>happened</error>
  </errors>
</hash>
)
  end

  def app
    subject
  end

  context 'rendering' do
    context 'when no rabl template is specified' do
      before do
        # Grape::API defaults to the following declarations:
        # content_type :xml, 'application/xml'
        # content_type :json, 'application/json'
        # content_type :binary, 'application/octet-stream'
        # content_type :txt, 'text/plain'
        # default_format :txt
        subject.formatter :xml, Grape::Formatter::Rabl
        subject.formatter :txt, Grape::Formatter::Rabl
        subject.get('/oops') { { errors: %w[bad things happened] } }
        expect_any_instance_of(Grape::Rabl::Formatter).to receive(:render).and_call_original
      end

      it 'falls back to :txt given no other format information' do
        get '/oops'
        expect(last_response.body).to eq({ errors: %w[bad things happened] }.to_s)
        expect(last_response.headers['Content-Type']).to eq('text/plain')
      end

      it 'falls back to the file extension if it is a valid format' do
        get '/oops.xml'
        expect(last_response.body).to eq(xml_render)
        expect(last_response.headers['Content-Type']).to eq('application/xml')
      end

      it 'falls back to the value of the `format` parameter in the query string if it is provided' do
        get '/oops?format=xml'
        expect(last_response.body).to eq(xml_render)
        expect(last_response.headers['Content-Type']).to eq('application/xml')
      end

      it 'falls back to the format set by the `format` option if it is a valid format' do
        # `format` option must be declared before endpoint
        subject.format :xml
        subject.get('/oops/2') { { errors: %w[bad things happened] } }

        get '/oops/2'
        expect(last_response.body).to eq(xml_render)
        expect(last_response.headers['Content-Type']).to eq('application/xml')
      end

      it 'falls back to the `Accept` header if it is a valid format' do
        get '/oops', {}, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.body).to eq(xml_render)
        expect(last_response.headers['Content-Type']).to eq('application/xml')
      end

      it 'falls back to the default_format option if it is a valid format' do
        # `default_format` option must be declared before endpoint
        subject.default_format :xml
        subject.get('/oops/2') { { errors: %w[bad things happened] } }

        get '/oops/2'
        expect(last_response.body).to eq(xml_render)
        expect(last_response.headers['Content-Type']).to eq('application/xml')
      end
    end
  end
end
