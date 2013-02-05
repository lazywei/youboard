class Authorization < ActiveRecord::Base

  belongs_to :user
  attr_accessible :provider, :expires_at, :refresh_token, :token, :uid, :user_id

  def get_token!
    if (Time.now > self.expires_at)
      r = Typhoeus::Request.post("https://accounts.google.com/o/oauth2/token",
                             :body => "client_id=#{Setting.google_oauth2_token}&client_secret=#{Setting.google_oauth2_secret}&refresh_token=#{self.refresh_token}&grant_type=refresh_token")
      result = JSON.parse(r.body)
      self.token = result["access_token"]
      self.expires_at = self.expires_at + result["expires_in"]
      self.save
    end
    return self.token
  end

end
