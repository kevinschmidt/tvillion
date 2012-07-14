require 'tvillion/tvinfo'
require 'tvillion/show'

describe TvInfo do
  context "parsing" do
    before(:each) do
      @resp = double("resp")
      @http = double("http")
      @http.stub(:request_get).and_return(@resp)
    end
    
    it "should parse the search xml and get Futurama as a result" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TvInfo::SEARCH_URL + "Futurama")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_search.xml", "r").read)
      @resp.should_receive(:body).once
      
      id = TvInfo::get_show_id(@http, "Futurama")
      id.should eq("3628")
    end
    
    it "should parse the info xml and get detail info about Futurama" do
      @http.should_receive(:request_get).with(URI.parse(URI.escape(TvInfo::INFO_URL + "3628")).request_uri).once
      @resp.stub(:body).and_return(File.open("spec/data/futurama_show_info.xml", "r").read)
      @resp.should_receive(:body).once
      
      show = TvInfo::get_show_info(@http, "3628")
      show.should be_instance_of(Show)
      show.name.should eq("Futurama")
      show.season.should eq(7)
      show.episode.should eq(5)
    end
  end
end
