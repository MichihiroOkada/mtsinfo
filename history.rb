class History
  def initialize(history_path)
    @history_path = history_path
    @history = Hash.new
  end

  def set_path(path)
    @history[ :path ] = path
  end

  def get_path
    return @history[ :path ] + "/"
  end

  def load
    @history = eval File.read(@history_path)
  end

  def save
    File.write(@history_path, @history) 
  end

  def to_s
    p @history
  end 

end
