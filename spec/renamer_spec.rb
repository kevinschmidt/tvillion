require 'tvillion/renamer'

describe TVillion::Renamer do
  class RenameTest
    include TVillion::Renamer
  end

  context "matching" do
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
      matchData = @renamer.matchName("Modern Family.S03E18.720p.HDTV.X264-DIMENSION.mkv")
      puts matchData
    end
  end
  
  context "normalizing" do
    before(:each) do
      @renamer = RenameTest.new
    end
    
    it "should rename just number name" do
      newName = @renamer.normalizeName("Daria - 406 - I Loathe A Parade.mpg")
      newName.should eq("Daria.S04E06.mpg")
    end
    
    it "should rename long name" do
      newName = @renamer.normalizeName("24 Season 1 Episode 10 - 9AM - 10AM.avi")
      newName.should eq("24.S01E10.avi")
    end
    
    it "should rename standard name" do
      newName = @renamer.normalizeName("Modern Family.S03E18.720p.HDTV.X264-DIMENSION.mkv")
      newName.should eq("Modern.Family.S03E18.720p.mkv")
    end
  end
end
