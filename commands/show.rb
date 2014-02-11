class MyCommand 
  def show_full
    
  end

  def show_reread
    tree = Tk.focus
    vpath = $ui.tree2addr[tree]
    foldertab_reread(tree, vpath.value) if vpath
  end
end
