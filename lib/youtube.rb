# -*- encoding : utf-8 -*-
require 'google/api_client'
class Youtube
  @client = Google::APIClient.new(:application_name => 'YouBoard', :application_version => '1.0', :key => "AIzaSyCpdYMHWovpNC4bPHyTs4puTPp523B3BYk", :authorization => nil)
  @yt = @client.discovered_api('youtube', 'v3')

  def self.find_video_id(q)
    req = {
      :api_method => @yt.search.list,
      :parameters => {
        :part => 'id',
        :q => q
      }
    }
    
    return @client.execute!(req).data.items[0].id.videoId
  end
end
