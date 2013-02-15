namespace :crawler do
  desc "Crawl the charts from xiami.com"  
  namespace :xiami do
    def crawl_parse_search(url)
      r = Typhoeus::Request.get(url)

      doc = Nokogiri::HTML(r.body)
      
      result = []
      doc.css('table.track_list td.song_name').each do |song|
        tmp =  {
          :song => song.css('a')[0].content,
          :artist => song.css('a')[1].content
        }
        tmp[:id] = Youtube.find_video_id(tmp.map{|x| x[0]}.join(' '))
        result << tmp
      end
      return result
    end

    desc "crawl http://www.xiami.com/music/hothuayu/time_week"
    task :time_week => :environment do
      url = "http://www.xiami.com/music/hothuayu/time_week"
      result = crawl_parse_search(url)
      Hot.create!(:songs => result, :type => 'xiami_time_week')
    end

    desc "crawl http://www.xiami.com/music/billboards/c/1"
    task :hito => :environment do
      url = "http://www.xiami.com/music/billboards/c/1"
      result = crawl_parse_search(url)
    end
  end
end
