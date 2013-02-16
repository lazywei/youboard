require 'google/api_client'

class UpdateWorker
  include Sidekiq::Worker

  # args = {"user_id" => '', "type" => '', "token" => ''}
  def perform(args, count)
    playlist = User.find(args["user_id"].to_i).find_or_create_playlist_by_hot_type(args["type"])
    return unless playlist.can_update?

    playlist.last_updated_at = Time.now
    playlist.save

    client = Google::APIClient.new(:application_name => 'YouBoard', :application_version => '1.0')
    yt = client.discovered_api('youtube', 'v3')
    client.authorization.access_token = args["token"]
    pid = playlist.p_id


    # Delete all playlist items
    while true
      # Get all playlist items
      r = client.execute!(
        :api_method => yt.playlist_items.list,
        :parameters => {
          :playlistId => pid,
          :part => 'id',
          :maxResults => 50
        }
      )
      break if r.data.pageInfo['totalResults'] == 0

      ids = r.data.items.collect {|x| x.id}

      ids.each do |id|
        r = client.execute!(
          :api_method => yt.playlist_items.delete,
          :parameters => {'id' => id},
        )
        p r.data
      end
      sleep 30
    end


    0.upto(1) do |i|
      videos = Hot.where(:hot_type => args["type"]).last.songs.slice(50*i, 50)
      break if (videos.nil? or videos.empty?)

      videos.each do |v|
        r = client.execute!(
          :api_method => yt.playlist_items.insert,
          :parameters => {'part' => 'snippet'},
          :body_object => {
            'snippet' => {
              'playlistId' => pid,
              'resourceId' => {"kind"=>"youtube#video", "videoId"=>v[:id]}
            }
          }
        )
        p r.data
      end
      sleep 30
    end

  end
end
