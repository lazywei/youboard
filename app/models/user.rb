class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  has_many :authorizations, :dependent => :destroy

  def self.yt_client
    ''
  end

  def bind_service(response)
    provider = response["provider"]
    uid = response["uid"]
    authorizations.find_or_create_by_provider_and_uid!(provider, uid)
  end

  def can_bind_to
    Setting.providers - (self.authorizations.map {|auth| auth.provider})
  end

end
