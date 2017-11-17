object @user => :user
attributes :name, :email

child @project => :project do
  attributes :name
end

node :details, unless: ->(_n) { locals[:details].nil? } do |_m|
  locals[:details]
end
