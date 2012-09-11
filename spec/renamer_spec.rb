require 'tvillion/renamer'

describe TVillion::Renamer do
  class RenameTest
    include TVillion::Renamer
  end

  context "renaming" do
    before(:each) do
      @renamer = RenameTest.new
    end
    
    it "should parse just number name" do
      matchData = @renamer.matchName("Daria - 406 - I Loathe A Parade.mpg")
      puts matchData
    end
    
    it "should parse long name" do
      matchData = @renamer.matchName("24 Season 1 Episode 10 - 9AM - 10AM.avi")
      puts matchData
    end
    
    it "should parse standard name" do
      matchData = @renamer.matchName("Futurama.S07E01.720p.HDTV.x264-IMMERSE.mkv")
      puts matchData
    end
  end
end
