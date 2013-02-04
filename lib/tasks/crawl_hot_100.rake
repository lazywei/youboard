desc "Crawl the hot 100 from BillBoard website."  
task :crawl_hot_100 => :environment do
  def parse(html)
    doc = Nokogiri::HTML(html)
    result = []
    doc.css('article.song_review header').each do |x|
      song = x.at_css('h1').content
      if x.at_css('p.chart_info a')
        artist = x.at_css('p.chart_info a').content 
      else
        artist = x.at_css('p.chart_info').content
      end
      result << {:song => song , :artist => artist}
    end
    return result
  end

  songs = []
  result = []

  0.upto(9).each do |page|
    r = Typhoeus::Request.new("http://www.billboard.com/charts/hot-100?page=#{page}", :method => :get)
    r.run
    result += parse(r.response.body)
  end

  client = YouTubeIt::Client.new(:dev_key => 'AI39si4X8tG4AbBOrBJEPDLNYgm5L6tLhKOWi-spAE5sH4N9CS-3nKgExktTRBudmp6lwW0YyhzA4wRd0Qur4EXY-BjaOtTxsw')
  0.upto(3) do |i|
    result.slice(i*25, 25).each do |r|
      id = client.videos_by(:query => r[:song]).videos[0].video_id.split(':').last
      songs << ({:id => id}.merge(r))
    end
    sleep 15
  end
  Hot.create!(:songs => songs)
end
