require 'find'

load 'log.rb'

# read config file
config = eval File.read 'config.rb'
$log = Log.new(config[ :logoutput ])

READ_SIZE = 500

class MtsParser
  def initialize
  end

  def parse(path)
    open(path, "rb") do |file|
      read_size = 0
      datetime_tag = false
      while(data = file.read(READ_SIZE)) 
        mdpm_index = /MDPM/ =~ data
        if(mdpm_index)
          read_size = read_size + mdpm_index
          file.seek(read_size, IO::SEEK_SET)
          break
        else
          file.seek(-4, IO::SEEK_CUR)
          read_size = read_size + READ_SIZE - 4
        end
      end
    
      mdpm_data = file.read(20)
      datetag_index_top = mdpm_data.index("\x18")
      datetime = sprintf("%02x%02x-%02x-%02x %02x:%02x:%02x",
              mdpm_data[datetag_index_top+2].unpack("C*").join,
              mdpm_data[datetag_index_top+3].unpack("C*").join,
              mdpm_data[datetag_index_top+4].unpack("C*").join,
              mdpm_data[datetag_index_top+6].unpack("C*").join,
              mdpm_data[datetag_index_top+7].unpack("C*").join,
              mdpm_data[datetag_index_top+8].unpack("C*").join,
              mdpm_data[datetag_index_top+9].unpack("C*").join)

      if(datetime)
        # success 
        filelist = Filelist.new
        filelist.path = path
        filelist.datetime = datetime
        $log.debuglog("[MTSPARSE] datetime = " + datetime)
        return filelist
      else
        return nil
      end
    end
  end  
end

class Filelist
  attr_accessor :path
  attr_accessor :datetime
  def initialize
    @path = String.new
    @datetime = String.new
  end

  def to_s
    puts "#{@path} = #{@datetime}"
  end
end

class MtsInfo
  attr_accessor :mtsinfolist

  def initialize
    @parser = MtsParser.new
    @mtsinfolist = Array.new
  end

  def get_mtsinfo(topdir, baseDirOutput)
    @baseDirOutput = baseDirOutput
    directory_traverse(topdir)
  end

  def directory_traverse(topdir)
    Find.find(topdir) do |dir|
      $log.debuglog("[MTSPARSE] dir = " + dir)
      if File.extname(dir) == ".MTS"
        filelist = @parser.parse(dir)
        unless @baseDirOutput
          filelist.path = filelist.path.sub(topdir, "")
        end
        @mtsinfolist.push(filelist)
      end
    end
  end

  def to_s
    @mtsinfolist.each do |mtsinfo|
      puts mtsinfo
    end
  end
end



