require "ruby2d"

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
  WIDTH = 32 * 3
  HEIGHT = 46 * 3

  # allow rest of codebase to read position of player chars
  attr_reader :x, :y, :speed, :fire_rate

  # can refactor arguments to, player type/descendent class, x, y position
  def initialize(image, x, y, speed, fire_rate)
    @x = x
    @y = y
    @speed = speed
    @fire_rate = fire_rate
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
    title_text = Text.new('ASTEROIDS', size: 72, y: 40)
    # Centers text using width of screen, x marks beginning of where object will display
    title_text.x = (Window.width - title_text.width) / 2

    # Text object for subtitle text, 32 font size, centered
    title_text = Text.new('SELECT YOUR PLAYER', size: 32, y: 120)
    title_text.x = (Window.width - title_text.width) / 2

    # put these values somewhere within player class, maybe descendent classes
    # Creating sprites for each player icon 
    @players = [
      Player.new('spritesheets/shipsheet_1.png', Window.width * (1/4.0) - Player::WIDTH / 2, 240, 80, 80),
      Player.new('spritesheets/shipsheet_2.png', Window.width * (2/4.0) - Player::WIDTH / 2, 240, 100, 60),
      Player.new('spritesheets/shipsheet_3.png', Window.width * (3/4.0) - Player::WIDTH / 2, 240, 60, 100)
    ]

    # set player object as selected playerso with_index doesn't have to be used, maybe as active? attribute of player object
    # set middle player as default selection
    @selected_player = 1

    # update player animation speed/masks
    animate_players
    add_player_masks
    set_player_stat_text
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
    @players.each_with_index do |player, index|
      if index == @selected_player
        player.animate_fast
      else
        player.animate_slow
      end
    end
  end

  # Changing selected player based on key which triggered method
  def move(direction)
    if direction == :left
      @selected_player = (@selected_player - 1) % 3
    elsif direction == :right
      @selected_player = (@selected_player + 1) % 3
    end

    #move this block to some sort of update screen method
    # update player animation speed/masks
    animate_players
    add_player_masks
    set_player_stat_text
  end

  # private?

  # draw circles/highlights around each player sprite 
  def add_player_masks
    # block will remove masks if player masks are set
    @player_masks && @player_masks.each { |mask| mask.remove }

    # change color of circle and position (over or behind) based on selection
    @player_masks = @players.each_with_index.map do |player, index|
      if index == @selected_player
        color = [0.2, 0.2, 0.2, 0.6]
        z = -1
      else
        color = [0.0, 0.0, 0.0, 0.6]
        z = 2
      end

      Circle.new(
        radius: 100,
        # says how many triangles to use to draw circle, need more to make well formed circle
        sectors: 32,
        # set highlight/circle position based on players position
        # can move this out to method for Player class, x_center(optional_offset), y_center
        x: player.x + (Player::WIDTH / 2),
        y: player.y + (Player::HEIGHT / 2),
        color: color,
        z: z
      )
    end
  end

  # text objects displaying players stats
  def set_player_stat_text
    @players_stat_texts && @players_stat_texts.each { |text| text.remove }
    @players_stat_texts = []
    # maybe try to figure out how to do without with_index
    @players.each_with_index do |player, index|
      # set color for text based on if player is selected
      if index == @selected_player
        color = Color.new([1,1,1,1]) # white
      else
        color = Color.new([0.3,0.3,0.3,1]) # grey
      end

      # speed text displays player speed, below player sprite, color based on selected player
      speed_text = Text.new("Speed - #{player.speed}%", size: 20, y: player.y + 200, color: color)
      # consider moving these width - object width calculations to a position calculator within player class
      # set speed text x value to center on player
      speed_text.x = player.x + ((Player::WIDTH - speed_text.width)/2)

      fire_rate_text = Text.new("Fire rate - #{player.fire_rate}%", size: 20, y: player.y + 220, color: color )
      fire_rate_text.x = player.x + ((Player::WIDTH - fire_rate_text.width)/2)

      @players_stat_texts.push(speed_text)
      @players_stat_texts.push(fire_rate_text)
    end
  end
end

# creating new screen object
player_select_screen = PlayerSelectScreen.new

# update function called each frame
update do
  # PlayerSelectScreen#update
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
