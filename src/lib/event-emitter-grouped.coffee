# Import
events = if window? then require('events-browser') else require('events')
ambi = require('ambi')
{TaskGroup} = require('taskgroup')

# Group
# Allows you to emit events in serial or parallel
class EventEmitterGrouped extends events.EventEmitter

	# Get Listener Group
	# Fetch the listeners for a particular event as a task group
	# next(err,results)
	getListenerGroup: (eventName,args...,next) ->
		# Get listeners
		me = @

		# Prepare tasks
		tasks = new TaskGroup("EventEmitterGrouped for #{eventName}").done(next)

		# Convert the listeners into objects that we can use
		listenerObjects = @listeners(eventName).slice().map (listener) ->
			# Prepare
			listenerObject = {}

			# The `once` method will actually wrap around the original listener, which isn't what we want for the introspection
			# So we must pass fireWithOptionalCallback an array of the method to fire, and the method to introspect
			# https://github.com/bevry/docpad/issues/462
			# https://github.com/joyent/node/commit/d1b4dcd6acb1d1c66e423f7992dc6eec8a35c544
			if listener.listener  # this is a `once` thing
				listenerObject.actual = listener.listener
				listenerObject.fire   = [listener.bind(me), listener.listener]
			else
				listenerObject.actual = listener
				listenerObject.fire   = listener.bind(me)

			# Defaults
			listenerObject.priority = listenerObject.actual.priority or 0
			listenerObject.name     = listenerObject.name or "Untitled listener for [#{eventName}] with priority [#{listenerObject.priority}]"

			# Return the new listenerObject
			return listenerObject

		# Sort the listeners by highest priority first
		listenerObjects.sort (a,b) ->
			return b.priority - a.priority

		# Add the tasks for the listeners
		listenerObjects.forEach (listenerObject) ->
			# Bind to the task
			tasks.addTask listenerObject.name, (complete) ->
				# Fire the listener, treating the callback as optional
				ambi(listenerObject.fire, args..., complete)

		# Return
		return tasks

	# Off
	off: (args...) -> @removeListener(args...)

	# Emit Serial
	emitSerial: (args...) -> @getListenerGroup(args...).run()

	# Emit Parallel
	emitParallel: (args...) -> @getListenerGroup(args...).setConfig({concurrency:0}).run()

# Attach
attach = (somethingElse) ->
	for own key,value of EventEmitterGrouped::
		somethingElse[key] = value
	return somethingElse

# Inherit Into
inheritInto = (somethingElse) ->
	return util.inherits(somethingElse, EventEmitterGrouped)

# Export
module.exports = {EventEmitterGrouped, attach, inheritInto}