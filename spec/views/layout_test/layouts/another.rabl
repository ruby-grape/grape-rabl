# frozen_string_literal: true

node(:result) do
  JSON.parse(yield)
end
