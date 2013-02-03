class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  def index
  end

  def subscribe
    yt = current_user.yt_client
    if current_user.playlist.nil?
      playlist = yt.add_playlist(:title => "BillBoard Hot 100", :description => "The collections for this week's BillBoard Hot 100 singles!")
      current_user.update_attributes(:playlist => playlist.playlist_id)
    end
    
    # Remove all videos in the playlist
    yt.playlist(current_user.playlist).videos.each do |v|
      yt.delete_video_from_playlist(current_user.playlist, v.video_id)
    end

    # Add hot 100 into playlist
    Hot.last.songs.each do |song|
      yt.add_video_to_playlist(current_user.playlist, song[:id])
    end

    redirect_to root_path
  end
end
