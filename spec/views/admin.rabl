object @user => :admin
attributes :name

node :details, unless: ->(_n) { locals[:details].nil? } do |_m|
  locals[:details]
end
