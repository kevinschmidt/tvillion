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

    it "should parse the search json and get a proper torrent url as a result" do
      Net::HTTP.should_receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::THORRENTS_URL % "Futurama 720p S07E04"))).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_torrent_search.json", "r").read)
      @resp.should_receive(:body).once

      url = @torrent_search.get_search_results("Futurama 720p S07E04")
      url.should eq("magnet:?xt=urn:btih:f647750b368f950f86ded488ac3160e3f5e30101&dn=Futurama+S07E26+720p+HDTV+x264-EVOLVE+%5Beztv%5D&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337")
    end
  end
end