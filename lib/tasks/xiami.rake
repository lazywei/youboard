require 'google/api_client'

namespace :crawler do
  desc "Crawl the charts from xiami.com"  
  namespace :xiami do

    @client = Google::APIClient.new(:application_name => 'YouBoard', :application_version => '1.0', :key => "AIzaSyCpdYMHWovpNC4bPHyTs4puTPp523B3BYk", :authorization => nil)
    @yt = @client.discovered_api('youtube', 'v3')

    def crawl_parse_search(url)
      req = {
        :api_method => @yt.search.list,
        :parameters => {
          :part => 'id'
        }
      }

      r = Typhoeus::Request.get(url)

      doc = Nokogiri::HTML(r.body)
      
      result = []
      doc.css('table.track_list td.song_name').each do |song|
        tmp =  {
          :song => song.css('a')[0].content,
          :artist => song.css('a')[1].content
        }
        req[:parameters][:q] = tmp.map{|x| x[0]}.join(' ')
        tmp[:id] = @client.execute!(req).data.items[0].id.videoId
        result << tmp
      end
      return result
    end

    desc "crawl http://www.xiami.com/music/hothuayu/time_week"
    task :time_week => :environment do
      url = "http://www.xiami.com/music/hothuayu/time_week"
      result = crawl_parse_search(url)
    end

    desc "crawl http://www.xiami.com/music/billboards/c/1"
    task :hito => :environment do
      url = "http://www.xiami.com/music/billboards/c/1"
      result = crawl_parse_search(url)
    end
  end
end
