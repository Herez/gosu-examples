#!/usr/bin/env ruby

require 'rubygems'
require 'gosu/preview'


class Example
  attr_accessor :caption
  attr_reader :width, :height
  
  def initialize(width, height, *options)
    @width, @height = width, height
  end
  
  def draw
  end
  
  def update
  end
  
  def button_down(id)
  end
  
  def button_up(id)
  end
  
  def button_down?(id)
    Gosu::button_down?(id)
  end
  
  def self.current_source_file
    @current_source_file
  end
  
  def self.current_source_file=(current_source_file)
    @current_source_file = current_source_file
  end
  
  def self.inherited(subclass)
    @@examples ||= {}
    @@examples[subclass] = self.current_source_file
  end
  
  def self.examples
    @@examples.keys - [Feature]
  end
  
  def self.source_file
    @@examples[self]
  end
  
  def show_source
    if file = self.class.source_file then
      if RUBY_PLATFORM =~ /darwin[0-9]*$/ then
        `open '#{file}'`
      elsif RUBY_PLATFORM =~ /mingw[0-9]*$/ then
        `explorer '#{file}'`
      else
        `xdg-open '#{file}'`
      end
    end
  end
end


class Feature < Example
  def self.inherited(subclass)
    @@features ||= {}
    @@features[subclass] = self.current_source_file
  end
  
  def self.features
    @@features.keys
  end
  
  def self.source_file
    @@examples[self]
  end
end


Dir.chdir "#{File.dirname __FILE__}/../examples"

Dir.glob("{.,../features}/{welcome}.rb") do |file| # TODO - should be *.rb
  begin
    # Remember that all examples and features being loaded now must come from the
    # next file.
    #
    Example.current_source_file = File.expand_path(file)
    
    # Load the example/feature in a sandbox module (second parameter). This way,
    # several examples can define a Player class without colliding.
    # 
    # load() does not let us refer to the anonymous module it creates, but we
    # can enumerate all loaded examples and features using Example.examples and
    # Feature.features afterwards.
    # 
    load file, true
  rescue StandardError => e
    puts "*** Cannot load #{file}:"
    puts e
    puts
  end
end


class ExampleBox < Gosu::Window
  # TODO - the ExampleWindow should resize to fit once Gosu::Window#resize has been added.
  # See https://github.com/jlnr/gosu/issues/255
  EXAMPLE_WIDTH  = 600
  EXAMPLE_HEIGHT = 600
  SIDEBAR_WIDTH  = 213
  
  def initialize
    super SIDEBAR_WIDTH + EXAMPLE_WIDTH, EXAMPLE_HEIGHT, :fullscreen => ARGV.include?('--fullscreen')
    
    @header = Gosu::Image.new("media/header.psd", :tileable => true)
    @current_example = Example::examples.sample.new
  end
  
  def update
    self.caption = "Gosu Example Box - #{@current_example.caption}"
    
    @current_example.update
  end
  
  def draw
    @current_example.draw
    
    flush
    
    draw_sidebar
  end
  
  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    when char_to_button_id('S')
      @current_example.show_source
    else
      @current_example.button_down(id)
    end
  end
  
  def button_up(id)
    @current_example.button_up(id)
  end
  
  def needs_cursor?
    true
  end
  
  private
  
  def draw_sidebar
    Gosu::draw_quad EXAMPLE_WIDTH,                 0,              Gosu::Color::WHITE,
                    EXAMPLE_WIDTH + SIDEBAR_WIDTH, 0,              Gosu::Color::WHITE,
                    EXAMPLE_WIDTH,                 EXAMPLE_HEIGHT, Gosu::Color::WHITE,
                    EXAMPLE_WIDTH + SIDEBAR_WIDTH, EXAMPLE_HEIGHT, Gosu::Color::WHITE,
                    0
    
    @header.draw EXAMPLE_WIDTH, 0, 0
  end
end

ExampleBox.new.show