require 'fileutils'

module TVillion
  module Renamer
    STANDARD = Regexp.new('^(?<showname>.*)[ ._-][Ss](?<seasonnum>\d{1,2})[ ._-]?[Ee](?<episodenum>\d{1,2})[ ._-]?(?<episodename>.*)[.](?<fileend>\w{3,4})$')
    LONG_NAMES = Regexp.new('^(?<showname>.*)[Ss]eason[ .](?<seasonnum>[0-9]{1,2})[ .][Ee]pisode[ .](?<episodenum>\d{2})(?<episodename>.*)[.](?<fileend>\w{3,4})')
    JUST_NUMBERS = Regexp.new('^(?<showname>.*)(?<seasonnum>[0-9]{1,2})[xX]?(?<episodenum>\d{2})(?<episodename>.*)[.](?<fileend>\w{3,4})$')
    REGEX_ARRAY = [STANDARD, LONG_NAMES, JUST_NUMBERS]
    OUTPUT_FORMAT_SD = '%{showname}.S%{seasonnum}E%{episodenum}.%{fileend}'
    OUTPUT_FORMAT_HD = '%{showname}.S%{seasonnum}E%{episodenum}.720p.%{fileend}'
    
    
    def normalizeName(name, show_name=nil)
      match_data = matchName(name)
      symbolized_data = match_data.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      if symbolized_data[:is720p]
        return OUTPUT_FORMAT_HD % symbolized_data
      else
        return OUTPUT_FORMAT_SD % symbolized_data
      end
    end
    
    def matchName(name, show_name=nil)
      matchResults = REGEX_ARRAY.chunk {|regex| regex.match(name)}
      if matchResults.none?
        raise "unsupported file name: " + name
      end
      matchData = matchResults.first[0]
      result = Hash[ matchData.names.zip(matchData.captures) ]
      
      is720p = false
      result.each do |key, value|
        mod_value = value.gsub(/\A[_\W]+|[_\W]+\Z/, '').gsub(/[._]/, ' ').squeeze(' ').titleize().gsub(/ /, '.') 
        is_number = true if Fixnum(mod_value) rescue false
        if ['seasonnum', 'episodenum'].include?(key)
          mod_value = mod_value.rjust(2, '0')
        end
        if key == 'episodename' && value.index(/720[pP]/)
          is720p = true
        end
        if key == 'fileend'
          mod_value.downcase!()
        end
        if key == 'showname' && show_name
          mod_value = show_name
        end
        result[key] = mod_value
      end
      result['is720p'] = is720p
      return result
    end
    
    
    def processFolder(source_folder, target_folder, show_name=nil)
      FileUtils.mkdir_p(target_folder)
      Dir.glob(source_folder+"/*.{avi,AVI,mpg,MPG,mp4,MP4,mkv,MKV}") do |filename|
        filename.slice!(0..filename.rindex('/'))
        new_file = target_folder+"/"+normalizeName(filename, show_name)
        FileUtils.cp(source_folder+"/"+filename, new_file)
        puts "Copied #{filename} to #{new_file}"
      end
    end
  end
end
