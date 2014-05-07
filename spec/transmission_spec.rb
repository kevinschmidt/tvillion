require 'tvillion/transmission'

describe TVillion::Transmission do

  context "submission" do
    before(:each) do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .to_return(:body => "", :status => 409, :headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
      @transmission_client = TVillion::Transmission::Client.new('localhost', '9091')
    end

    it "should parse the transmission add response and get a proper reference back" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/add_response.json", "r").read, :status => 200)
      response = @transmission_client.add_torrent("magnet:?xt=urn:btih:4759325bd4812b828cd2deac7e1cc135bcf6e02a")
      response.should eq(4)
    end

    it "should parse the transmission check response and return proper status"

    it "should parse the transmission remove response and verify" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/remove_response.json", "r").read, :status => 200)
      response = @transmission_client.remove_torrent("4")
      response.should eq(true)
    end
  end
end