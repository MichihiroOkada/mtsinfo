class History
  def initialize(history_path)
    @history_path = history_path
    @history = Hash.new
  end

  def set_path(path)
    @history[:path] = path
  end

  def get_path
    if @history.has_key?(:path)
      return @history[:path] + "/"
    else
      return nil
    end
  end

  def load
    @history = eval File.read(@history_path) if File.file?(@history_path)
  end

  def save
    File.write(@history_path, @history) 
  end

  def to_s
    p @history
  end 

end
