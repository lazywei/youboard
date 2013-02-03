class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  def index
  end

  def subscribe
    yt = current_user.yt_client
    if current_user.playlist.nil?
      playlist = yt.add_playlist(:title => "BillBoard Hot 100", :description => "The collections for this week's BillBoard Hot 100 singles!")
      current_user.update_attributes(:playlist => playlist.playlist_id)
    end

    pid = current_user.playlist

    r = Typhoeus::Request.new(
      "https://gdata.youtube.com/feeds/api/playlists/#{pid}/batch?v=2",
      :method => :post,
        :headers => {
        "Content-Type" => "application/atom+xml", 
        "Authorization" => "Bearer #{current_user.authorizations.find_by_provider(:google_oauth2).token}",
        "GData-Version" => 2,
        "X-GData-Key" => "key=AI39si4X8tG4AbBOrBJEPDLNYgm5L6tLhKOWi-spAE5sH4N9CS-3nKgExktTRBudmp6lwW0YyhzA4wRd0Qur4EXY-BjaOtTxsw",
      },
    )

      # Add hot 100 into playlist by batch API
      # Ref: https://developers.google.com/youtube/2.0/developers_guide_protocol_batch_processing
      #
      0.upto(4) do
        to_del = yt.playlist(pid).videos
        break if to_del.nil?

        builder = Nokogiri::XML::Builder.new do |xml|
          xml.feed("xmlns" => "http://www.w3.org/2005/Atom","xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:batch" => "http://schemas.google.com/gdata/batch", "xmlns:yt" => "http://gdata.youtube.com/schemas/2007") {
            xml["batch"].operation("type"=>"update")
            to_del.each do |v|
              xml.entry {
                xml["batch"].operation("type"=>"delete")
                xml.id_ v.video_id
                xml.link("rel" => "edit", "type" => "application/atom+xml", "href" => "https://gdata.youtube.com/feeds/api/playlists/#{pid}/#{v.in_playlist_id}?v=2")
              }
            end
          }
        end
        prepare_request(r, builder).run
      end

      0.upto(2) do |x|
        to_add = Hot.last.songs.slice(33*x,33)
        break if to_add.nil?

        builder1 = Nokogiri::XML::Builder.new do |xml|
          xml.feed("xmlns" => "http://www.w3.org/2005/Atom","xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:batch" => "http://schemas.google.com/gdata/batch", "xmlns:yt" => "http://gdata.youtube.com/schemas/2007") {
            xml["batch"].operation("type"=>"update")
            to_add.each do |song|
              xml.entry {
                xml["batch"].operation("type"=>"insert")
                xml.id_ song[:id]
              }
            end
          }
        end
        prepare_request(r, builder1).run
      end

      redirect_to root_path
  end

  private

  def prepare_request(r, builder)
    r.options[:headers]["Content-Length"] = builder.to_xml.length
    r.options[:body] = builder.to_xml
    return r
  end

  def add_xml_builder(arr)
  end

  def del_xml_builder(arr)
  end

end
