#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"

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

$root = TkRoot.new do |root|
  $main_frame = Ttk::Frame.new(root) do |main_frame|
    Ttk::Frame.new(main_frame) do |frame|
      xscr = Ttk::Scrollbar.new(frame, :orient=>"horizontal").grid(:row=>1, :column=>0, :sticky=>'we', :in=>frame)
      yscr = Ttk::Scrollbar.new(frame, :orient=>"vertical").grid(:row=>0, :column=>1, :sticky=>'ns', :in=>frame)
      Tk::Text.new() { |t|
        t.value = ''
        t.wrap 'none'
        t.width 82
        t.height 32
        t.xscrollbar xscr
        t.yscrollbar yscr
      }.grid(:row=>0, :column=>0, :sticky=>"nsew", 'in'=>frame)
      frame.grid_rowconfigure 0, :weight=>1
      frame.grid_columnconfigure 0, :weight=>1
    end.pack('expand'=>'yes', 'fill'=>'both', 'padx'=>'1m')

    Ttk::Frame.new(main_frame) do |frame|
      Ttk::Button.new(frame) {
        text 'bsf 3'
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
    end.pack('fill'=>'x', 'pady'=>'1m', 'padx'=>'1m')

    Ttk::Frame.new(main_frame) do |frame|
      Ttk::Button.new(frame) {
        text 'reload'
        command {cmd_reload_all}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')

      Ttk::Button.new(frame) {
        text 'F2 Rename'
        command {cmd_rename}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F3 View'
        command {cmd_view}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F4 Edit'
        command {cmd_edit}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F5 Copy'
        command {cmd_copy}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F6 Move'
        command {cmd_move}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F7 New Folder'
        command {cmd_newfolder}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'F8 Delete'
        command {cmd_delete}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      Ttk::Button.new(frame) {
        text 'None'
        command {p 'none clicked'}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
    end.pack('fill'=>'x', 'pady'=>'1m', 'padx'=>'1m')

  end.pack('expand'=>'yes', 'fill'=>'both')
end

Tk.mainloop
