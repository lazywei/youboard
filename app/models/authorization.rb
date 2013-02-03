class Authorization < ActiveRecord::Base

  belongs_to :user
  attr_accessible :provider, :secret, :token, :uid, :user_id
end
