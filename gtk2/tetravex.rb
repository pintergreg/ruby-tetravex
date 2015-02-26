#!/usr/bin/ruby
# encoding: utf-8
#The MIT License (MIT)
#
#Copyright (c) 2015 Gergő Pintér
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

require 'gtk2'

#tile class only contains the four value with getter methods
class Tile

  def initialize(top, right, bottom, left)
    @top    = top
    @right  = right
    @bottom = bottom
    @left   = left
  end
  
  def getTop
    return @top
  end
  
  def getRight
    return @right
  end
  
  def getBottom
    return @bottom
  end
  
  def getLeft
    return @left
  end
end

class Game

  def initialize
    @tiles=Array.new(9)
    @table=Array.new(18)
    @selected=nil
    @start_time = @end_time = 0.0
    init
  end
  
  def init
    @started=false
    #generate random values of tiles in a solved state from tile 0 to 8, considering the matches
    @tiles[0]=Tile.new rand(10), rand(10), rand(10), rand(10)
    @tiles[1]=Tile.new rand(10), rand(10), rand(10), @tiles[0].getRight
    @tiles[2]=Tile.new rand(10), rand(10), rand(10), @tiles[1].getRight

    @tiles[3]=Tile.new @tiles[0].getBottom, rand(10), rand(10), rand(10)
    @tiles[4]=Tile.new @tiles[1].getBottom, rand(10), rand(10), @tiles[3].getRight
    @tiles[5]=Tile.new @tiles[2].getBottom, rand(10), rand(10), @tiles[4].getRight

    @tiles[6]=Tile.new @tiles[3].getBottom, rand(10), rand(10), rand(10)
    @tiles[7]=Tile.new @tiles[4].getBottom, rand(10), rand(10), @tiles[6].getRight
    @tiles[8]=Tile.new @tiles[5].getBottom, rand(10), rand(10), @tiles[7].getRight
    
    for i in 0..17 do
      @table[i]=nil
    end
    
    for i in 9..17 do
      k=0
      begin
        k=rand(9)
      end while @table.include?(@tiles[k])
      @table[i]=@tiles[k]
    end
  end
  
  def getTable
    return @table
  end
  
  def getTiles
    return @tiles
  end
  
  def started
    @started
  end
  
  def started=(value)
    @started = value
  end
  
  def start_time=(value)
    @start_time = value
  end
  
  def stop_time=(value)
    @stop_time = value
  end
  
  def stop_time
    @stop_time
  end
  
  def getSelected
    return @selected
  end
  
  def setSelected s
    @selected=s 
  end
  
  #used for debugging purposes
  def drawToSTDOUT
    for r in (0..6).step(3) do
      print "+-----++-----++-----+\n"
      print "| \\"+@table[r].getTop.to_s+"/ || \\"+@table[r+1].getTop.to_s+"/ || \\"+@table[r+2].getTop.to_s+"/ |\n"
      print "|"+@table[r].getLeft.to_s+" × "+@table[r+1].getRight.to_s+"||"+@table[r+2].getLeft.to_s+" × "+@table[r].getRight.to_s+"||"+@table[r+1].getLeft.to_s+" × "+@table[r+2].getRight.to_s+"|\n"
      print "| /"+@table[r].getBottom.to_s+"\\ || /"+@table[r+1].getBottom.to_s+"\\ || /"+@table[r+2].getBottom.to_s+"\\ |\n"
      print "+-----++-----++-----+\n"
    end
  end
end



class TileWidget < Gtk::DrawingArea

  def initialize parent, tile, number, callback
    @parent = parent
    @tile = tile
    @selected = false
    @number = number

    super()
    
    #add and catch mouse click event, where a invert selected value and callback to main swapping method
    add_events Gdk::Event::BUTTON_PRESS_MASK
    signal_connect("button-press-event") do
            @selected = !@selected
            callback.call @number        
    end
 
    #color codes for tile values, defined with nested hashes where a value determines a hash with rgb values
    @bgcolor = Hash[0=> Hash["r" => 0.0, "g" => 0.0, "b"=> 0.0], 1 =>Hash["r" => 0.76, "g" => 0.49, "b"=> 0.07], 2 =>Hash["r" => 0.8, "g" => 0.0, "b"=> 0.0], 3 =>Hash["r" => 0.96, "g" => 0.47, "b"=> 0.0], 4 =>Hash["r" => 0.93, "g" => 0.83, "b"=> 0.0], 5 =>Hash["r" => 0.45, "g" => 0.83, "b"=> 0.08], 6 =>Hash["r" => 0.2, "g" => 0.39, "b"=> 0.64], 7 =>Hash["r" => 0.46, "g" => 0.31, "b"=> 0.48], 8 =>Hash["r" => 0.72, "g" => 0.72, "b"=> 0.72], 9 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], nil =>Hash["r" => 0.53, "g" => 0.53, "b"=> 0.53]]

    @fgcolor = Hash[0=> Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 1 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 2 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 3 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 4 =>Hash["r" => 0.0, "g" => 0.0, "b"=> 0.0], 5 =>Hash["r" => 0.0, "g" => 0.0, "b"=> 0.0], 6 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 7 =>Hash["r" => 1.0, "g" => 1.0, "b"=> 1.0], 8 =>Hash["r" => 0.0, "g" => 0.0, "b"=> 0.0], 9 =>Hash["r" => 0.0, "g" => 0.0, "b"=> 0.0], nil =>Hash["r" => 0.53, "g" => 0.53, "b"=> 0.53]]

    @tile_size=99 
    @tile_center=(@tile_size+1)/2

    set_size_request @tile_size, @tile_size
    signal_connect "expose_event" do
        on_draw
    end
  
  end

  def on_draw  
    cr = window.create_cairo_context
    draw_widget cr
  end
  
  def getSelected
    return @selected
  end
  
  def setSelected s
    @selected=s
  end
  
  def getTile
    return @tile
  end
  
  def setTile tile
    @tile=tile
  end
  
  def getNumber
    return @number
  end

  def draw_widget cr
    if @tile==nil then #if there's no tile in tilewidget, draw a gray square with black border
      cr.set_source_rgb 0.53, 0.53, 0.53
      cr.rectangle(0, 0, @tile_size, @tile_size)
      cr.fill
      cr.stroke
      cr.set_source_rgb 0.0, 0.0, 0.0
      cr.rectangle(0, 0, @tile_size, @tile_size)
      cr.stroke
    else
        #draw top triange with cairo
        cr.set_source_rgb @bgcolor[@tile.getTop]["r"], @bgcolor[@tile.getTop]["g"], @bgcolor[@tile.getTop]["b"]
        cr.move_to(0, 0)
        cr.line_to(@tile_center, @tile_center)
        cr.line_to(@tile_size, 0)
        cr.close_path
        cr.fill
        cr.stroke
      
        #draw right triange with cairo
        cr.set_source_rgb @bgcolor[@tile.getRight]["r"], @bgcolor[@tile.getRight]["g"], @bgcolor[@tile.getRight]["b"]
        cr.move_to(@tile_size, 0)
        cr.line_to(@tile_center, @tile_center)
        cr.line_to(@tile_size, @tile_size)
        cr.close_path
        cr.fill
        cr.stroke

        #draw bottom triange with cairo
        cr.set_source_rgb @bgcolor[@tile.getBottom]["r"], @bgcolor[@tile.getBottom]["g"], @bgcolor[@tile.getBottom]["b"]
        cr.move_to(@tile_size, @tile_size)
        cr.line_to(@tile_center, @tile_center)
        cr.line_to(0, @tile_size)
        cr.close_path
        cr.fill
        cr.stroke

        #draw left triange with cairo
        cr.set_source_rgb @bgcolor[@tile.getLeft]["r"], @bgcolor[@tile.getLeft]["g"], @bgcolor[@tile.getLeft]["b"]
        cr.move_to(0, @tile_size)
        cr.line_to(@tile_center, @tile_center)
        cr.line_to(0, 0)
        cr.close_path
        cr.fill
        cr.stroke
        
        #draw border, red if selected, black if not
        if @selected then
          cr.set_source_rgb 1.0, 0.0, 0.0
          cr.rectangle(0, 0, @tile_size, @tile_size)
          cr.stroke
        else
          cr.set_source_rgb 0.0, 0.0, 0.0
          cr.rectangle(0, 0, @tile_size, @tile_size)
          cr.stroke
        end
        
        #draw triangle lighten and darken lines in order of top, right, bottom and left
        cr.set_line_width(2)
        cr.move_to(2, 2)
        cr.set_source_rgb @bgcolor[@tile.getTop]["r"]+0.1, @bgcolor[@tile.getTop]["g"]+0.1, @bgcolor[@tile.getTop]["b"]+0.1
        cr.line_to(@tile_center, @tile_center-1)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getTop]["r"]-0.1, @bgcolor[@tile.getTop]["g"]-0.1, @bgcolor[@tile.getTop]["b"]-0.1
        cr.move_to(@tile_center, @tile_center-1)
        cr.line_to(@tile_size-2, 2)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getRight]["r"]+0.1, @bgcolor[@tile.getRight]["g"]+0.1, @bgcolor[@tile.getRight]["b"]+0.1
        cr.move_to(@tile_size-2, 2)
        cr.line_to(@tile_center+1, @tile_center)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getRight]["r"]+0.1, @bgcolor[@tile.getRight]["g"]+0.1, @bgcolor[@tile.getRight]["b"]+0.1
        cr.move_to(@tile_center+1, @tile_center)
        cr.line_to(@tile_size-2, @tile_size-2)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getBottom]["r"]-0.1, @bgcolor[@tile.getBottom]["g"]-0.1, @bgcolor[@tile.getBottom]["b"]-0.1
        cr.move_to(@tile_size-2, @tile_size-2)
        cr.line_to(@tile_center, @tile_center+1)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getBottom]["r"]+0.1, @bgcolor[@tile.getBottom]["g"]+0.1, @bgcolor[@tile.getBottom]["b"]+0.1
        cr.move_to(@tile_center, @tile_center+1)
        cr.line_to(2, @tile_size-2)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getLeft]["r"]-0.1, @bgcolor[@tile.getLeft]["g"]-0.1, @bgcolor[@tile.getLeft]["b"]-0.1
        cr.move_to(2, @tile_size-2)
        cr.line_to(@tile_center-1, @tile_center)
        cr.stroke
        
        cr.set_source_rgb @bgcolor[@tile.getLeft]["r"]-0.1, @bgcolor[@tile.getLeft]["g"]-0.1, @bgcolor[@tile.getLeft]["b"]-0.1
        cr.move_to(@tile_center-1, @tile_center)
        cr.line_to(2, 2)
        cr.stroke
        
        #write numbers onto triangles
        cr.select_font_face "Sanserif", Cairo::FONT_SLANT_NORMAL,  Cairo::FONT_WEIGHT_BOLD
        cr.set_font_size 30 
        
        cr.set_source_rgb @fgcolor[@tile.getTop]["r"], @fgcolor[@tile.getTop]["r"], @fgcolor[@tile.getTop]["r"]
        cr.move_to (@tile_size-cr.text_extents(@tile.getTop.to_s).width)/2, 30
        cr.show_text @tile.getTop.to_s 
        
        cr.set_source_rgb @fgcolor[@tile.getBottom]["r"], @fgcolor[@tile.getBottom]["r"], @fgcolor[@tile.getBottom]["r"]
        cr.move_to (@tile_size-cr.text_extents(@tile.getBottom.to_s).width)/2, @tile_size-8
        cr.show_text @tile.getBottom.to_s 
        
        cr.set_source_rgb @fgcolor[@tile.getLeft]["r"], @fgcolor[@tile.getLeft]["r"], @fgcolor[@tile.getLeft]["r"]
        cr.move_to 8,(@tile_size+cr.text_extents(@tile.getLeft.to_s).height)/2
        cr.show_text @tile.getLeft.to_s 
        
        cr.set_source_rgb @fgcolor[@tile.getRight]["r"], @fgcolor[@tile.getRight]["r"], @fgcolor[@tile.getRight]["r"]
        cr.move_to @tile_size-cr.text_extents(@tile.getRight.to_s).width-10,(@tile_size+cr.text_extents(@tile.getRight.to_s).height)/2
        cr.show_text @tile.getRight.to_s
    end
  end

end

class MainWindow < Gtk::Window
    def initialize
        super
        
        if  File.exist?('icon.png') then
            icon = Gdk::Pixbuf.new "icon.png"
            set_icon icon
        end
        
        @game=Game.new
        @timer = GLib::Timer.new
    
        set_title  "Tetravex"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end

        set_resizable false
        init_ui
        
        show_all
    end
    
    def init_ui      
        fixed = Gtk::Fixed.new
        add fixed
       
        button = Gtk::Button.new 'New'
        button.set_size_request 80, 35      
        button.signal_connect "clicked" do 
            @game=Game.new 
            for i in 0..17 do
                @tiles[i].setTile @game.getTable[i]
                @tiles[i].queue_draw
            end
            @timer.reset
        end
        
        fixed.put button, 10, 5 
        
        button2 = Gtk::Button.new 'Quit'
        button2.set_size_request 80, 35      
        button2.signal_connect "clicked" do  
            Gtk.main_quit
        end
        
        #@label = Gtk::Label.new "00:00"
        #@label.override_font(Pango::FontDescription.new("Sans Bold 20"))
        #fixed.put @label, 600, 13
  
        fixed.put button2, 95, 5      
        
        @darea = Gtk::DrawingArea.new
        @darea.set_size_request 40, 306 
        fixed.put @darea, 330, 55
        
        @darea.signal_connect "expose_event" do  
            cr = @darea.window.create_cairo_context  
            cr.set_source_rgb 0.25, 0.25, 0.25
            cr.move_to(40, 0)
            cr.line_to(0, 153)
            cr.line_to(40, 306)
            cr.close_path
            cr.fill
            cr.stroke
        end

        @tiles = Array.new 18
        @tiles[0] = TileWidget.new fixed, @game.getTable[0], 0, method(:deselect)
        fixed.put @tiles[0], 10,55
        @tiles[1] = TileWidget.new fixed, @game.getTable[1], 1, method(:deselect)
        fixed.put @tiles[1], 113,55
        @tiles[2] = TileWidget.new fixed, @game.getTable[2], 2, method(:deselect)
        fixed.put @tiles[2], 216,55
        
        @tiles[3] = TileWidget.new fixed, @game.getTable[3], 3, method(:deselect)
        fixed.put @tiles[3], 10,158
        @tiles[4] = TileWidget.new fixed, @game.getTable[4], 4, method(:deselect)
        fixed.put @tiles[4], 113,158
        @tiles[5] = TileWidget.new fixed, @game.getTable[5], 5, method(:deselect)
        fixed.put @tiles[5], 216,158
        
        @tiles[6] = TileWidget.new fixed, @game.getTable[6], 6, method(:deselect)
        fixed.put @tiles[6], 10,261
        @tiles[7] = TileWidget.new fixed, @game.getTable[7], 7, method(:deselect)
        fixed.put @tiles[7], 113,261
        @tiles[8] = TileWidget.new fixed, @game.getTable[8], 8, method(:deselect)
        fixed.put @tiles[8], 216,261
        
        @tiles[9] = TileWidget.new fixed, @game.getTable[9], 9, method(:deselect)
        fixed.put @tiles[9], 386,55
        @tiles[10] = TileWidget.new fixed, @game.getTable[10], 10, method(:deselect)
        fixed.put @tiles[10], 489,55
        @tiles[11] = TileWidget.new fixed, @game.getTable[11], 11, method(:deselect)
        fixed.put @tiles[11], 592,55
        
        @tiles[12] = TileWidget.new fixed, @game.getTable[12], 12, method(:deselect)
        fixed.put @tiles[12], 386,158
        @tiles[13] = TileWidget.new fixed, @game.getTable[13], 13, method(:deselect)
        fixed.put @tiles[13], 489,158
        @tiles[14] = TileWidget.new fixed, @game.getTable[14], 14, method(:deselect)
        fixed.put @tiles[14], 592,158
        
        @tiles[15] = TileWidget.new fixed, @game.getTable[15], 15, method(:deselect)
        fixed.put @tiles[15], 386,261
        @tiles[16] = TileWidget.new fixed, @game.getTable[16], 16, method(:deselect)
        fixed.put @tiles[16], 489,261
        @tiles[17] = TileWidget.new fixed, @game.getTable[17], 17, method(:deselect)
        fixed.put @tiles[17], 592,261
        
        set_default_size 700, 380
        set_window_position :center
    end
    
    def deselect n
        if !@game.started then
            @game.started = !@game.started
            @game.start_time = @timer.elapsed[0]
        end
        if @game.getSelected==n then
            @game.setSelected nil
        else
            if @tiles[n].getTile==nil and @game.getSelected != nil then
                @tiles[n].setTile @tiles[@game.getSelected].getTile
                @tiles[@game.getSelected].setTile nil
            else
                @game.setSelected n
            end
        end
        for i in 0..17 do
            if @game.getSelected!=nil and @game.getSelected!=@tiles[i].getNumber then
                @tiles[i].setSelected false
            end
            @tiles[i].queue_draw
        end
        check
    end
    
    def check
        nine=true
        for i in 0..8 do
            if @tiles[i].getTile==nil then
                nine=false
                break
            end
        end
        if nine then
            done=true
            for i in 0..8 do
                if @tiles[i].getTile != @game.getTiles[i] then
                   done=false
                   break
                end
            end
            if done then
                @game.stop_time = @timer.elapsed[0]
                #puts @game.stop_time
                md = Gtk::MessageDialog.new self, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::INFO,  Gtk::MessageDialog::BUTTONS_OK, "Nice work!\nYour time: "+@game.stop_time.truncate.to_s+" s"
                md.run
                md.destroy
            end
        end
    end
end

Gtk.init
window = MainWindow.new
Gtk.main
