# frozen_string_literal: true

node(:status) { @status }

node(:result) do
  JSON.parse(yield)
end
