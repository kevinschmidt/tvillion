require 'json'
require 'net/http'

module TVillion
  module Transmission
    class StatusResponse
      attr_accessor :id, :status, :isFinished, :percentDone

      def initialize(id, status, isFinished, percentDone)
        @id = id
        @status = status
        @isFinished = isFinished
        @percentDone = percentDone
      end

      def ==(other)
        return self.id == other.id &&
          self.status == other.status &&
          self.isFinished == other.isFinished &&
          self.percentDone == other.percentDone
      end
    end

    class Client
      def initialize(host='localhost', port=9091, username=nil, password=nil)
        @uri = URI.parse("http://#{host}:#{port}/transmission/rpc")
        if username
          @header = {'authorization' => [username, password]}
        else
          @header = {}
        end
      end
      
      def add_torrent(url, download_dir = nil)
        arguments = { "filename" => url }
        if download_dir
          arguments["download-dir"] = download_dir
        end
        payload = build_request("torrent-add", arguments)
        puts "trying torrent add request with payload " + payload
        response = send_request(payload)
        puts "response for torrent add request is " + response.body
        parse_add_response(response.body)
      end

      def check_torrent(id)
        arguments = { "id" => id }
        payload = build_request("torrent-check", arguments)
        puts "trying torrent check request with payload " + payload
        response = send_request(payload)
        puts "response for torrent check request is " + response.body
        parse_check_response(response.body, id)
      end

      def remove_torrent(id)
        arguments = { "id" => id }
        payload = build_request("torrent-remove", arguments)
        puts "trying torrent check request with payload " + payload
        response = send_request(payload)
        puts "response for torrent remove request is " + response.body
        parse_remove_response(response.body)
      end
  
      private
        def build_request(method, arguments = {})
          if arguments.empty?
            return {'method' => method}.to_json
          else
            return {'method' => method, 'arguments' => arguments }.to_json
          end
        end

        def send_request(payload)
          request = Net::HTTP::Post.new(@uri.request_uri, {'Content-Type' =>'application/json'})
          request.body = payload
          Net::HTTP.new(@uri.hostname, @uri.port).start do |http|
            begin
              response = http.request(request)
            rescue Timeout::Error
              raise "timeout error occurred on request"
            end
            if response.is_a?(Net::HTTPConflict)
              session_id = response['x-transmission-session-id']
            else
              raise "did not get 409 on first request"
            end
            request['x-transmission-session-id'] = session_id
            response = http.request(request)
            if response.is_a?(Net::HTTPSuccess)
              return response
            else
              raise "did not get 200 on second request"
            end
          end
        end

        def parse_add_response(body)
          result = JSON.parse(body)
          if result['result'] == 'success'
            return result['arguments']['torrent-added']['id']
          else
            raise "bad response for add"
          end
        end

        def parse_check_response(body, id)
          result = JSON.parse(body)
          if result['result'] == 'success'
            torrents = result['arguments']['torrents']
            torrents.each do |torrent|
              if torrent['id'] == id
                return StatusResponse.new(id, torrent['status'], torrent['isFinished'], torrent['percentDone'])
              end
            end
            StatusResponse.new(-1, -1, false, 0.0)
          else
            raise "bad response for check"
          end
        end

        def parse_remove_response(body)
          result = JSON.parse(body)
          if result['result'] != 'success'
            raise "bad response for remove"
          end
          true
        end
    end
  end
end