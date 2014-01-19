#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"

def cmd_reload_all
  d = File.expand_path('../lib/cmd4*.rb', __FILE__)
  Dir.glob(d).each do |fn|
    puts "reloading ... #{fn}" if $DEBUG
    load fn rescue nil
  end
end

def aff *args
  p 'in aff'
  p args

end

$root = TkRoot.new do |root|
  $main_frame = TkFrame.new(root) do |main_frame|
    TkFrame.new(main_frame) do |frame|
      TkText.new() { |t|
        t.value = ''
      }.pack('expand'=>'yes', 'fill'=>'both', 'in'=>frame)
    end.pack('expand'=>'yes', 'fill'=>'both', 'padx'=>'1m')

    TkFrame.new(main_frame) do |frame|
      TkButton.new(frame) {
        text 'bsf 3'
        # width 120
        # height 30
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
    end.pack('fill'=>'x', 'pady'=>'1m', 'padx'=>'1m')

    TkFrame.new(main_frame) do |frame|
      TkButton.new(frame) {
        text 'reload'
        command {cmd_reload_all}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')

      TkButton.new(frame) {
        text 'F2 Rename'
        command {cmd_rename}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F3 View'
        command {cmd_view}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F4 Edit'
        command {cmd_edit}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F5 Copy'
        command {cmd_copy}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F6 Move'
        command {cmd_move}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F7 New Folder'
        command {cmd_newfolder}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'F8 Delete'
        command {cmd_delete}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
      TkButton.new(frame) {
        text 'None'
        command {p 'none clicked'}
      }.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'x')
    end.pack('fill'=>'x', 'pady'=>'1m', 'padx'=>'1m')

  end.pack('expand'=>'yes', 'fill' => 'both')
end

Tk.mainloop
