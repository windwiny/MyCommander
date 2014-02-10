#!/usr/bin/env ruby
# encoding: UTF-8

require "tk"
require "nokogiri"


class MyConfig
  attr_accessor :font
  attr_accessor :config_file
  attr_accessor :config

  def initialize
    @config_file = File.absolute_path(File.expand_path('../config.xml', __FILE__))
    @old_xml = File.file?(@config_file) ? File.read(@config_file) : ''
    @config = Nokogiri::XML(@old_xml)
    @config.encoding = 'utf-8' unless @config.encoding
    @config << "<MyCommand />" unless @config.root
    @config.root << "<CreateBy>#{Time.now}</CreateBy>" if @config.xpath('/MyCommand/CreateBy').empty?
    @config.root << "<ModifyBy>#{Time.now}</ModifyBy>" if @config.xpath('/MyCommand/ModifyBy').empty?
  end

  def save
    if @old_xml != @config.to_s
      @config.xpath('/MyCommand/ModifyBy')[0].content = Time.now
      puts "Write config to #{@config_file}"
      File.write(@config_file, @config)
    end
  end
end


class MyCommand
  attr_accessor :panel_infos_left, :panel_infos_right
  attr_accessor :root, :main_frame
  attr_accessor :notebook_l, :notebook_r
  attr_accessor :command_input, :command_label

  def load_all_source
    %w{commands gui config}.each do |dir|
      d = File.expand_path("../#{dir}/*.rb", __FILE__)
      Dir.glob(d).each do |fn|
        puts "reloading ... #{fn}" if $DEBUG
        load fn
      end
    end

    unless (chs=Tk.root.winfo_children).empty?
      chs.map(&:destroy)
      $cfg.save
      $pg.init_gui
    end
  end
end


$cfg = MyConfig.new
END { $cfg.save rescue nil }

$pg = MyCommand.new

$pg.load_all_source
$pg.init_gui

Tk.mainloop
