require 'tvillion/tvinfo'

describe TVillion::TvInfo do
  class TvInfoTest
    include TVillion::TvInfo
  end
  
  class ShowTest
    attr_accessor :name, :season, :episode, :runtime, :hd, :image_url, :last_show_date, :last_season, :last_episode, :next_show_date, :next_season, :next_episode
  end

  context "parsing" do
    before(:each) do
      @resp = double("resp")
      @http = double("http")
      @http.stub(:request_get).and_return(@resp)
      @tvinfo = TvInfoTest.new
    end
    
    it "should parse the search xml and get Futurama as a result" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read)
      @resp.should_receive(:body).once
      
      id = @tvinfo.get_show_id(@http, "Futurama")
      id.should eq("3628")
    end
    
    it "should parse the info xml and get detail info about Futurama" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      @resp.should_receive(:body).once
      
      show = ShowTest.new
      @tvinfo.get_show_info(@http, "3628", show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_futurama(show)
    end
    
    it "ask for futurama and get full show info" do
      net_http = double("net_http").as_null_object
      Net::HTTP.should_receive(:new).and_return(net_http)
      net_http.should_receive(:start).and_yield(@http)
    
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read, File.open("spec/data/futurama_show_info.xml", "r").read)
      @resp.should_receive(:body).twice
      
      show = ShowTest.new
      show.name = "Futurama"
      @tvinfo.generate_show(show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_futurama(show)
    end
    
    it "should parse the info xml and get detail info about True Blood" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "12662")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/trueblood_show_info_farseason.xml", "r").read)
      @resp.should_receive(:body).once
      
      show = ShowTest.new
      @tvinfo.get_show_info(@http, "12662", show, current_date=DateTime.parse("2012-08-27 13:41"))
      check_show_trueblood(show)
    end
    
    it "should parse the info xml and get detail info about Futurama with two episodes the same day" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_info_twosameday.xml", "r").read)
      @resp.should_receive(:body).once
      
      show = ShowTest.new
      @tvinfo.get_show_info(@http, "3628", show, current_date=DateTime.parse("2012-09-01 13:41"))
      check_show_futurama_twosameday(show)
    end
    
    def check_show_futurama(show)
      show.name.should eq("Futurama")
      show.last_show_date.should eq(DateTime.parse("2012-08-23 03:00 UTC"))
      show.last_season.should eq(7)
      show.last_episode.should eq(11)
      show.next_show_date.should eq(DateTime.parse("2012-08-30 03:00 UTC"))
      show.next_season.should eq(7)
      show.next_episode.should eq(12)
    end
    
    def check_show_futurama_twosameday(show)
      show.name.should eq("Futurama")
      show.last_show_date.should eq(DateTime.parse("2012-08-30 03:00 UTC"))
      show.last_season.should eq(7)
      show.last_episode.should eq(13)
      show.next_show_date.should be_nil
      show.next_season.should be_nil
      show.next_episode.should be_nil
    end
    
    def check_show_trueblood(show)
      show.name.should eq("True Blood")
      show.last_show_date.should eq(DateTime.parse("2012-08-27 02:00 UTC"))
      show.last_season.should eq(5)
      show.last_episode.should eq(12)
      show.next_show_date.should be_nil
      show.next_season.should be_nil
      show.next_episode.should be_nil
    end
  end
end
