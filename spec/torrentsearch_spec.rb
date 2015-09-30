require 'tvillion/torrentsearch'

describe TVillion::TorrentSearch do
  class TorrentSearchTest
    include TVillion::TorrentSearch
  end

  context "parsing" do
    before(:each) do
      @resp = double("resp")
      @http = double("net_http").as_null_object
      allow(Net::HTTP).to receive(:get_response).and_return(@resp)
      allow(Net::HTTP).to receive(:new).and_return(@http)
      allow(@http).to receive(:get).and_return(@resp)
      @torrent_search = TorrentSearchTest.new
    end

    it "should parse thorrents search json and get a proper torrent url as a result" do
      expect(Net::HTTP).to receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::THORRENTS_URL % "Futurama 720p S07E04"))).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_torrent_search_thorrents.json", "r").read)
      expect(@resp).to receive(:body).once

      url = @torrent_search.search_thorrents("Futurama 720p S07E04")
      expect(url).to eq("magnet:?xt=urn:btih:f647750b368f950f86ded488ac3160e3f5e30101&dn=Futurama+S07E26+720p+HDTV+x264-EVOLVE+%5Beztv%5D&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337")
    end

    it "should parse fenopy search json and get a proper torrent url as a result" do
      expect(Net::HTTP).to receive(:get_response).with(URI.parse(URI.escape(TVillion::TorrentSearch::FENOPY_URL % "NCIS 720p S11E11"))).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/ncis_torrent_search_fenopy.json", "r").read)
      expect(@resp).to receive(:body).once

      url = @torrent_search.search_fenopy("NCIS 720p S11E11")
      expect(url).to eq("magnet:?xt=urn:btih:1446cee021f624870d61117dc00269fffe8a81ce&dn=NCIS+S11E11+720p+HDTV+X264+DIMENSION+PublicHD")
    end

    it "should parse kickass search rss and get a proper torrent url as a result" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TorrentSearch::KICKASS_URL % "Modern Family 720p S05E23")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(File.open("spec/data/modern_family_torrent_search_kickass.xml", "r").read)
      expect(@resp).to receive(:body).once

      url = @torrent_search.search_kickass("Modern Family 720p S05E23")
      expect(url).to eq("magnet:?xt=urn:btih:1F05AEEEF758F429C9DD0384191FE3CEC38BD49D&dn=modern+family+s05e23+720p+web+dl+2ch+x264+psa&tr=udp%3A%2F%2Ftracker.secureboxes.net%3A80%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337")
    end
  end
end