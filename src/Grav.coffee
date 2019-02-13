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

    @numParticles = 10

    @maxSize      = 5
    @gravConstant = 2
    @showArrow    = true
    @running      = true

    @cameraFactor = 1/50
    @cameraShift  = 100

    @setValuesOf
      numparticles: @numParticles
      gravstr:      @gravConstant * 100
      maxSize:      @maxSize

    if @window.WebGLRenderingContext
      @renderer = new (THREE.WebGLRenderer)
    else
      @renderer = new (THREE.CanvasRenderer)

    menuHeight = @document.body.children[0].clientHeight
    @renderer.setSize @window.innerWidth, @window.innerHeight - menuHeight

    @init()

    @document.body.appendChild @renderer.domElement

  # Stuff that also gets reset by the reset button
  init: ->
    @largestSize  = 0
    @cooldown     = 0

    @scene        = new THREE.Scene
    @keyboard     = new THREEx.KeyboardState

    @lastFrameMS  = Date.now()

    randRange = (lower, upper) -> Math.random() * (upper - lower) + lower

    randPos = ->
      [ randRange -20, 20
        randRange -20, 20
        randRange -0, 0
      ]

    randVel = ->
      [ randRange -50, 50
        randRange -50, 50
        randRange -1, 1
      ]

    {maxSize} = @

    @particles = [1..@numParticles].map ->
      new Particle
        radius:   10 ** (randRange(1, maxSize) / 5)
        position: Vector.fromArray randPos()
        velocity: Vector.fromArray randVel()

    @particles
      .unshift @sun = new Particle
        radius: 30
        position: new Vector
        velocity: new Vector

    @largestSize = Math.max ( @particles.map (p) -> p.radius )...

    dir    = new THREE.Vector3 1, 0, 0
    origin = new THREE.Vector3 0, 0, 0
    length = 1
    color  = 0xcf171d # a sort of pink?

    @arrowHelper             = new THREE.ArrowHelper dir, origin, length, color
    @camera                  = new THREE.PerspectiveCamera 75, @window.innerWidth / @window.innerHeight, 0.1, 1000000
    @delta                   = new Vector

    setPosition @camera,      x: 0, y: 0, z: 600
    setPosition @arrowHelper, x: 0, y: 0, z: 0

    @scene.add mesh for {mesh} in @particles

    #@scene.add @arrowHelper

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
    ###
    h: ->
      @window.alert '''
        This is a three dimensional particles simulator that is run using
        Newton\'s definition for the force of gravity and three.js. If you
        want to mess with different settings, enter numbers into the boxes and
        press reload. The vector at the center of the screen shows the
        direction that the camera is currently moving. You can move the camera
        with w, a, s, and d, and zoom in and out with j and k, respectively.
        Use l to toggle the camera vector.
      '''
    ###
    d: -> @shiftCamera x: +1
    a: -> @shiftCamera x: -1
    w: -> @shiftCamera y: +1
    s: -> @shiftCamera y: -1
    j: -> @shiftCamera z: +1
    k: -> @shiftCamera z: -1
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

  computeMeanVelocity: ->
    total = 0
    for p in @particles
      total += p.velocity.mag()

    total / @numParticles

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
    {x, y, z} = @camera.position
    if false
      {x: x2, y: y2, z: z2} = @computeCenterOfMass().plus @delta
    else
      {x: x2, y: y2, z: z2} = @sun.position
   
    x += (x2 - x) * @cameraFactor
    y += (y2 - y) * @cameraFactor
    z += (z2 - z) * @cameraFactor

    z += @largestSize * 40

    setPosition @camera,      {x, y, z}
    setPosition @arrowHelper, {x, y, z}

    zOffset = if @showArrow then -3 else 600
    @arrowHelper.position.x += zOffset

    direction = new THREE.Vector3 x, y, z
    @arrowHelper.setDirection direction.normalize()
    @arrowHelper.setLength    direction.length()

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
    @numParticles = (@getValueOf 'numparticles')
    @gravConstant = (@getValueOf 'gravstr'     ) / 100
    @maxSize      = (@getValueOf 'maxSize'     )

    #@particles = []
    #@scene = new THREE.Scene
    @init()
    return @
  ).bind app
