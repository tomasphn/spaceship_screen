require "ruby2d"
require "pry"

set title: "Asteroids"
set width: 800
set height: 600

class Star
  def initialize
    # -5..0 as velocity to alter y position by that much per update
    @y_velocity = rand(-5..0)
    # Create circle object, random position/color, 1 or 2 pixels
    @shape = Circle.new(
      x: rand(Window.width),
      y: rand(Window.height),
      # ensures stars are behind all masks and player sprites
      z: -2,
      radius: rand(1..2),
      color: 'random')
  end

  def move
    # change y position by velocity
    # Window height makes sure that y position doesnt move out of bounds of window, wraps back
    @shape.y = (@shape.y + @y_velocity) % Window.height
  end
end

class Player
  # pixel h/w of each individual sprite on spritesheet, *3 because theres 3 sprites per sheet
  WIDTH = 32 * 3
  HEIGHT = 46 * 3

  # allow rest of codebase to read position of player chars
  attr_reader :x, :y, :label

  def initialize(image, x, y, label)
    @x = x
    @y = y
    @label = label
    # Sprite is created with image file name and given position
    @sprite = Sprite.new(
      image,
      clip_width: 32,
      width: WIDTH,
      height: HEIGHT,
      x: x,
      y: y,
      rotate: 180,
      # Defining animations specifying which versions of image to cycle
      animations: {
        moving_slow: 1..2,
        moving_fast: 3..4
      }
    )
  end

  def animate_slow
    @sprite.play(animation: :moving_slow, loop: true)
  end

  def animate_fast
    @sprite.play(animation: :moving_fast, loop: true)
  end
end

class PlayerSelectScreen
  def initialize
    # Create 100 stars stored by screen
    @stars = Array.new(100).map { Star.new }

    # Text object which displays Title, 72 font size
    title_text = Text.new('Portfolio Site', size: 72, y: 50, font: "fasthand.ttf")
    # Centers text using width of screen, x marks beginning of where object will display
    title_text.x = (Window.width - title_text.width) / 2

    # Text object for subtitle text, 32 font size, centered
    title_text = Text.new('SELECT YOUR PLAYER', size: 50, y: 120, font: "chronosfer.otf")
    title_text.x = (Window.width - title_text.width) / 2

    # put these values somewhere within player class, maybe descendent classes
    # Creating sprites for each player icon 
    @players = [
      Player.new('images/ship_1.png', Window.width * (1/4.0) - Player::WIDTH / 2, 240, "Work"),
      Player.new('images/ship_2.png', Window.width * (2/4.0) - Player::WIDTH / 2, 240, "Projects"),
      Player.new('images/ship_3.png', Window.width * (3/4.0) - Player::WIDTH / 2, 240, "About Me")
    ]

    # set middle player as default selection
    @selected_player = @players[1]
    # Initial setup of labels and masks
    set_player_masks
    set_player_labels
  
    # update color of label/masks/animation based on selection
    update_players
  end

  def update
    # only update every other frame to slow down movement
    if Window.frames % 2 == 0
      # Update each stars y position
      @stars.each { |star| star.move }
    end
  end

  # makes player play specific animation depending on hover
  def animate_players
    @players.each do |player, index|
      if player == @selected_player
        player.animate_fast
      else
        player.animate_slow
      end
    end
  end

  # Changing selected player based on key which triggered method
  def move(direction)
    if direction == :left
      @selected_player = @players[(@players.index(@selected_player) - 1) % 3]
    elsif direction == :right
      @selected_player = @players[(@players.index(@selected_player) + 1) % 3]
    end
    # update player animation speed/masks
    update_players
  end

  # private?

  # draw circles/highlights around each player sprite 
  def set_player_masks
    @player_masks = @players.map do |player|
      Circle.new(
        radius: 100,
        # says how many triangles to use to draw circle, need more to make well formed circle
        sectors: 32,
        # set highlight/circle position based on players position
        x: player.x + (Player::WIDTH / 2),
        y: player.y + (Player::HEIGHT / 2),
      )
    end
  end

  # initially set player labels 
  def set_player_labels
    @player_labels = @players.map do |player|
      # creates player label below player sprite, color based on selected player
      player_label = Text.new(player.label, size: 40, y: player.y + 180, font: "chronosfer.otf")
      # set label text x value to center on player
      player_label.x = player.x + ((Player::WIDTH - player_label.width)/2)
      player_label
    end
  end

  # updates color of masks and labels based on selection
  def update_labels_highlights
    @players.each_with_index do |player, index|
      if player == @selected_player
        @player_labels[index].color = Color.new([1,1,1,1]) # white
        @player_masks[index].color = Color.new([0.2, 0.2, 0.2, 0.6]) # light grey
        @player_masks[index].z = -1
      else
        @player_labels[index].color = Color.new([0.3,0.3,0.3,1]) # grey
        @player_masks[index].color = Color.new([0.0, 0.0, 0.0, 0.6]) # black
        @player_masks[index].z = 2
      end
    end
  end

  # updates player animations, masks and under text
  def update_players
    animate_players
    update_labels_highlights
  end
end

# creating new screen object
player_select_screen = PlayerSelectScreen.new

# update function called each frame
update do
  player_select_screen.update
end

# when key is pressed
on :key_down do |event|
  case event.key
  when 'left'
    player_select_screen.move(:left)
  when 'right'
    player_select_screen.move(:right)
  end
end

# displays active objects
show
