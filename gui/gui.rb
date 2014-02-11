class MyCommand
  def init_gui
    create_gui
    setkeys
    create_menu
  end

  def load_notebook
    paths_l = $cfg.config.xpath('/MyCommand/Notebook_l').map(&:text)
    paths_r = $cfg.config.xpath('/MyCommand/Notebook_r').map(&:text)
    paths_l << Dir.home if paths_l.empty?
    paths_r << Dir.home if paths_r.empty?
    
    [paths_l, $ui.notebook_l, paths_r, $ui.notebook_r].each_slice(2) do |paths, nb|
      paths.each do |path|
        next unless File.directory?(path)
        file_infos = TkVariable.new
        file_infos.value = Dir.chdir(path) { v=Dir.glob('*', File::FNM_DOTMATCH);v.shift(2);v }
        p file_infos
        t1 = Ttk::Frame.new(nb) { |f1|
          Ttk::Entry.new(f1).pack(:fill=>:x, :expand=>:no, :side=>:top)
          TkListbox.new(f1, :listvariable=>file_infos) {
            # itemconfigure(0, :background=>self.cget(:foreground),
            #                  :foreground=>self.cget(:background) )
            yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
            pack(:fill=>:both, :expand=>:yes, :side=>:top)
          }
        }
        nb.add(t1, :text=>File.split(path)[1])
      end
    end
  end

  private
  def create_gui
    @panel_infos_left = []
    @panel_infos_right = []

    $ui.root = TkRoot.new do |root|
      $ui.main_frame = Ttk::Frame.new(root) do |main_frame|
        # Ttk::Frame.new(main_frame) do |frame|
        #   xscr = Ttk::Scrollbar.new(frame, :orient=>"horizontal")
        #   yscr = Ttk::Scrollbar.new(frame, :orient=>"vertical")
        #   tx = Tk::Text.new() { |t|
        #     t.font $cfg.font
        #     t.value = ''
        #     t.wrap 'none'
        #     t.width 10
        #     t.height 4
        #     t.xscrollbar xscr
        #     t.yscrollbar yscr
        #   }
        #   Tk.grid(tx, yscr, :in=>frame, :sticky=>:nswe)
        #   Tk.grid(xscr, :in=>frame, :sticky=>:nswe)
        #   grid_rowconfigure(0, :weight=>1)
        #   grid_columnconfigure(0, :weight=>1)
        #   pack(:expand=>:yes, :fill=>:both, :padx=>'1m')
        # end

        Ttk::Frame.new(main_frame) do |frame|
          Ttk::Panedwindow.new(frame, :orient=>:horizontal) do |pw|
            $ui.notebook_l = Ttk::Notebook.new(pw) { |nb|
              enable_traversal
              pack(:fill=>:both, :expand=>:yes)
            }
            $ui.notebook_r = Ttk::Notebook.new(pw) { |nb|
              enable_traversal
              pack(:fill=>:both, :expand=>:yes)
            }

            add($ui.notebook_l, $ui.notebook_r)
            pack(:side=>:left, :expand=>:yes, :fill=>:both)
          end

          pack(:expand=>:yes, :fill=>:both)
        end

        Ttk::Frame.new(main_frame) do |frame|
          Tk.pack(
            Ttk::Button.new(frame) {
              text 'reload'
              command { $pg.load_all_source }
            },
            Ttk::Button.new(frame) {
              text 'F2 Rename'
              command { $pg.cmd_rename }
            },
            Ttk::Button.new(frame) {
              text 'F3 View'
              command { $pg.cmd_view }
            },
            Ttk::Button.new(frame) {
              text 'F4 Edit'
              command { $pg.cmd_edit }
            },
            Ttk::Button.new(frame) {
              text 'F5 Copy'
              command { $pg.cmd_copy }
            },
            Ttk::Button.new(frame) {
              text 'F6 Move'
              command { $pg.cmd_move }
            },
            Ttk::Button.new(frame) {
              text 'F7 New Folder'
              command { $pg.cmd_newfolder }
            },
            Ttk::Button.new(frame) {
              text 'F8 Delete'
              command { $pg.cmd_delete }
            },
            Ttk::Button.new(frame) {
              text 'None'
              command { p 'none clicked'; $pg.command_label.text Time.now.to_s + ' >' }
            },
            :in=>frame, :side=>:left, :fill=>:x, :expand=>:yes
          )
          pack(:fill=>:x, :pady=>'1m', :padx=>'1m')
        end

        Ttk::Frame.new(main_frame) do |frame|
          $ui.command_label = Ttk::Label.new(frame) { |x|
            x.text 'path'
            x.justify :right
          }
          $ui.command_input = Ttk::Combobox.new(frame) { |b|
            b.font $cfg.font
            b.bind('Return', '%W') { |w|
              cmd = w.value.strip
              next if cmd.empty?
              puts %x{#{cmd}} rescue nil
              w.values <<= cmd unless w.values.include?(cmd)
            }
          }
          Tk.grid($ui.command_label, $ui.command_input, :in=>frame, :sticky=>:nswe)
          grid_columnconfigure(0, :weight=>1)
          grid_columnconfigure(1, :weight=>2)
          pack(:fill=>:x, :pady=>'1m', :padx=>'2m')
        end

        pack(:expand=>:yes, :fill=>:both)
      end
    end
  end
  
  def setkeys
    $ui.root.bind('F1', proc{ $pg.help_index })
    $ui.root.bind('F2', proc{ $pg.cmd_rename })
    $ui.root.bind('F3', proc{ $pg.cmd_view })
    $ui.root.bind('F4', proc{ $pg.cmd_edit })
    $ui.root.bind('F5', proc{ $pg.cmd_copy })
    $ui.root.bind('F6', proc{ $pg.cmd_move })
    $ui.root.bind('F7', proc{ $pg.cmd_newfolder })
    $ui.root.bind('F8', proc{ $pg.cmd_delete })

    $ui.root.bind('Tab', proc{ $pg.cmd_switch_active_panel })

    $ui.root.bind('BackSpace', proc{ $pg.cmd_gotoup })
  end
  
  def create_menu
    $ui.root.bind('Control-f', proc{ $pg.ftp_connect })
    $ui.root.bind('Control-r', proc{ $pg.show_reread })

    $ui.root.add_menubar([
      [
        ['Files', 0],
        ['Quit', proc{ exit }, 0]
      ],
      [
        ['Mark', 0],
        ['Select All', proc{ $pg.select_all }, 0, 'Ctrl Num +'],
      ],
      [
        ['Commands', 0],
        ['Go Back', proc{ $pg.go_back }, 0, 'Alt+Left Arrow'],
      ],
      [
        ['Net', 0],
        ['FTP Connect...', proc{ $pg.ftp_connect }, 0, 'Ctrl-F'],
      ],
      [
        ['Show', 0],
        ['Full', proc{ $pg.show_full }, 0, 'Ctrl-F2'],
        '---',
        ['Reread Source', proc{ $pg.show_reread }, 0, 'Ctrl-R'],
      ],
      [
        ['Configuration', 0],
        ['Options...', proc{ $pg.show_options }, 0],
      ],
      [
        ['Start', 0],
        '---',
        ['Change Start Menu...', proc{ $pg.change_start_menu }, 0],
        ['Change Main Mneu...', proc{ $pg.change_main_menu }, 0],
      ],
      [
        ['Help', 0],
        ['Index', proc{ $pg.help_index }, 0, 'F1'],
        ['Keyboard', proc{ $pg.help_keyboard }, 0],
        ['Registration Info', proc{ $pg.help_registration }, 0],
        ["Visit MyCommand's Web Site", proc{ $pg.help_visit_website }, 0],
        '---',
        ['About ... ', proc{ $pg.about_box }, 0],
      ],
    ])
  end
end