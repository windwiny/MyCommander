#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"

def about_box
  Tk.messageBox :title=>'About..', :message=>"hello"
end

def cmd_reload_all
  d = File.expand_path('../lib/cmd4*.rb', __FILE__)
  Dir.glob(d).each do |fn|
    puts "reloading ... #{fn}" if $DEBUG
    load fn
  end
end

def aff *args
  p 'in aff'
  p args

end


cmd_reload_all

$font = TkFont.new('Courier -14')
$left_panel_infos = []
$right_panel_infos = []

$root = TkRoot.new do |root|
  $main_frame = Ttk::Frame.new(root) do |main_frame|
    Ttk::Frame.new(main_frame) do |frame|
      xscr = Ttk::Scrollbar.new(frame, :orient=>"horizontal")
      yscr = Ttk::Scrollbar.new(frame, :orient=>"vertical")
      tx = Tk::Text.new() { |t|
        t.font $font
        t.value = ''
        t.wrap 'none'
        t.width 10
        t.height 4
        t.xscrollbar xscr
        t.yscrollbar yscr
      }
      Tk.grid(tx, yscr, :in =>frame, :sticky=>:nswe)
      Tk.grid(xscr, :in =>frame, :sticky=>:nswe)
      grid_rowconfigure(0, :weight=>1)
      grid_columnconfigure(0, :weight=>1)
      pack(:expand=>:yes, :fill=>:both, :padx=>'1m')
    end

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
        $notebook_l = Ttk::Notebook.new(pw) { |nb|
          enable_traversal
          t1 = Ttk::Frame.new(nb) { |f1|
            TkListbox.new(f1, :listvariable=>$paneList) {
              itemconfigure(0, :background=>self.cget(:foreground),
                               :foreground=>self.cget(:background) )
              yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
              pack(:fill=>:both, :expand=>:yes, :side=>:left)
            }
          }
          t2 = Ttk::Frame.new(nb) { |f1|
            TkListbox.new(f1, :listvariable=>$paneList) {
              itemconfigure(0, :background=>self.cget(:foreground),
                               :foreground=>self.cget(:background) )
              yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
              pack(:fill=>:both, :expand=>:yes, :side=>:left)
            }
          }
          nb.add(t1, :text=>'file left', :underline=>0)
          nb.add(t2, :text=>'file left 2', :underline=>0)
          pack(:fill=>:both, :expand=>:yes)
        }
        $notebook_r = Ttk::Notebook.new(pw) { |nb|
          enable_traversal
          t1 = Ttk::Frame.new(nb) { |f1|
            TkListbox.new(f1, :listvariable=>$paneList) {
              itemconfigure(0, :background=>self.cget(:foreground),
                               :foreground=>self.cget(:background) )
              yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
              pack(:fill=>:both, :expand=>:yes, :side=>:left)
            }
          }
          t2 = Ttk::Frame.new(nb) { |f1|
            TkListbox.new(f1, :listvariable=>$paneList) {
              itemconfigure(0, :background=>self.cget(:foreground),
                               :foreground=>self.cget(:background) )
              yscrollbar(TkScrollbar.new(f1).pack(:side=>:right, :fill=>:y))
              pack(:fill=>:both, :expand=>:yes, :side=>:left)
            }
          }
          nb.add(t1, :text=>'file right', :underline=>0)
          nb.add(t2, :text=>'file right 2', :underline=>0)
          pack(:fill=>:both, :expand=>:yes)
        }

        add($notebook_l, $notebook_r)
        pack(:side=>:left, :expand=>:yes, :fill=>:both)
      end

      pack(:expand=>:yes, :fill=>:both)
    end

    Ttk::Frame.new(main_frame) do |frame|
      Tk.pack(
        Ttk::Button.new(frame) {
          text 'reload'
          command { cmd_reload_all }
        },
        Ttk::Button.new(frame) {
          text 'F2 Rename'
          command { cmd_rename }
        },
        Ttk::Button.new(frame) {
          text 'F3 View'
          command { cmd_view }
        },
        Ttk::Button.new(frame) {
          text 'F4 Edit'
          command { cmd_edit }
        },
        Ttk::Button.new(frame) {
          text 'F5 Copy'
          command { cmd_copy }
        },
        Ttk::Button.new(frame) {
          text 'F6 Move'
          command { cmd_move }
        },
        Ttk::Button.new(frame) {
          text 'F7 New Folder'
          command { cmd_newfolder }
        },
        Ttk::Button.new(frame) {
          text 'F8 Delete'
          command { cmd_delete }
        },
        Ttk::Button.new(frame) {
          text 'None'
          command {p 'none clicked'; $command_label.text Time.now.to_s + ' >' }
        },
        :in=>frame, :side=>:left, :fill=>:x, :expand=>:yes
      )
      pack(:fill=>:x, :pady=>'1m', :padx=>'1m')
    end

    Ttk::Frame.new(main_frame) do |frame|
      $command_label = Ttk::Label.new(frame) { |x|
        x.text 'path'
        x.justify :right
      }
      $command_input = Ttk::Combobox.new(frame) { |b|
        b.font $font
        b.bind('Return', '%W') { |w|
          cmd = w.value.strip
          next if cmd.empty?
          puts %x{#{cmd}} rescue nil
          w.values <<= cmd unless w.values.include?(cmd)
        }
      }
      Tk.grid($command_label, $command_input, :in=>frame, :sticky=>:nswe)
      grid_columnconfigure(0, :weight=>3)
      grid_columnconfigure(1, :weight=>4)
      pack(:fill=>:x, :pady=>'1m', :padx=>'2m')
    end

    pack(:expand=>:yes, :fill=>:both)
  end
end
$root.bind('F1', proc{ about_box })
$root.bind('F2', proc{ cmd_rename })
$root.bind('F3', proc{ cmd_view })
$root.bind('F4', proc{ cmd_edit })
$root.bind('F5', proc{ cmd_copy })
$root.bind('F6', proc{ cmd_move })
$root.bind('F7', proc{ cmd_newfolder })
$root.bind('F8', proc{ cmd_delete })

Tk.mainloop
