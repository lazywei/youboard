namespace :crawler do
  desc "Crawl the charts from xiami.com"  
  task :nztop40 => :environment do
    r = Typhoeus::Request.get('http://nztop40.co.nz/')
    doc = Nokogiri::HTML(r.body)
    result = []
    doc.css('div.record_label').each do |song|
      result << {
        :song => song.at_css('.title').content,
        :artist => song.at_css('.artist').content
      }
    end
    ids = Youtube.new.batch_search(result.map {|x| "#{x[:song]} #{x[:artist]}"})
    ids.each_with_index {|id, index| result[index][:id] = id}

    Hot.create!(:songs => result, :hot_type => Setting.hot_type[1])
  end
end
