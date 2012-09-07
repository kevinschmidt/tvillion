require 'tvillion/renamer'

describe TVillion::Renamer do
  class RenameTest
    include TVillion::Renamer
  end

  context "renaming" do
    before(:each) do
      @renamer = RenameTest.new
    end
    
    it "should parse standard name" do
      matchData = @renamer.matchName("Daria - 406 - I Loathe A Parade.mpg")
      puts matchData
    end
  end
end
