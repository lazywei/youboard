#desc "Crawl the hot 100 from BillBoard website."  
#task :delete_10 => :environment do
#end

class UpdateWorker
  include Sidekiq::Worker

  def perform(user, count)
    user = User.find(user["id"])
    return unless user.can_update_playlist?
    yt = user.yt_client
    pid = user.playlist

    p "pid = #{pid}"
    while true
      videos = yt.playlist(pid).videos.slice(0, 8)
      p "videos size = #{videos.size}"
      break if videos.size == 0
      videos.each do |v|
        yt.delete_video_from_playlist(pid, v.in_playlist_id)
        p "delete #{v.in_playlist_id}"
      end
      sleep 20
    end
    p 'Deleted ALL'

    0.upto(12) do |i|
      videos = Hot.last.songs.slice(8*i, 8)
      p "videos size = #{videos.size}"
      break if videos.size == 0
      videos.each do |v|
        yt.add_video_to_playlist(pid, v[:id])
        p "Add #{v[:id]}, #{v[:song]}"
      end
      sleep 20
    end
    p 'Added All, Done!'
  end
end
