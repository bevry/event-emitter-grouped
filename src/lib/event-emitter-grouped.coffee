# Import
EventEmitter = require('events').EventEmitter
ambi = require('ambi')
{TaskGroup} = require('taskgroup')

# Group
# Allows you to emit events in serial or parallel
class EventEmitterGrouped extends EventEmitter

	# Get Listener Group
	# Fetch the listeners for a particular event as a task group
	# next(err,results)
	getListenerGroup: (eventName,args...,next) ->
		# Get listeners
		me = @
		listeners = @listeners(eventName)

		# Prepare tasks
		tasks = new TaskGroup().once('complete', next)

		# Sort the listeners by highest priority first
		listeners.sort (a,b) ->
			return (b.priority or 0) - (a.priority or 0)

		# Add the tasks for the listeners
		listeners.forEach (listener) ->
			# The `once` method will actually wrap around the original listener, which isn't what we want for the introspection
			# So we must pass fireWithOptionalCallback an array of the method to fire, and the method to introspect
			# https://github.com/bevry/docpad/issues/462
			# https://github.com/joyent/node/commit/d1b4dcd6acb1d1c66e423f7992dc6eec8a35c544
			if listener.listener
				listener = [listener.bind(me), listener.listener]
			else
				listener = listener.bind(me)

			# Bind to the task
			tasks.addTask (complete) ->
				# Fire the listener, treating the callback as optional
				ambi(listener, args..., complete)

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