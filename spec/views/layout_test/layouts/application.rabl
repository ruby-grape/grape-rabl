node(:status) { @status }

node(:result) do
  JSON.parse(yield)
end
