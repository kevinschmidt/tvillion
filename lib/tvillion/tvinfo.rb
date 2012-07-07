require 'date'
require 'tvillion/show'
require 'net/http'
require 'rexml/document'
require "active_support/core_ext/numeric/time"

module TvInfo
  SEARCH_URL = "http://services.tvrage.com/feeds/search.php?show="
  INFO_URL = "http://services.tvrage.com/feeds/full_show_info.php?sid="
  
  def generate_show(title)
    id = get_show_id(title)
    return get_show_info(id)
  end
  
  def get_show_id(title)
    resp = get_response(URI.parse(URI.escape(SEARCH_URL + title)))
    doc = REXML::Document.new(resp.body)
    
    ids = []
    doc.elements.each('Results/show/showid') do |id|
      ids.push(id.text)
    end
    names = []
    doc.elements.each('Results/show/name') do |name|
      names.push(name.text)
    end
    
    id = nil
    names.each_with_index do |item, index|
      puts item
      if item == title
        return ids[index]
      end
    end
    
    raise "show not found: " + title
  end
  
  def get_show_info(id)
    resp = get_response(URI.parse(URI.escape(INFO_URL + id)))
    xml_elements = REXML::Document.new(resp.body).root.elements
    result = Show.new(xml_elements["name"].text)
    result.image_url = xml_elements["image"].text
    
    airtime = xml_elements["airtime"].text
    timezone = xml_elements["timezone"].text
    result.runtime = xml_elements["runtime"].text.to_i
    result.hd = true
    
    seasons_xml = xml_elements["Episodelist"].elements.to_a("//Season")
    print seasons_xml
    result.season = seasons_xml.last.attributes['no'].to_i
    seasons_xml.last.elements["episode"].each do |episode|
      next_show_date = DateTime.parse(episode.elements['airdate'].text + " " + airtime + " " + timezone) + (result.runtime.to_f / 24 / 60)
      if next_show_date > DateTime.now()
        result.next_show_date = next_show_date
        result.episode = episode.elements['seasonnum'].text.to_i - 1
        break
      end
    end
    
    result.last_updated = DateTime.now()
    return result
  end
  
  def get_response(uri)
    http_request = Net::HTTP.new(uri.host, uri.port)
    http_request.read_timeout = 500
    http_request.start do |http|
      return http.request_get(uri.request_uri)
    end
  end
end