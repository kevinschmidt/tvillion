module TVillion
  module Renamer
    STANDARD = Regexp.new('^(?<showname>.*)[ ._-][Ss](?<seasonnum>\d{1,2})[ ._-]?[Ee](?<episodenum>\d{1,2})[ ._-](?<episodename>.*)[.](?<fileend>\w{3,4})$')
    LONG_NAMES = Regexp.new('^(?<showname>.*)[Ss]eason[ .](?<seasonnum>[0-9]{1,2})[ .][Ee]pisode[ .](?<episodenum>\d{2})(?<episodename>.*)[.](?<fileend>\w{3,4})')
    JUST_NUMBERS = Regexp.new('^(?<showname>.*)(?<seasonnum>[0-9]{1,2})(?<episodenum>\d{2})(?<episodename>.*)[.](?<fileend>\w{3,4})$')
    REGEX_ARRAY = [STANDARD, LONG_NAMES, JUST_NUMBERS]
    
    def normalizeName(name)
      match_data = matchName(name)
    end
    
    def matchName(name)
      matchResults = REGEX_ARRAY.chunk {|regex| regex.match(name)}
      if matchResults.none?
        raise "unsupported file name"
      end
      matchData = matchResults.first[0]
      result = Hash[ matchData.names.zip(matchData.captures) ]
      
      is720p = false
      result.each do |key, value|
        mod_value = value.gsub(/\A[_\W]+|[_\W]+\Z/, '')
        is_number = true if Fixnum(mod_value) rescue false
        if ['seasonnum', 'episodenum'].include?(key)
          mod_value = mod_value.rjust(2, '0')
        end
        if key == 'episodename' && value.index(/720[pP]/)
          is720p = true
        end
        result[key] = mod_value
      end
      result['720p'] = is720p
      return result
    end
  end
end