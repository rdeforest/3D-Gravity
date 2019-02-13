randLetter  = -> '0123456789ABCDEF'[Math.floor Math.random() * 16]

randomColor = ->
  ['#'] .concat [1..6].map randLetter
        .join ''

randomValue = (min, max) ->
  dif = max - min + 1
  min + Math.floor Math.random() * dif

randomColor = ->
  "#" +
    [0..2]
      .map -> (randomValue 128, 255).toString 16
      .join ''

# TODO: add getters/setters
class Particle
  constructor: ({ @position = new Vector
                  @velocity = new Vector
                  @radius = 1} = {}) ->

    @acceleration  = new Vector

    @radiusSquared = @radius ** 2
    @mass          = @radius ** 3

    @mesh          = new THREE.Mesh(
        new THREE.SphereGeometry    @radius * 20
        new THREE.MeshBasicMaterial color: randomColor()
      )

  diff: (other) -> @position.sub other.position

  tick: (t = 1) ->
    @velocity = @velocity.add @acceleration.scale t
    @position = @position.add @velocity    .scale t

    @acceleration = new Vector

    @mesh.translateX @velocity.x
    @mesh.translateY @velocity.y
    @mesh.translateZ @velocity.z

  push: (a) ->
    @acceleration.add a

if 'undefined' isnt typeof exports
  module.exports = Particle
else
  window.Particle = Particle
