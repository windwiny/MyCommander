#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"
require "nokogiri"


PGNAME = "MyCommand"
VERSION = "0.1"
REGISTER = "NOT REGISTERED"



class MyConfig
  attr_accessor :font
  attr_accessor :config

  def initialize
    @config_file = File.absolute_path(File.expand_path('../config.xml', __FILE__))
    @old_xml = File.file?(@config_file) ? File.read(@config_file) : ''
    @config = Nokogiri::XML(@old_xml) { |cfg| cfg.noblanks }
    load_config_from_xml
    init_config
  end

  def save
    @config.root << "<WindowPosition></WindowPosition>" if @config.xpath("/#{PGNAME}/WindowPosition").empty?
    @config.xpath("/#{PGNAME}/WindowPosition").first.content = "+#{$ui.root.winfo_x}+#{$ui.root.winfo_y}"
    @config.xpath("/#{PGNAME}/WindowSize").first.content = "#{$ui.root.winfo_width}x#{$ui.root.winfo_height}"

    if @old_xml != @config.to_s
      @config.xpath("/#{PGNAME}/ModifyBy").first.content = Time.now
      puts "Write config to #{@config_file}"
      File.write(@config_file, @config)
      @old_xml = @config.to_s
    end
  end
  
  private
  def load_config_from_xml
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
  
  def init_config
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
  attr_accessor :panedwindow
  attr_accessor :notebook_l, :notebook_r
  attr_accessor :command_input, :command_label
  attr_accessor :lasttab
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

$image = {}

$image['refresh'] = TkPhotoImage.new(:height=>16, :format=>'GIF', :data=><<EOD)
    R0lGODlhEAAQAPMAAMz/zCpnKdb/1z9mPypbKBtLGy9NMPL/9Or+6+P+4j1Y
    PwQKBP7//xMLFAYBCAEBASH5BAEAAAAALAAAAAAQABAAAwR0EAD3Gn0Vyw0e
    ++CncU7IIAezMA/nhUqSLJizvSdCEEjy2ZIV46AwDAoDHwPYGSoEiUJAAGJ6
    EDHBNCFINW5OqABKSFk/B9lUa94IDwIFgewFMwQDQwCZQCztTgM9Sl8SOEMG
    KSAthiaOjBMPDhQONBiXABEAOw==
EOD

$image['view'] = TkPhotoImage.new(:height=>16, :format=>'GIF', :data=><<EOD)
    R0lGODlhEAAQAPMAAMz/zP///8DAwICAgH9/fwAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAwRIcMhJB7h3hM33
    KFjWdQQYap1QrCaGBmrRrS4nj5b53jOgbwXBKGACoYLDIuAoHCmZyYvR1rT5
    RMAq8LqcIYGsrjPsW1XOmFUEADs=
EOD


$cfg = MyConfig.new
END { $cfg.save rescue nil }

$ui = UI.new
$pg = MyCommand.new
$pg.run

# $ui.lasttab.focus $ui.lasttab
# Tk.root.focus Tk.root

Tk.mainloop
