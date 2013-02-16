class Playlist < ActiveRecord::Base
  belongs_to :user
  attr_accessible :last_updated_at, :p_id, :hot_type, :user_id

  def can_update?
    self.last_updated_at.nil? or (Time.now - 1.hours > self.last_updated_at)
  end
end
