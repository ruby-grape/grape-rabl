object @user => :user
attributes :name, :email

child @project => :project do
  attributes :name
end

node :details, :unless => lambda { |n| locals[:details].nil? } do |m|
  locals[:details]
end
