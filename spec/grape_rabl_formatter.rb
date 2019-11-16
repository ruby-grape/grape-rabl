require 'spec_helper'

describe 'Grape::Rabl formatter' do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :xml
    subject.formatter :xml, Grape::Formatter::Rabl
    subject.default_format :xml
  end

  context 'fallback rendering' do
    it 'should fallback to using the default formatter if no template is specified' do
      subject.get('/oops') { { errors: %w[bad things happened] } }
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
