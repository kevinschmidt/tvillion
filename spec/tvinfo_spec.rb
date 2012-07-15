require 'tvillion/tvinfo'
require 'tvillion/show'

describe TVillion::TvInfo do
  context "parsing" do
    before(:each) do
      @resp = double("resp")
      @http = double("http")
      @http.stub(:request_get).and_return(@resp)
    end
    
    it "should parse the search xml and get Futurama as a result" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read)
      @resp.should_receive(:body).once
      
      id = TVillion::TvInfo::get_show_id(@http, "Futurama")
      id.should eq("3628")
    end
    
    it "should parse the info xml and get detail info about Futurama" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      @resp.should_receive(:body).once
      
      show = TVillion::TvInfo::get_show_info(@http, "3628")
      check_show(show)
    end
    
    it "ask for futurama and get full show info" do
      net_http = double("net_http").as_null_object
      Net::HTTP.should_receive(:new).and_return(net_http)
      net_http.should_receive(:start).and_yield(@http)
    
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read, File.open("spec/data/futurama_show_info.xml", "r").read)
      @resp.should_receive(:body).twice
      
      show = TVillion::TvInfo::generate_show("Futurama")
      check_show(show)
    end
    
    def check_show(show)
      show.should be_instance_of(TVillion::Show)
      show.name.should eq("Futurama")
      show.season.should eq(7)
      show.episode.should eq(5)
    end
  end
end
