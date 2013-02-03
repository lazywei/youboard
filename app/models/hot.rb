class Hot < ActiveRecord::Base
  attr_accessible :songs
  serialize :songs
end
