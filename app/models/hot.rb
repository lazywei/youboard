class Hot < ActiveRecord::Base
  attr_accessible :songs, :type
  serialize :songs
end
