namespace :crawler do

  desc "Crawl the charts from www.billboard.com"  
  namespace :billboard do

    desc "Crawl the hot 100"  
    task :hot_100 => :environment do
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

      0.upto(5).each do |page|
        r = Typhoeus::Request.get("http://www.billboard.com/charts/hot-100?page=#{page}")
        result += parse(r.body)
      end

      result.each do |song|
        id = Youtube.find_video_id("#{song[:song]} #{song[:artist]}")
        songs << {:id => id}.merge(song)
      end

      Hot.create!(:songs => songs, :type => 'billboard_hot_100')
    end
  end
end
