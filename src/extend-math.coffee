extender = ({Math, force}) ->
  MAX_RECURSION_DEPTH      = 48
  MAX_RECURSIVE_LENGTH = 2 ** 48 # because ECMAScript VMs don't like deep stacks
  MIN_RECURSIVE_LENGTH = 2 ** 4  # because recursing for less than 16 elements is silly

  _recursor = (fn, base) ->
    # For MIN_RECURSIVE_LENGTH <= xs.length < MAX_RECURSIVE_LENGTH
    _recurse =
      (xs) ->
        if xs.length is 2
          return fn xs[0], xs[1]

        m = xs.length >> 1

        xsLeft  = xs[..m - 1]
        xsRight = xs[m..]

        _recurse xsLeft  +
        _recurse xsRight

    outer = (xs...) ->
      # Only recurse on length 2 ** N lists
      total =
      if extraLen = xs.length % MIN_RECURSIVE_LENGTH
        extra    = xs[..extraLen - 1]
        xs       = xs[extraLen..]
        extra.reduce fn, base
      else
        0

      while xs.length
        total = fn total, _recurse xs[..MAX_RECURSIVE_LENGTH - 1]
        xs = xs[MAX_RECURSIVE_LENGTH..]

      total

  sum  = _recursor ((a, b) -> a + b), 0
  prod = _recursor ((a, b) -> a * b), 1
  max  = _recursor ((a, b) -> if a > b then a else b), undefined
  min  = _recursor ((a, b) -> if a < b then a else b), undefined

  if force
    Object.assign Math, {sum, prod, max, min}
  else
    Math.sum  ?= sum
    Math.prod ?= prod
    Math.max  ?= max
    Math.min  ?= min

if 'undefined' isnt typeof exports
  module.exports = extender
else
  extender {Math}
