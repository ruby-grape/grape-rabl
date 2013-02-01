object @project => :project
attributes :name

node :info do
  partial "partial", object: @project.type
end

child @author => :author do
  extends "info"
end