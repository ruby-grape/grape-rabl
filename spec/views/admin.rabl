object @user => :admin
attributes :name

node :details, :unless => lambda { |n| locals[:details].nil? } do |m|
  locals[:details]
end
