// Import
const {EventEmitter} = require('events')
const {TaskGroup} = require('taskgroup')
const ambi = require('ambi')

/**
Events EventEmitter to allow you to execute events in serial or parallel.
Made possible thanks to TaskGroup.

Inherits from https://nodejs.org/dist/latest/docs/api/events.html#events_class_eventemitter

Uses https://github.com/bevry/taskgroup

@class EventEmitterGrouped
@extends EventEmitter
@constructor
@access public
*/
class EventEmitterGrouped extends EventEmitter {

	/**
	Get a TaskGroup for a particular event.
	For each listener, treat them as Tasks within a TaskGroup, and return the TaskGroup.
	@param {string} eventName
	@param {...*} args - the arguments to forward to each task, with the last one being a completion callback with signature `error, results`
	@returns {TaskGroup}
	@access public
	*/
	getListenerGroup (eventName, ...args) {
		// Get listeners
		const next = args.pop()
		const me = this

		// Prepare tasks
		const tasks = new TaskGroup(`EventEmitterGrouped for ${eventName}`).done(next)

		// Convert the listeners into objects that we can use
		const listenerObjects = this.listeners(eventName).slice().map((listener) => {
			// Prepare
			const listenerObject = {}

			// The `once` method will actually wrap around the original listener, which isn't what we want for the introspection
			// So we must pass fireWithOptionalCallback an array of the method to fire, and the method to introspect
			// https://github.com/bevry/docpad/issues/462
			// https://github.com/joyent/node/commit/d1b4dcd6acb1d1c66e423f7992dc6eec8a35c544
			if ( listener.listener ) {  // this is a `once` thing
				listenerObject.actual = listener.listener
				listenerObject.fire   = [listener.bind(me), listener.listener]
			}
			else {
				listenerObject.actual = listener
				listenerObject.fire   = listener.bind(me)
			}

			// Defaults
			listenerObject.priority = listenerObject.actual.priority || 0
			listenerObject.name     = listenerObject.name || `Untitled listener for [${eventName}] with priority [${listenerObject.priority}]`

			// Return the new listenerObject
			return listenerObject
		})

		// Sort the listeners by highest priority first
		listenerObjects.sort((a, b) => b.priority - a.priority)

		// Add the tasks for the listeners
		listenerObjects.forEach(function (listenerObject) {
			// Bind to the task
			tasks.addTask(listenerObject.name, function (complete) {
				// Fire the listener, treating the callback as optional
				ambi(listenerObject.fire, ...args, complete)
			})
		})

		// Return
		return tasks
	}

	/**
	Refer to EventEmitter#removeListener
	https://nodejs.org/dist/latest/docs/api/events.html#events_emitter_removelistener_eventname_listener
	@returns {*} whatever removeListener returns
	@access public
	*/
	off (...args) {
		return this.removeListener(...args)
	}

	/**
	Runs the listener group for the event in serial mode (one at a time)
	@param {...*} args - forwarded to {@link EventEmitterGrouped#getListenerGroup}
	@returns {TaskGroup}
	*/
	emitSerial (...args) {
		return this.getListenerGroup(...args).run()
	}

	/**
	Runs the listener group for the event in parallel mode (multiple at a time)
	@param {...*} args - forwarded to {@link EventEmitterGrouped#getListenerGroup}
	@returns {TaskGroup}
	*/
	emitParallel (...args) {
		return this.getListenerGroup(...args).setConfig({concurrency: 0}).run()
	}
}

// Export
EventEmitterGrouped.EventEmitterGrouped = EventEmitterGrouped  // backwards compatability
module.exports = EventEmitterGrouped
