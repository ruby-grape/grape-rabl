object @user => :user
attributes :name, :email

child @project => :project do
  attributes :name
end
