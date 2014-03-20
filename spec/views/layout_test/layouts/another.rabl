node(:result) do
  JSON.parse(yield)
end
