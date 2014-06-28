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
      expect(response).to eq(4)
    end

    it "should parse the transmission remove response and verify" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/remove_response.json", "r").read, :status => 200)
      response = @transmission_client.remove_torrent(4)
      expect(response).to eq(true)
    end

    it "should parse the transmission check response and return status stopped" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/get_response_1.json", "r").read, :status => 200)
      response = @transmission_client.check_torrent(2)
      expect(response).to eq(TVillion::Transmission::StatusResponse.new(2, TVillion::Transmission::StatusCode::STOPPED, 0))
    end

    it "should parse the transmission check response and return status download" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/get_response_1.json", "r").read, :status => 200)
      response = @transmission_client.check_torrent(4)
      expect(response).to eq(TVillion::Transmission::StatusResponse.new(4, TVillion::Transmission::StatusCode::DOWNLOADING, 0.034))
    end

    it "should parse the transmission check response and return status waiting" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/get_response_2.json", "r").read, :status => 200)
      response = @transmission_client.check_torrent(2)
      expect(response).to eq(TVillion::Transmission::StatusResponse.new(2, TVillion::Transmission::StatusCode::DOWNLOADING, 0.0))
    end

    it "should parse the transmission check response and return status done" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/get_response_3.json", "r").read, :status => 200)
      response = @transmission_client.check_torrent(3)
      expect(response).to eq(TVillion::Transmission::StatusResponse.new(3, TVillion::Transmission::StatusCode::DONE, 1))
    end

    it "should parse the transmission check response and return status seeding" do
      stub_request(:post, "http://localhost:9091/transmission/rpc")
        .with(:headers => { 'x-transmission-session-id' => "tyfhsldlsafa7888" })
        .to_return(:body => File.open("spec/data/transmission/get_response_3.json", "r").read, :status => 200)
      response = @transmission_client.check_torrent(4)
      expect(response).to eq(TVillion::Transmission::StatusResponse.new(4, TVillion::Transmission::StatusCode::SEEDING, 1))
    end
  end
end