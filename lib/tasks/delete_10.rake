desc "Crawl the hot 100 from BillBoard website."  
task :delete_10 => :environment do
  user = User.first
  yt = user.yt_client
  pid = user.playlist


  p "pid = #{pid}"
  videos = yt.playlist(pid).videos.slice(0, 8)
  p "videos size = #{videos.size}"
  videos.each do |v|
    yt.delete_video_from_playlist(pid, v.in_playlist_id)
    p "delete #{v.in_playlist_id}"
  end
  p 'Done!'
end
