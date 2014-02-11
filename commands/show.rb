class MyCommand 
  def show_full
    
  end
  
  def show_reread
    # $paneList ||= TkVariable.new
    begin
      $paneList.value = Dir.glob( '/*') +[ Time.now.to_s]
    rescue 
    end
  end
end
