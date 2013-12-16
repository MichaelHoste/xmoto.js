# xmoto c++ version constants

class CppConstants

  @init: ->

    # world constants
    @world =
      gravity:         9.81
      mass_elevation : 0.9
  
    # anchors constants
    @rider =
  
      # anchors
      elbow:
        position:
          x: -0.1
          y:  0.6
        axe: []
      shoulder:
        position:
          x: -0.2
          y:  1.1
        axe: []
      wrist:
        position:
          x: 0.3
          y: 0.45
        axe: []
      hip:
        position:
          x: -0.3
          y:  0.4
        axe: []
      knee:
        position:
          x: 0.3
          y: 0.2
        axe: []
      ankle:
        position:
          x:  0.0
          y: -0.37
        axe: []
  
      # head
      head:
        radius:       0.18
        neck_length : 0.22
        neck_axe :
          x: 0
          y: 0
        position: [] # computed later
  
      # members
      torso:     [] # computed later
      lower_leg: [] # computed later
      upper_leg: [] # computed later
      lower_arm: [] # computed later
      upper_arm: [] # computed later
  
    @moto =
      wheel:
        radius: 0.35
        base:   1.4
        position: [] # computed later
      body:
        position:
          x: 0
          y: @world.mass_elevation
  
    @moto.wheel.position =
      x: 0.5*@moto.wheel.base
      y: @moto.wheel.radius
  
    # compute head position
    backdiff =
      x: @rider.shoulder.position.x - @rider.hip.position.x
      y: @rider.shoulder.position.y - @rider.hip.position.y
    backdiff_norm = Math2D.normalize(backdiff)
    
    @rider.head.position =
      x: @rider.shoulder.position.x + @rider.head.neck_length*backdiff_norm.x
      y: @rider.shoulder.position.y + @rider.head.neck_length*backdiff_norm.y + @world.mass_elevation
  
    @rider.torso =
      position:
        x: (@rider.hip.position.x + @rider.shoulder.position.x)/2
        y: (@rider.hip.position.y + @rider.shoulder.position.y)/2 + @world.mass_elevation
  
    @rider.lower_leg =
      position:
        x: (@rider.ankle.position.x + @rider.knee.position.x)/2
        y: (@rider.ankle.position.y + @rider.knee.position.y)/2 + @world.mass_elevation
  
    @rider.upper_leg =
      position:
        x: (@rider.hip.position.x + @rider.knee.position.x)/2
        y: (@rider.hip.position.y + @rider.knee.position.y)/2 + @world.mass_elevation
  
    @rider.lower_arm =
      position:
        x: (@rider.elbow.position.x + @rider.wrist.position.x)/2
        y: (@rider.elbow.position.y + @rider.wrist.position.y)/2 + @world.mass_elevation
  
    @rider.upper_arm =
      position:
        x: (@rider.elbow.position.x + @rider.shoulder.position.x)/2
        y: (@rider.elbow.position.y + @rider.shoulder.position.y)/2 + @world.mass_elevation
  
    @rider.ankle.axe =
      x: @rider.ankle.position.x-(@rider.ankle.position.x + @rider.knee.position.x)/2
      y: @rider.ankle.position.y-(@rider.ankle.position.y + @rider.knee.position.y)/2
  
    @rider.wrist.axe =
      x: @rider.wrist.position.x-(@rider.elbow.position.x + @rider.wrist.position.x)/2
      y: @rider.wrist.position.y-(@rider.elbow.position.y + @rider.wrist.position.y)/2
  
    @rider.knee.axe =
      x:  @rider.knee.position.x-(@rider.ankle.position.x + @rider.knee.position.x)/2
      y:  @rider.knee.position.y-(@rider.ankle.position.y + @rider.knee.position.y)/2
  
    @rider.elbow.axe =
      x: @rider.elbow.position.x-(@rider.elbow.position.x+@rider.shoulder.position.x)/2
      y: @rider.elbow.position.y-(@rider.elbow.position.y+@rider.shoulder.position.y)/2
  
    @rider.shoulder.axe =
      x: @rider.shoulder.position.x-(@rider.elbow.position.x+@rider.shoulder.position.x)/2
      y: @rider.shoulder.position.y-(@rider.elbow.position.y+@rider.shoulder.position.y)/2
  
    @rider.hip.axe =
      x: @rider.hip.position.x-(@rider.hip.position.x + @rider.knee.position.x)/2
      y: @rider.hip.position.y-(@rider.hip.position.y + @rider.knee.position.y)/2
