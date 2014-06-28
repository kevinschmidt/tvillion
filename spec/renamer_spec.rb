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
    
    it "should parse x number name" do
      matchData = @renamer.matchName("Gilmore Girls [3x06] - Take the Deviled Eggs....avi")
      puts matchData
    end
    
    it "should parse standard name" do
      matchData = @renamer.matchName("Modern Family.S03E18.720p.HDTV.X264-DIMENSION.mkv")
      puts matchData
    end
    
    it "should parse standard name, complicated" do
      matchData = @renamer.matchName("gilmore.girls.s02e05.avi")
      puts matchData
    end
  end
  
  context "normalizing" do
    before(:each) do
      @renamer = RenameTest.new
    end
    
    it "should rename just number name" do
      newName = @renamer.normalizeName("Daria - 406 - I Loathe A Parade.mpg")
      expect(newName).to eq("Daria.S04E06.mpg")
    end
    
    it "should rename long name" do
      newName = @renamer.normalizeName("24 Season 1 Episode 10 - 9AM - 10AM.avi")
      expect(newName).to eq("24.S01E10.avi")
    end
    
    it "should rename x number name" do
      newName = @renamer.normalizeName("Gilmore Girls [3x06] - Take the Deviled Eggs....avi")
      expect(newName).to eq("Gilmore.Girls.S03E06.avi")
    end
    
    it "should rename standard name" do
      newName = @renamer.normalizeName("Modern Family.S03E18.720p.HDTV.X264-DIMENSION.mkv")
      expect(newName).to eq("Modern.Family.S03E18.720p.mkv")
    end
    
    it "should rename standard name, second version" do
      newName = @renamer.normalizeName("Daria.S01E11.Road Worrier.avi")
      expect(newName).to eq("Daria.S01E11.avi")
    end
    
    it "should rename standard name, uppercase" do
      newName = @renamer.normalizeName("DARIA.S01E11.ROAD_WORRIER.avi")
      expect(newName).to eq("Daria.S01E11.avi")
    end
    
    it "should rename standard name, complicated" do
      newName = @renamer.normalizeName("gilmore.girls.s02e05.avi")
      expect(newName).to eq("Gilmore.Girls.S02E05.avi")
    end
  end
  
  context "renaming" do
    before(:each) do
      @renamer = RenameTest.new
    end
    
    after(:each) do
      FileUtils.remove_dir('spec/data/renamer_target')
    end
    
    it "should rename all filenames" do
      @renamer.processFolder('spec/data/renamer', 'spec/data/renamer_target')
      result = Dir.foreach('spec/data/renamer_target').to_a
      expect(result.size()).to eq(5)
      expect(result[2]).to eq('24.S01E14.avi')
      expect(result[3]).to eq('Daria.S04E06.mpg')
      expect(result[4]).to eq('The.Cleveland.Show.S03E22.720p.mkv')
    end
  end
end
