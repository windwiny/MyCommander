class MyCommand 
  def show_full
    
  end
  
  def show_reread
    $paneList.value = Dir.glob( '/*') +[ Time.now.to_s]
  end
end
