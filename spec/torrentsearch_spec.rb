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

    it "should parse the search xml and get a proper torrent url as a result" do
      Net::HTTP.should_receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::SEARCH_ENGINE_URLS[0] + "Futurama 720p S07E04"))).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_torrent_search.xml", "r").read)
      @resp.should_receive(:body).once

      url = @torrent_search.get_search_results("Futurama 720p S07E04")
      url.should eq("http://ca.isohunt.com/download/398893185/Futurama+720p+S07E04.torrent")
    end
  end
end