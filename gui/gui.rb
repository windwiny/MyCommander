class MyCommand
  def init_gui
    create_gui
    setkeys
    create_menu
  end

  def load_notebook
    p $cfg.config.xpath '/MyCommand/Notebook_l'
    p $cfg.config.xpath '/MyCommand/Notebook_r'
  end

  private
  def create_gui
    @panel_infos_left = []
    @panel_infos_right = []

    @root = TkRoot.new do |root|
      @main_frame = Ttk::Frame.new(root) do |main_frame|
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
        #   Tk.grid(tx, yscr, :in =>frame, :sticky=>:nswe)
        #   Tk.grid(xscr, :in =>frame, :sticky=>:nswe)
        #   grid_rowconfigure(0, :weight=>1)
        #   grid_columnconfigure(0, :weight=>1)
        #   pack(:expand=>:yes, :fill=>:both, :padx=>'1m')
        # end

        Ttk::Frame.new(main_frame) do |frame|
          Ttk::Panedwindow.new(frame, :orient=>:horizontal) do |pw|
            $paneList = TkVariable.new
            $paneList.value = [
                'List of Ruby/Tk Widgets',
                'TkButton',
                'TkCanvas',
                'TkCheckbutton',
                'TkEntry',
                'TkFrame',
                'TkLabel',
                'TkLabelframe',
                'TkListbox',
                'TkMenu',
                'TkMenubutton',
                'TkMessage',
                'TkPanedwindow',
                'TkRadiobutton',
                'TkScale',
                'TkScrollbar',
                'TkSpinbox',
                'TkText',
                'TkToplevel'
            ]
            @notebook_l = Ttk::Notebook.new(pw) { |nb|
              enable_traversal
              t1 = Ttk::Frame.new(nb) { |f1|
                Ttk::Entry.new(f1).pack(:fill=>:x, :expand=>:no, :side=>:top)
                TkListbox.new(f1, :listvariable=>$paneList) {
                  itemconfigure(0, :background=>self.cget(:foreground),
                                   :foreground=>self.cget(:background) )
                  yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
                  pack(:fill=>:both, :expand=>:yes, :side=>:top)
                }
              }
              t2 = Ttk::Frame.new(nb) { |f1|
                Ttk::Entry.new(f1).pack(:fill=>:x, :expand=>:no, :side=>:top)
                TkListbox.new(f1, :listvariable=>$paneList) {
                  itemconfigure(0, :background=>self.cget(:foreground),
                                   :foreground=>self.cget(:background) )
                  yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
                  pack(:fill=>:both, :expand=>:yes, :side=>:top)
                }
              }
              nb.add(t1, :text=>'file left')
              nb.add(t2, :text=>'file left 2')
              pack(:fill=>:both, :expand=>:yes)
            }
            @notebook_r = Ttk::Notebook.new(pw) { |nb|
              enable_traversal
              t1 = Ttk::Frame.new(nb) { |f1|
                Ttk::Entry.new(f1).pack(:fill=>:x, :expand=>:no, :side=>:top)
                TkListbox.new(f1, :listvariable=>$paneList) {
                  itemconfigure(0, :background=>self.cget(:foreground),
                                   :foreground=>self.cget(:background) )
                  yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
                  pack(:fill=>:both, :expand=>:yes, :side=>:top)
                }
              }
              t2 = Ttk::Frame.new(nb) { |f1|
                Ttk::Entry.new(f1).pack(:fill=>:x, :expand=>:no, :side=>:top)
                TkListbox.new(f1, :listvariable=>$paneList) {
                  itemconfigure(0, :background=>self.cget(:foreground),
                                   :foreground=>self.cget(:background) )
                  yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
                  pack(:fill=>:both, :expand=>:yes, :side=>:top)
                }
              }
              nb.add(t1, :text=>'file right')
              nb.add(t2, :text=>'file right 2')
              pack(:fill=>:both, :expand=>:yes)
            }

            add(@notebook_l, @notebook_r)
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
              command { p 'none clicked'; @command_label.text Time.now.to_s + ' >' }
            },
            :in=>frame, :side=>:left, :fill=>:x, :expand=>:yes
          )
          pack(:fill=>:x, :pady=>'1m', :padx=>'1m')
        end

        Ttk::Frame.new(main_frame) do |frame|
          @command_label = Ttk::Label.new(frame) { |x|
            x.text 'path'
            x.justify :right
          }
          @command_input = Ttk::Combobox.new(frame) { |b|
            b.font $cfg.font
            b.bind('Return', '%W') { |w|
              cmd = w.value.strip
              next if cmd.empty?
              puts %x{#{cmd}} rescue nil
              w.values <<= cmd unless w.values.include?(cmd)
            }
          }
          Tk.grid(@command_label, @command_input, :in=>frame, :sticky=>:nswe)
          grid_columnconfigure(0, :weight=>1)
          grid_columnconfigure(1, :weight=>2)
          pack(:fill=>:x, :pady=>'1m', :padx=>'2m')
        end

        pack(:expand=>:yes, :fill=>:both)
      end
    end
  end
  
  def setkeys
    @root.bind('F1', proc{ $pg.help_index })
    @root.bind('F2', proc{ $pg.cmd_rename })
    @root.bind('F3', proc{ $pg.cmd_view })
    @root.bind('F4', proc{ $pg.cmd_edit })
    @root.bind('F5', proc{ $pg.cmd_copy })
    @root.bind('F6', proc{ $pg.cmd_move })
    @root.bind('F7', proc{ $pg.cmd_newfolder })
    @root.bind('F8', proc{ $pg.cmd_delete })

    @root.bind('Tab', proc{ $pg.cmd_switch_active_panel })

    @root.bind('BackSpace', proc{ $pg.cmd_gotoup })
  end
  
  def create_menu
    @root.bind('Control-f', proc{ $pg.ftp_connect })
    @root.bind('Control-r', proc{ $pg.show_reread })

    @root.add_menubar([
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