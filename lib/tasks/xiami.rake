namespace :crawler do
  desc "Crawl the charts from xiami.com"  
  namespace :xiami do
    def crawl_parse_search(url, finder)
      r = Typhoeus::Request.get(url)

      doc = Nokogiri::HTML(r.body)
      
      result = []
      doc.css('table.track_list td.song_name').each do |song|
        tmp =  {
          :song => song.css('a')[0].content,
          :artist => song.css('a')[1].content
        }
        tmp[:id] = finder.find_video_id(tmp.map{|x| x[0]}.join(' '))
        result << tmp
      end
      return result
    end

    desc "crawl http://www.xiami.com/music/hothuayu/time_week"
    task :time_week => :environment do
      url = "http://www.xiami.com/music/hothuayu/time_week"
      result = crawl_parse_search(url, Youtube.new)
      Hot.create!(:songs => result, :hot_type => Setting.hot_type[0])
    end

    desc "crawl http://www.xiami.com/music/billboards/c/1"
    task :hito => :environment do
      url = "http://www.xiami.com/music/billboards/c/1"
      result = crawl_parse_search(url, Youtube.new)
    end
  end
end
