class User < ActiveRecord::Base
  extend OmniauthCallbacks
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :playlist
  # attr_accessible :title, :body
  has_many :authorizations, :dependent => :destroy
  
  def yt_client
    dev_key = "AI39si4X8tG4AbBOrBJEPDLNYgm5L6tLhKOWi-spAE5sH4N9CS-3nKgExktTRBudmp6lwW0YyhzA4wRd0Qur4EXY-BjaOtTxsw"
    client = YouTubeIt::OAuth2Client.new(
      client_access_token: self.authorizations.find_by_provider(:google_oauth2).token,
      client_id: Setting.google_oauth2_token,
      client_secret: Setting.google_oauth2_secret,
      dev_key: dev_key, expires_at: "3600")
  end

  def bind_service(response)
    provider = response["provider"]
    uid = response["uid"]
    authorizations.find_or_create_by_provider_and_uid!(provider, uid)
  end

  def update_token(response)
    provider = response["provider"]
    auth = authorizations.find_by_provider(provider)
    auth.update_attributes(:token => response["credentials"]["token"])
  end

  def can_bind_to
    Setting.providers - (self.authorizations.map {|auth| auth.provider})
  end

end
