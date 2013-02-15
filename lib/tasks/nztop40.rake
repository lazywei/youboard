namespace :crawler do
  desc "Crawl the charts from xiami.com"  
  task :nztop40 => :environment do

    r = Typhoeus::Request.get('http://nztop40.co.nz/')
    doc = Nokogiri::HTML(r.body)
    result = []
    doc.css('div.record_label').each do |song|
      tmp = {
        :song => song.at_css('.title').content,
        :artist => song.at_css('.artist').content
      }
      tmp[:id] = Youtube.find_video_id("#{tmp[:song]} #{tmp[:artist]}")
      result << tmp
    end

    Hot.create!(:songs => result, :type => 'nztop40')
  end
end
