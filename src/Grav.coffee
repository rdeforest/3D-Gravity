if 'function' is typeof require
  THREE    = require 'three'

  Vector   = require './vector'
  Particle = require './particle'

  Math     = (require './extend-math') { Math }

setPosition = (o, {x, y, z}) ->
  (o.position[k] = v) for k, v of {x, y, z}
  return

class GravApp
  constructor: (@window) ->
    {@document} = @window

    @numParticles = 200

    @maxSize      = 5
    @gravConstant = 1
    @showArrow    = false
    @running      = true

    @init()

    @document.body.appendChild @renderer.domElement

  # Stuff that gets reset by the reset button
  init: ->
    @setValuesOf
      numparticles: @numParticles
      gravstr:      @gravConstant * 100
      maxSize:      @maxSize

    @largestSize  = 0
    @cooldown     = 0
    @cameraShift  = 10

    @scene        = new THREE.Scene
    @keyboard     = new THREEx.KeyboardState

    @tick         = 0
    @lastFrameMS  = Date.now()

    if @window.WebGLRenderingContext
      @renderer = new (THREE.WebGLRenderer)
    else
      @renderer = new (THREE.CanvasRenderer)

    menuHeight = @document.body.children[0].clientHeight
    @renderer.setSize @window.innerWidth, @window.innerHeight - menuHeight

    randRange = (lower, upper) -> Math.random() * (upper - lower) + lower

    {maxSize} = @
    @particles = [1..@numParticles].map ->
      new Particle
        radius:   randRange 1, maxSize
        position: Vector.fromArray [randRange(-20, 20), randRange(-20, 20), 0]
        velocity: Vector.fromArray [randRange(-20, 20), randRange(-20, 20), 0]

    @largestSize = Math.max ( @particles.map (p) -> p.radius )...

    dir    = new THREE.Vector3 1, 0, 0
    origin = new THREE.Vector3 0, 0, 0
    length = 1
    color  = 0xcf171d # a sort of pink?

    @arrowHelper             = new THREE.ArrowHelper dir, origin, length, color
    @camera                  = new THREE.PerspectiveCamera 75, @window.innerWidth / @window.innerHeight, 0.1, 1000000
    @delta                   = new Vector

    setPosition @camera,      x: 0, y: 0, z: 300
    setPosition @arrowHelper, x: 0, y: 0, z: 300

    @scene.add mesh for {mesh} in @particles

    #app
    #  .scene
    #  .add @arrowHelper

    return @

  shiftCamera: (axisAndDir) ->
    for axis, dir of axisAndDir
      @delta[axis] += @cameraShift * dir

  setValuesOf: (nameAndValue) ->
    for name, value of nameAndValue
      Object.assign (@document.getElementById name), {value}

  getValueOf: (name) ->
    @document
      .getElementById name
      .value

  hotKeys:
    h: -> @window.alert '''
      This is a three dimensional particles simulator that is run using
      Newton\'s definition for the force of gravity and three.js. If you want to
      mess with different settings, enter numbers into the boxes and press
      reload. The vector at the center of the screen shows the direction that
      the camera is currently moving. You can move the camera with w, a, s, and
      d, and zoom in and out with j and k, respectively. Use l to toggle the
      camera vector.
    '''
    d: -> shiftCamera x: +1
    a: -> shiftCamera x: -1
    w: -> shiftCamera y: +1
    s: -> shiftCamera y: -1
    j: -> shiftCamera z: +1
    k: -> shiftCamera z: -1
    l: ->
      if not @cooldown
        @showArrow = not @showArrow
        @cooldown = 5

  move: ->
    deltaT = 1/(@msPerFrame or 1)

    for a, i in @particles[      .. -2]
      for b  in @particles[i + 1 .. ]
        dif = a.diff b
        distSquared = dif.magSquared()
        gravity = @gravConstant / distSquared

        if distSquared >= a.radiusSquared + b.radiusSquared
          forceOfGravity = dif.scale gravity

          a.push forceOfGravity.scale -b.mass
          b.push forceOfGravity.scale  a.mass
        else
          # How should we handle collisions?
          # Merge the bodies? Bounce? Other?
          true

      # At the end of the b loop, a has been attracted by every particle before
      # and after it.
      a.tick deltaT

    return @


  handleKeypresses: ->
    op.call @ for key, op of @hotKeys when @keyboard.pressed key

    @cooldown-- if @cooldown > 0

  computeCenterOfMass: ->
    centerOfMass = [0, 0, 0]
    totalMass    = 0

    for p in @particles
      for axis, i in ['x', 'y', 'z']
        centerOfMass[i] += p.position[axis] * p.mass
      totalMass       += p.mass

    Vector.fromArray centerOfMass
      .scaled (1 / totalMass)

  updateView: ->
    {x, y, z} = @computeCenterOfMass().plus @delta
    z += @largestSize * 40
    console.log updateView:   {x, y, z}
    setPosition @camera,      {x, y, z}

    setPosition @arrowHelper, {x, y, z}

    zOffset = if @showArrow then -3 else 600
    @arrowHelper.position.x += zOffset

    direction = new THREE.Vector3 x, y, z
    @arrowHelper.setDirection direction.normalize()
    @arrowHelper.setLength    direction.length()

    @setValuesOf tick: @tick++

    @msPerFrame = (now = Date.now()) - @lastFrameMS
    @lastFrameMS = now

    return @

  start: ->
    @running = true
    @render()

  stop: ->
    @running = false

  render: ->
    if @running
      requestAnimationFrame => @render()
      @handleKeypresses()
      @move()
      @updateView()
      @renderer.render @scene, @camera
    return @

(app = new GravApp window)
  .start()

reInit = (->
    @tick         = 0
    @numParticles = (@getValueOf 'numparticles')
    @gravConstant = (@getValueOf 'gravstr'     ) / 100
    @maxSize      = (@getValueOf 'maxSize'     )

    @particles = []
    @scene = new THREE.Scene
    @init()
    return @
  ).bind app
