class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  def index
  end

  def subscribe
    if current_user.find_or_create_playlist_by_hot_type(Setting.hot_type[1]).can_update?
      args = {
        :user_id => current_user.id,
        :type => Setting.hot_type[1],
        :token => current_user.authorizations.find_by_provider('google_oauth2').get_token!
      }
      UpdateWorker.perform_async(args, 1) 
      flash[:notice] = 'Pleas wait minutes for playlist updating.'
    else
      flash[:notice] = 'We are updating your playlist, please wait.'
    end
    redirect_to root_path
  end
end
