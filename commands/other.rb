class MyCommand

  def aff *args
    p 'in aff'
    p args

  end

  def cmd_gotoup
    p 'goto up'
    
  end

  ## Code to do the sorting of the tree contents when clicked on
  def sort_by(tree, col, direction)
    tree.children(nil).map!{|row| [tree.get(row, col), row.id]} .
      sort(&((direction)? proc{|x, y| y <=> x}: proc{|x, y| x <=> y})) .
      each_with_index{|info, idx| tree.move(info[1], nil, idx)}

    tree.heading_configure(col, :command=>proc{sort_by(tree, col, ! direction)})
  end
  
  def itemopen(tree)
    p tree.selection.map { |x| x.value[0] }
  end
  
  def itemselect(tree)
    p tree.selection.map { |x| x.value[0] }
  end
  
  def cmd_show_focus
    p Tk.focus
  end
  
  def add_foldertab(nb, path)
    unless File.directory?(path)
      puts "#{path} not a directory!" if $DEBUG
      return
    end

    file_infos = Dir.chdir(path) { v=Dir.glob('*', File::FNM_DOTMATCH);v.shift(2);v }

    t1 = Ttk::Frame.new(nb) { |f1|
      vpath = TkVariable.new
      vpath.value = path
      pentry = Ttk::Entry.new(f1, :textvariable=>vpath)

      tree = Ttk::Treeview.new(f1, :columns=>%w(name ext size date attr), :show=>:headings)
      vsb = tree.yscrollbar(Ttk::Scrollbar.new(f1))

      # tree.bind('Double-Button', proc{ p [Time.now,self,self.class] } )
      # tree.bind('Return', proc{ p [Time.now,self,self.class] } )
      tree.bind('<TreeviewOpen>', '%W') { |w| $pg.itemopen(w) }
      tree.bind('<TreeviewSelect>', '%W') { |w| $pg.itemselect(w) }
      tree.bind('BackSpace', proc{ $pg.cmd_gotoup })  #FIXME: destory a widget, bind key auto release?

      Tk.grid(pentry,    :in=>f1, :sticky=>'nsew')
      Tk.grid(tree, vsb, :in=>f1, :sticky=>'nsew')

      f1.grid_columnconfigure(0, :weight=>1)
      f1.grid_rowconfigure(1, :weight=>1)

      font = Ttk::Style.lookup(tree[:style], :font)
      cols = %w(name ext size date attr)
      cols.zip(%w(Name Ext Size Date Attr)).each { |col, name|
        tree.heading_configure(col, :text=>name, :command=>proc{ $pg.sort_by(tree, col, false) })
        tree.column_configure(col, :width=>TkFont.measure(font, name))
      }

      file_infos.each do |name, ext, size, date, attr|
        tree.insert(nil, :end, :values=>[name, ext, size, date, attr])
        cols.zip([name, ext, size, date, attr]).each do |col, val|
          len = TkFont.measure(font, "#{val}  ")
          if tree.column_cget(col, :width) < len
            tree.column_configure(col, :width=>len)
          end
        end
      end
    }
    nb.add(t1, :text=>File.split(path)[1])

  end #def add_foldertab

end
