# '?' handles both undefined and null
selfOrPrevOrFirstOrZero = (d, i, l) ->
    d        ?
    l[i - 1] ?
    l[0]     ?
    0

callIfFunction = (f) -> if typeof f is 'function' then f() else f

class Vector
  @AxisNames:  'xyz'

  @fromFunction: (f) -> new @ f(), f(), f()
  @fromArray:  (v) -> new @ v...

  constructor: (@x = 0, @y = 0, @z = 0) ->

  magSquared:  -> @x ** 2 + @y ** 2 + @z ** 2
  mag:         -> Math.sqrt @magSquared()

  # non-mutating
  copy:       -> new Vector @
  plus:   (v) -> new Vector (@[d] + v[d] for d in Vector.AxisNames)...
  scaled: (s) -> new Vector @x * s, @y * s, @z * s
  neg:        -> new Vector -@x, -@y, -@z
  minus:  (v) -> @plus v.neg()

  # mutating
  add:    (v) -> @[d] += v[d] for d in Vector.AxisNames; @
  sub:    (v) -> @[d] -= v[d] for d in Vector.AxisNames; @
  scale:  (s) -> @[d] *= s for d in Vector.AxisNames; @

if 'undefined' isnt typeof exports
  module.exports = Vector
else
  window.Vector = Vector
