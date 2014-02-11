class MyCommand
  def cmd_show_focus
    p Tk.focus
  end

  def cmd_gotoup(tree)
    vpath = $ui.tree2addr[tree]
    old_path = vpath.value
    vpath.value = File.dirname(old_path)
    if old_path != vpath.value
      foldertab_reread(tree, vpath.value)
    end
  end

  def treeitem_sort_by(tree, col, direction)
    tree.children(nil).map!{|row| [tree.get(row, col), row.id]} .
      sort(&((direction)? proc{|x, y| y <=> x}: proc{|x, y| x <=> y})) .
      each_with_index{|info, idx| tree.move(info[1], nil, idx)}

    tree.heading_configure(col, :command=>proc{ treeitem_sort_by(tree, col, ! direction) })
  end

  def treeitem_open(tree)
    dirname = tree.get(tree.focus_item, 'name')
    vpath = $ui.tree2addr[tree]
    dir = File.join(vpath.value, dirname)
    p dir
    if File.directory?(dir)
      vpath.value = dir
      foldertab_reread(tree, vpath.value)
    end
  end

  def treeitem_select(tree)
    p tree.selection.map { |item| tree.get(item, 'name') }
  end

  def foldertab_new(nb, path)
    unless File.directory?(path)
      puts "#{path} not a directory!" if $DEBUG
      return
    end

    t1 = Ttk::Frame.new(nb) { |f1|
      vpath = TkVariable.new
      vpath.value = path

      pentry = Ttk::Entry.new(f1, :textvariable=>vpath, :state=>:readonly)
      tree = Ttk::Treeview.new(f1, :columns=>%w(name ext size date attr), :show=>:headings)
      vsb = tree.yscrollbar(Ttk::Scrollbar.new(f1))
      $ui.tree2addr[tree] = vpath

      Tk.grid(pentry,    :in=>f1, :sticky=>'nsew')
      Tk.grid(tree, vsb, :in=>f1, :sticky=>'nsew')
      f1.grid_columnconfigure(0, :weight=>1)
      f1.grid_rowconfigure(1, :weight=>1)

      # tree.bind('Double-Button', proc{ p [Time.now,self,self.class] } )
      # tree.bind('Return', proc{ p [Time.now,self,self.class] } )
      tree.bind('<TreeviewOpen>', '%W') { |w| $pg.treeitem_open(w) }
      tree.bind('<TreeviewSelect>', '%W') { |w| $pg.treeitem_select(w) }
      tree.bind('BackSpace', proc{ $pg.cmd_gotoup(tree) })  #FIXME: destory a widget, bind key auto release?
      # tree.font $cfg.font

      font = $cfg.font#Ttk::Style.lookup(tree[:style], :font)
      cols = %w(name ext size date attr)
      cols.zip(%w(Name Ext Size Date Attr)).each { |col, name|
        tree.heading_configure(col, :text=>name, :command=>proc{ $pg.treeitem_sort_by(tree, col, false) })
        # tree.column_configure(col, :width=>TkFont.measure(font, name))
      }
      tree.column_configure('ext',  :stretch=>0, :width=>TkFont.measure(font, 'w'*4))
      tree.column_configure('size', :stretch=>0, :width=>TkFont.measure(font, 'w'*12))
      tree.column_configure('date', :stretch=>0, :width=>TkFont.measure(font, 'w'*19))
      tree.column_configure('attr', :stretch=>0, :width=>TkFont.measure(font, 'w'*10))

      $pg.foldertab_reread(tree, path)
    }
    nb.add(t1, :text=>File.split(path)[1])

  end

  def foldertab_reread(tree, path)
    font = Ttk::Style.lookup(tree[:style], :font)
    cols = %w(name ext size date attr)

    file_infos = Dir.chdir(path) { v=Dir.glob('*', File::FNM_DOTMATCH);v.shift(2);v }
    file_infos.each do |name, ext, size, date, attr|
      tree.insert(nil, :end, :values=>[name, ext, size, date, attr])
      cols.zip([name, ext, size, date, attr]).each do |col, val|
        len = TkFont.measure(font, "#{val}  ")
        if tree.column_cget(col, :width) < len
          tree.column_configure(col, :width=>len)
        end
      end
    end

  end

end
