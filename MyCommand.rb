#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"
require "nokogiri"


PGNAME = "MyCommand"
VERSION = "0.1"
REGISTER = "NOT REGISTERED"



class MyConfig
  attr_accessor :font
  attr_accessor :config_file
  attr_accessor :config

  def initialize
    @config_file = File.absolute_path(File.expand_path('../config.xml', __FILE__))
    @old_xml = File.file?(@config_file) ? File.read(@config_file) : ''
    @config = Nokogiri::XML(@old_xml) { |cfg| cfg.noblanks }
    initconfig
    loadconfig
  end

  def save
    if @old_xml != @config.to_s
      @config.xpath("/#{PGNAME}/ModifyBy").first.content = Time.now
      puts "Write config to #{@config_file}"
      File.write(@config_file, @config)
      @old_xml = @config.to_s
    end
  end
  
  private
  def initconfig
    @config.encoding = 'utf-8' unless @config.encoding
    @config << "<#{PGNAME} />" unless @config.root
    @config.root << "<CreateBy>#{Time.now}</CreateBy>" if @config.xpath("/#{PGNAME}/CreateBy").empty?
    @config.root << "<ModifyBy>#{Time.now}</ModifyBy>" if @config.xpath("/#{PGNAME}/ModifyBy").empty?
    @config.root << "<Font>Courier -14</Font>" if @config.xpath("/#{PGNAME}/Font").empty?
    if @config.xpath("/#{PGNAME}/WindowSize").empty?
      width = [Tk.root.maxsize[0], Tk.root.winfo_screenwidth].min
      height = [Tk.root.maxsize[1], Tk.root.winfo_screenheight].min
      @config.root << "<WindowSize>#{width}x#{height}</WindowSize>"
    end
  end
  
  def loadconfig
    @font = TkFont.new(@config.xpath("/#{PGNAME}/Font").first.text)
  end
end

class UI
  attr_accessor :panel_infos_left, :panel_infos_right
  attr_accessor :tree2addr
  def initialize
    @panel_infos_left = []
    @panel_infos_right = []
    @tree2addr = {}
  end

  attr_accessor :root, :main_frame
  attr_accessor :notebook_l, :notebook_r
  attr_accessor :command_input, :command_label
end

class MyCommand
  def run #not initialize
    load_all_source
    init_gui
    load_notebook
  end

  def load_all_source
    %w{commands gui}.each do |dir|
      d = File.expand_path("../#{dir}/*.rb", __FILE__)
      Dir.glob(d).each do |fn|
        puts "reloading ... #{fn}" if $DEBUG
        load fn
      end
    end

    unless (chs=Tk.root.winfo_children).empty?
      chs.map(&:destroy)
      $cfg.save
      init_gui
      load_notebook
    end
  end
end

$cfg = MyConfig.new
END { $cfg.save rescue nil }

$ui = UI.new
$pg = MyCommand.new
$pg.run

Tk.mainloop
