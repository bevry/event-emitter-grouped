'use strict'

// Import
const { equal, errorEqual } = require('assert-helpers')
const { EventEmitterGrouped } = require('./')
const kava = require('kava')

// =====================================
// Event Emitter Enhanced

kava.suite('EventEmitterGrouped', function (suite, test) {
	let eventEmitter = null

	test('should construct', function () {
		eventEmitter = new EventEmitterGrouped()
	})

	// Serial
	test('should work in serial', function (done) {
		// Prepare
		let first = 0,
			second = 0

		// Asynchronous
		eventEmitter.on('serial-test', function (opts, next) {
			++first
			setTimeout(function () {
				equal(second, 0)
				++first
				next()
			}, 500)
		})

		// Synchronous
		eventEmitter.on('serial-test', function () {
			equal(first, 2)
			second += 2
		})

		// Correct amount of listeners?
		equal(eventEmitter.listeners('serial-test').length, 2)

		// Emit and check
		eventEmitter.emitSerial('serial-test', null, function (err) {
			errorEqual(err, null)
			equal(first, 2)
			equal(second, 2)
			done()
		})
	})

	// Parallel
	test('should work in parallel', function (done) {
		// Prepare
		let first = 0,
			second = 0

		// Asynchronous
		eventEmitter.on('parallel-test', function (opts, next) {
			++first
			setTimeout(function () {
				equal(second, 2)
				++first
				next()
			}, 500)
		})

		// Synchronous
		eventEmitter.on('parallel-test', function () {
			equal(first, 1)
			second += 2
		})

		// Correct amount of listeners?
		equal(eventEmitter.listeners('parallel-test').length, 2)

		// Emit and check
		eventEmitter.emitParallel('parallel-test', null, function (err) {
			errorEqual(err, null)
			equal(first, 2)
			equal(second, 2)
			done()
		})
	})

	// Parallel
	test('should work with once', function (done) {
		// Prepare
		let first = 0,
			second = 0

		// Asynchronous
		eventEmitter.once('once-test', function (opts, next) {
			++first
			setTimeout(function () {
				equal(second, 2, 'asynchronous callback: second value')
				++first
				next()
			}, 500)
		})

		// Synchronous
		eventEmitter.once('once-test', function () {
			equal(first, 1, 'synchronous callback: first value')
			second += 2
		})

		// Correct amount of listeners?
		equal(
			eventEmitter.listeners('once-test').length,
			2,
			'commencement: remaining listening'
		)

		// Emit and check
		eventEmitter.emitParallel('once-test', null, function (err) {
			errorEqual(err, null)
			equal(first, 2, 'completion callback: first value')
			equal(second, 2, 'completion callback: second value')
			equal(
				eventEmitter.listeners('once-test').length,
				0,
				'completion callback: remaining listeners'
			)
			done()
		})
	})

	// Off
	test('should work with off', function (done) {
		// Prepare
		let counterA = 0,
			counterB = 0
		function listenerA() {
			equal(counterA, 0)
			equal(counterB, 0)
			++counterA
		}
		function listenerB() {
			equal(counterA, 0)
			equal(counterB, 0)
			++counterB
		}

		// Synchronous
		eventEmitter.on('off-test', listenerA)

		// Synchronous
		eventEmitter.on('off-test', listenerB)

		// Correct amount of listeners?
		equal(eventEmitter.listeners('off-test').length, 2)

		// Remove and check again
		eventEmitter.off('off-test', listenerA)
		equal(eventEmitter.listeners('off-test').length, 1)

		// Emit and check
		eventEmitter.emitSerial('off-test', null, function (err) {
			errorEqual(err, null)
			equal(counterA, 0)
			equal(counterB, 1)
			done()
		})
	})

	// Priorities
	test('should work with priorities', function (done) {
		// Prepare
		let counterA = 0,
			counterB = 0,
			counterC = 0

		// Exec First
		function listenerA() {
			equal(counterA, 0)
			equal(counterB, 0)
			equal(counterC, 0)
			++counterA
		}
		listenerA.priority = 500
		eventEmitter.on('priority-test', listenerA)

		// Exec Last
		function listenerB() {
			equal(counterA, 1)
			equal(counterB, 0)
			equal(counterC, 1)
			++counterB
		}
		listenerB.priority = 300
		eventEmitter.on('priority-test', listenerB)

		// Exec Second
		function listenerC() {
			equal(counterA, 1)
			equal(counterB, 0)
			equal(counterC, 0)
			++counterC
		}
		listenerC.priority = 400
		eventEmitter.on('priority-test', listenerC)

		// Correct amount of listeners?
		equal(eventEmitter.listeners('priority-test').length, 3)

		// Emit and check
		eventEmitter.emitSerial('priority-test', null, function (err) {
			errorEqual(err, null)
			equal(counterA, 1)
			equal(counterB, 1)
			equal(counterC, 1)
			done()
		})
	})
})
