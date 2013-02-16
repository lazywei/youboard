class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  def index
  end

  def subscribe
    hot_type = Setting.hot_type[params[:hot_type_id].to_i]
    if current_user.find_or_create_playlist_by_hot_type(hot_type).can_update?
      args = {
        :user_id => current_user.id,
        :type => hot_type,
        :token => current_user.authorizations.find_by_provider('google_oauth2').get_token!
      }
      UpdateWorker.perform_async(args, 1) 
      flash[:notice] = "Pleas wait minutes for #{hot_type.humanize} playlist updating."
    else
      flash[:notice] = 'We are updating your playlist, please wait.'
    end
    redirect_to root_path
  end
end
