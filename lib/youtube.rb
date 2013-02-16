# -*- encoding : utf-8 -*-
require 'google/api_client'
class Youtube
  def initialize
    @client = Google::APIClient.new(:application_name => 'YouBoard', :application_version => '1.0', :key => "AIzaSyCpdYMHWovpNC4bPHyTs4puTPp523B3BYk")
    @yt = @client.discovered_api('youtube', 'v3')
  end

  def find_video_id(q)
    @client.authorization = nil
    req = {
      :api_method => @yt.search.list,
      :parameters => {
        :part => 'id',
        :q => q
      }
    }

    return @client.execute!(req).data.items[0].id.videoId
  end

  def create_playlist(name, token)
    @client.authorization.access_token = token
    r = @client.execute!(
      :api_method => @yt.playlists.insert,
      :parameters => {'part' => 'snippet,status'},
      :body_object => {
        'snippet' => { 'title' => name },
        'status' => { 'privacyStatus' => 'public' }
      }
    )
    return r.data.id
  end
end
