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
      @http = double("net_http").as_null_object
      allow(Net::HTTP).to receive(:new).and_return(@http)
      allow(@http).to receive(:get).and_return(@resp)
      @tvinfo = TvInfoTest.new
    end
    
    it "should parse the search result and get several shows as a result" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TvInfo::SEARCH_URL % "shield")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(File.open("spec/data/shield_show_search.json", "r").read)
      expect(@resp).to receive(:body).once
      
      ids = @tvinfo.search_show("shield")
      expect(ids).to eq({
        1173 => "Child Genius",
        1439 => "The field of blood",
        1935 => "Ghost in the Shell: Stand Alone Complex",
        2164 => "Love Child",
        2281 => "The Crimson Field",
        2570 => "Man vs. Child: Chef Showdown",
        31 => "Marvel's Agents of S.H.I.E.L.D",
        3445 => "Max & Shred",
        4615 => "Supervet in the Field",
        663 => "The Shield"
      })
    end
   
    it "should parse the show info json and get detail info about Shield" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TvInfo::INFO_URL % "31")).request_uri).once
      expect(@http).to receive(:get).with(URI.parse(URI.escape("http://api.tvmaze.com/episodes/153398")).request_uri).once
      expect(@http).to receive(:get).with(URI.parse(URI.escape("http://api.tvmaze.com/episodes/167570")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(
        File.open("spec/data/shield_show_info_main.json", "r").read,
        File.open("spec/data/shield_show_info_previous.json", "r").read,
        File.open("spec/data/shield_show_info_next.json", "r").read
      )
      expect(@resp).to receive(:body).exactly(3).times
      
      show = ShowTest.new
      show.tvrage_id = 31
      @tvinfo.generate_show(show)
      check_show_shield(show)
    end

    it "should parse the episodes json and get normal next episode for Shield" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TvInfo::EPISODE_URL % "31")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(File.open("spec/data/shield_show_episodes.json", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "Marvel's Agents of S.H.I.E.L.D"
      show.tvrage_id = 31
      show.season = 2
      show.episode = 17
      @tvinfo.get_next_episode(show)
      
      expect(show.name).to eq("Marvel's Agents of S.H.I.E.L.D")
      expect(show.tvrage_id).to eq(31)
      expect(show.season).to eq(2)
      expect(show.episode).to eq(18)
    end
    
    it "should parse the episodes json and get next season episode for Shield" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TvInfo::EPISODE_URL % "31")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(File.open("spec/data/shield_show_episodes.json", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "Marvel's Agents of S.H.I.E.L.D"
      show.tvrage_id = 31
      show.season = 2
      show.episode = 22
      @tvinfo.get_next_episode(show)
      
      expect(show.name).to eq("Marvel's Agents of S.H.I.E.L.D")
      expect(show.tvrage_id).to eq(31)
      expect(show.season).to eq(3)
      expect(show.episode).to eq(1)
    end
    
    it "should parse the episodes json and no new episode for Shield" do
      expect(@http).to receive(:get).with(URI.parse(URI.escape(TVillion::TvInfo::EPISODE_URL % "31")).request_uri).once
      allow(@resp).to receive(:code).and_return("200")
      allow(@resp).to receive(:body).and_return(File.open("spec/data/shield_show_episodes.json", "r").read)
      expect(@resp).to receive(:body).once
      
      show = ShowTest.new
      show.name = "Marvel's Agents of S.H.I.E.L.D"
      show.tvrage_id = 31
      show.season = 3
      show.episode = 3
      @tvinfo.get_next_episode(show)
      
      expect(show.name).to eq("Marvel's Agents of S.H.I.E.L.D")
      expect(show.tvrage_id).to eq(31)
      expect(show.season).to eq(nil)
      expect(show.episode).to eq(nil)
    end

    def check_show_shield(show)
      expect(show.name).to eq("Marvel's Agents of S.H.I.E.L.D")
      expect(show.tvrage_id).to eq(31)
      expect(show.last_show_date).to eq(DateTime.parse("2015-05-12T22:00:00-04:00"))
      expect(show.last_season).to eq(2)
      expect(show.last_episode).to eq(22)
      expect(show.next_show_date).to eq(DateTime.parse("2015-09-29T21:00:00-04:00"))
      expect(show.next_season).to eq(3)
      expect(show.next_episode).to eq(1)
    end
  end
end
