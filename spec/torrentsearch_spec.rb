require 'tvillion/torrentsearch'

describe TVillion::TorrentSearch do
  class TorrentSearchTest
    include TVillion::TorrentSearch
  end

  context "parsing" do
    before(:each) do
      @resp = double("resp")
      Net::HTTP.stub(:get_response).and_return(@resp)
      @torrent_search = TorrentSearchTest.new
    end

    it "should parse thorrents search json and get a proper torrent url as a result" do
      Net::HTTP.should_receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::THORRENTS_URL % "Futurama 720p S07E04"))).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_torrent_search_thorrents.json", "r").read)
      @resp.should_receive(:body).once

      url = @torrent_search.search_thorrents("Futurama 720p S07E04")
      url.should eq("magnet:?xt=urn:btih:f647750b368f950f86ded488ac3160e3f5e30101&dn=Futurama+S07E26+720p+HDTV+x264-EVOLVE+%5Beztv%5D&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337")
    end

    it "should parse fenopy search json and get a proper torrent url as a result" do
      Net::HTTP.should_receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::FENOPY_URL % "NCIS 720p S11E11"))).once
      @resp.stub(:body).and_return(File.open("spec/data/ncis_torrent_search_fenopy.json", "r").read)
      @resp.should_receive(:body).once

      url = @torrent_search.search_fenopy("NCIS 720p S11E11")
      url.should eq("magnet:?xt=urn:btih:1446cee021f624870d61117dc00269fffe8a81ce&dn=NCIS+S11E11+720p+HDTV+X264+DIMENSION+PublicHD")
    end
  end
end