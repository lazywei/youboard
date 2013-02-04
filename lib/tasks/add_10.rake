desc "Crawl the hot 100 from BillBoard website."  
task :add_10 => :environment do
  user = User.first
  yt = user.yt_client
  pid = user.playlist


  p "pid = #{pid}"

  0.upto(3) do |i|
    videos = Hot.last.songs.slice(0, 8)
    p "videos size = #{videos.size}"
    videos.each do |v|
      yt.add_video_to_playlist(pid, v[:id])
      p "Add #{v[:id]}, #{v[:song]}"
    end
    p 'sleep for 20 sec'
    sleep 20
  end
  p 'Done!'
end
