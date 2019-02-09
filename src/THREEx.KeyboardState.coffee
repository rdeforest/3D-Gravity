# THREEx.KeyboardState.js keep the current state of the keyboard.
# It is possible to query it at any time. No need of an event.
# This is particularly convenient in loop driven case, like in
# 3D demos or games.
#
# # Usage
#
# **Step 1**: Create the object
#
# ```var keyboard	= new THREEx.KeyboardState();```
#
# **Step 2**: Query the keyboard state
#
# This will return true if shift and A are pressed, false otherwise
#
# ```keyboard.pressed("shift+A")```
#
# **Step 3**: Stop listening to the keyboard
#
# ```keyboard.destroy()```
#
# NOTE: this library may be nice as standaline. independant from three.js
# - rename it keyboardForGame
#
# # Code
#

###* @namespace ###

THREEx = THREEx or {}

###*
# - NOTE: it would be quite easy to push event-driven too
#   - microevent.js for events handling
#   - in this._onkeyChange, generate a string from the DOM event
#   - use this as event name
###

#THREEx.KeyboardState = ->
class THREEx.KeyboardState
  constructor: ->
    # to store the current state
    @keyCodes  = {}
    @modifiers = {}
    # create callback to bind/unbind keyboard events
    self       = this

    @_onKeyDown = (event) ->
      self._onKeyChange event, true
      return

    @_onKeyUp = (event) ->
      self._onKeyChange event, false
      return

    # bind keyEvents
    document.addEventListener 'keydown', @_onKeyDown, false
    document.addEventListener 'keyup',   @_onKeyUp,   false

# To stop listening of the keyboard events

  destroy: ->
    # unbind keyEvents
    document.removeEventListener 'keydown', @_onKeyDown, false
    document.removeEventListener 'keyup',   @_onKeyUp,   false
    return

  @MODIFIERS = [
      'shift'
      'ctrl'
      'alt'
      'meta'
    ]

  @ALIAS =
    'left':     37
    'up':       38
    'right':    39
    'down':     40
    'space':    32
    'pageup':   33
    'pagedown': 34
    'tab':      9

# to process the keyboard dom event

  _onKeyChange: (event, pressed) ->
    # log to debug
    #console.log("onKeyChange", event, pressed, event.keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)
    
    # update this.keyCodes
    keyCode = event.keyCode
    @keyCodes[keyCode] = pressed

    # update this.modifiers
    @modifiers['shift'] = event.shiftKey
    @modifiers['ctrl']  = event.ctrlKey
    @modifiers['alt']   = event.altKey
    @modifiers['meta']  = event.metaKey
    return

# query keyboard state to know if a key is pressed of not
#
# @param {String} keyDesc the description of the key. format : modifiers+key e.g shift+A
# @returns {Boolean} true if the key is pressed, false otherwise

  pressed: (keyDesc) ->
    for key in keyDesc.split('+')
      pressed = undefined

      if THREEx.KeyboardState.MODIFIERS.indexOf(key) != -1
        pressed = @modifiers[key]
      else if Object.keys(THREEx.KeyboardState.ALIAS).indexOf(key) != -1
        pressed = @keyCodes[THREEx.KeyboardState.ALIAS[key]]
      else
        pressed = @keyCodes[key.toUpperCase().charCodeAt(0)]

      if !pressed
        return false

    true
