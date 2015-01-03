class Log
  def initialize(logoutput)
    @logoutput = logoutput
  end

  def debuglog(msg)
    if(@logoutput)
      #p msg
      puts msg
    end
  end

  def to_s
    p @logoutput
  end 
end
