require 'tvillion/tvinfo'

describe TVillion::TvInfo do
  class TvInfoTest
    include TVillion::TvInfo
  end
  
  class ShowTest
    attr_accessor :name, :season, :episode, :tvrage_id, :runtime, :hd, :image_url, :last_show_date, :last_season, :last_episode, :next_show_date, :next_season, :next_episode
  end

  context "parsing" do
    before(:each) do
      @resp = double("resp")
      @http = double("http")
      allow(@http).to receive(:request_get).and_return(@resp)
      @tvinfo = TvInfoTest.new
    end
    
    it "should parse the search xml and get Futurama as a result" do
      net_http = double("net_http").as_null_object
      expect(Net::HTTP).to receive(:new).and_return(net_http)
      expect(net_http).to receive(:start).and_yield(@http)
      
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      id = @tvinfo.search_show("Futurama")
      expect(id).to eq(3628 => "Futurama")
    end
    
    it "should parse the info xml and get detail info about Futurama" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.tvrage_id = 3628
      @tvinfo.get_show_info(@http, show.tvrage_id, show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_futurama(show)
    end
    
    it "ask for futurama and get full show info" do
      net_http = double("net_http").as_null_object
      allow(Net::HTTP).to receive(:new).and_return(net_http)
      allow(net_http).to receive(:start).and_yield(@http)
      
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.tvrage_id = 3628
      show.name = "Futurama"
      @tvinfo.generate_show(show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_futurama(show)
    end
    
    it "should parse the info xml and get detail info about True Blood" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "12662")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/trueblood_show_info_farseason.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.tvrage_id = 12662
      @tvinfo.get_show_info(@http, show.tvrage_id, show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_trueblood(show)
    end
    
    it "should parse the info xml and get detail info about Futurama with two episodes the same day" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_info_twosameday.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.tvrage_id = 3628
      @tvinfo.get_show_info(@http, show.tvrage_id, show, current_date=DateTime.parse("2012-09-01 13:41"))
      check_show_futurama_twosameday(show)
    end
    
    it "should parse the info xml and get normal next episode for Futurama" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "Futurama"
      show.tvrage_id = 3628
      show.season = 6
      show.episode = 17
      @tvinfo.find_next_episode(@http, show.tvrage_id, show)
      
      expect(show.name).to eq("Futurama")
      expect(show.tvrage_id).to eq(3628)
      expect(show.season).to eq(6)
      expect(show.episode).to eq(18)
    end
    
    it "should parse the info xml and get next season episode for Futurama" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "Futurama"
      show.tvrage_id = 3628
      show.season = 6
      show.episode = 26
      @tvinfo.find_next_episode(@http, show.tvrage_id, show)
      
      expect(show.name).to eq("Futurama")
      expect(show.tvrage_id).to eq(3628)
      expect(show.season).to eq(7)
      expect(show.episode).to eq(1)
    end
    
    it "should parse the info xml and get next unaired season episode for True Blood" do
      expect(@http).to receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "12662")).request_uri).once
      allow(@resp).to receive(:body).and_return(File.open("spec/data/trueblood_show_info_farseason.xml", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "True Blood"
      show.tvrage_id = 12662
      show.season = 5
      show.episode = 12
      @tvinfo.find_next_episode(@http, show.tvrage_id, show)
      
      expect(show.name).to eq("True Blood")
      expect(show.tvrage_id).to eq(12662)
      expect(show.season).to eq(6)
      expect(show.episode).to eq(1)
    end
    
    def check_show_futurama(show)
      expect(show.name).to eq("Futurama")
      expect(show.tvrage_id).to eq(3628)
      expect(show.last_show_date).to eq(DateTime.parse("2012-08-23 03:00 UTC"))
      expect(show.last_season).to eq(7)
      expect(show.last_episode).to eq(11)
      expect(show.next_show_date).to eq(DateTime.parse("2012-08-30 03:00 UTC"))
      expect(show.next_season).to eq(7)
      expect(show.next_episode).to eq(12)
    end
    
    def check_show_futurama_twosameday(show)
      expect(show.name).to eq("Futurama")
      expect(show.tvrage_id).to eq(3628)
      expect(show.last_show_date).to eq(DateTime.parse("2012-08-30 03:00 UTC"))
      expect(show.last_season).to eq(7)
      expect(show.last_episode).to eq(13)
      expect(show.next_show_date).to be_nil
      expect(show.next_season).to be_nil
      expect(show.next_episode).to be_nil
    end
    
    def check_show_trueblood(show)
      expect(show.name).to eq("True Blood")
      expect(show.tvrage_id).to eq(12662)
      expect(show.last_show_date).to eq(DateTime.parse("2012-08-27 02:00 UTC"))
      expect(show.last_season).to eq(5)
      expect(show.last_episode).to eq(12)
      expect(show.next_show_date).to be_nil
      expect(show.next_season).to be_nil
      expect(show.next_episode).to be_nil
    end
  end
end
