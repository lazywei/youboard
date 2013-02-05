require 'google/api_client'

class UpdateWorker
  include Sidekiq::Worker

  def perform(user, count)
    user = User.find(user["id"])
    return unless user.can_update_playlist?
    user.updated_playlist_at = Time.now
    user.save

    client = Google::APIClient.new(:application_name => 'YouBoard', :application_version => '1.0')
    yt = client.discovered_api('youtube', 'v3')
    client.authorization.access_token = user.authorizations.find_by_provider('google_oauth2').get_token!
    pid = user.playlist


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
      videos = Hot.last.songs.slice(50*i, 50)

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

  #def perform(user, count)
  #  user = User.find(user["id"])
  #  return unless user.can_update_playlist?
  #  user.updated_playlist_at = Time.now
  #  user.save
  #  yt = user.yt_client
  #  pid = user.playlist

  #  p "pid = #{pid}"
  #  while true
  #    videos = yt.playlist(pid).videos.slice(0, 7)
  #    p "videos size = #{videos.size}"
  #    break if videos.size == 0
  #    videos.each do |v|
  #      yt.delete_video_from_playlist(pid, v.in_playlist_id)
  #      p "delete #{v.in_playlist_id}"
  #    end
  #    sleep 30
  #  end
  #  p 'Deleted ALL'

  #  0.upto(14) do |i|
  #    videos = Hot.last.songs.slice(7*i, 7)
  #    p "videos size = #{videos.size}"
  #    break if videos.size == 0
  #    videos.each do |v|
  #      yt.add_video_to_playlist(pid, v[:id])
  #      p "Add #{v[:id]}, #{v[:song]}"
  #    end
  #    sleep 30
  #  end
  #  p 'Added All, Done!'
  #end
end
