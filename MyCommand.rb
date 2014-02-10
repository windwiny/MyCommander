#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"


class MyConfig
  attr_accessor :font
end
$cfg = MyConfig.new

class MyCommand
  attr_accessor :panel_infos_left, :panel_infos_right
  attr_accessor :root, :main_frame
  attr_accessor :notebook_l, :notebook_r
  attr_accessor :command_input, :command_label

  def load_all_source
    %w{commands gui}.each do |dir|
      d = File.expand_path("../#{dir}/*.rb", __FILE__)
      Dir.glob(d).each do |fn|
        puts "reloading ... #{fn}" if $DEBUG
        load fn
      end
    end

    unless (chs=Tk.root.winfo_children).empty?
      chs.each { |x| x.destroy }
      $pg.init_gui
    end
  end
end

$pg = MyCommand.new

$pg.load_all_source
$pg.init_gui

Tk.mainloop
