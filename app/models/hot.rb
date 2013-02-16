class Hot < ActiveRecord::Base
  attr_accessible :songs, :hot_type
  serialize :songs
end
