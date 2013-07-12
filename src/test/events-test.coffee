# Import
{expect,assert} = require('chai')
joe = require('joe')
{EventEmitterGrouped} = require('../../')


# =====================================
# Event Emitter Enhanced

joe.describe 'EventEmitterGrouped', (describe,it) ->
	eventEmitter = null

	it 'should construct', ->
		eventEmitter = new EventEmitterGrouped()

	# Serial
	it 'should work in serial', (done) ->
		# Prepare
		first = second = 0

		# Asynchronous
		eventEmitter.on 'serial-test', (opts,next) ->
			first++
			setTimeout(
				->
					expect(second).to.eql(0)
					first++
					next()
				500
			)

		# Synchronous
		eventEmitter.on 'serial-test', ->
			expect(first).to.eql(2)
			second += 2

		# Correct amount of listeners?
		expect(eventEmitter.listeners('serial-test').length).to.eql(2)

		# Emit and check
		eventEmitter.emitSerial 'serial-test', null, (err) ->
			expect(err).to.eql(null)
			expect(first).to.eql(2)
			expect(second).to.eql(2)
			done()

	# Parallel
	it 'should work in parallel', (done) ->
		# Prepare
		first = second = 0

		# Asynchronous
		eventEmitter.on 'parallel-test', (opts,next) ->
			first++
			setTimeout(
				->
					expect(second).to.eql(2)
					first++
					next()
				500
			)

		# Synchronous
		eventEmitter.on 'parallel-test', ->
			expect(first).to.eql(1)
			second += 2

		# Correct amount of listeners?
		expect(eventEmitter.listeners('parallel-test').length).to.eql(2)

		# Emit and check
		eventEmitter.emitParallel 'parallel-test', null, (err) ->
			expect(err).to.eql(null)
			expect(first).to.eql(2)
			expect(second).to.eql(2)
			done()

	# Parallel
	it 'should work with once', (done) ->
		# Prepare
		first = second = 0

		# Asynchronous
		eventEmitter.once 'once-test', (opts,next) ->
			first++
			setTimeout(
				->
					expect(second).to.eql(2)
					first++
					next()
				500
			)

		# Synchronous
		eventEmitter.once 'once-test', ->
			expect(first).to.eql(1)
			second += 2

		# Correct amount of listeners?
		expect(eventEmitter.listeners('once-test').length).to.eql(2)

		# Emit and check
		eventEmitter.emitParallel 'once-test', null, (err) ->
			expect(err).to.eql(null)
			expect(first).to.eql(2)
			expect(second).to.eql(2)
			expect(eventEmitter.listeners('once-test').length).to.eql(0)
			done()

	# Off
	it 'should work with off', (done) ->
		# Prepare
		counterA = counterB = 0

		# Synchronous
		eventEmitter.on 'off-test', listenerA = ->
			expect(counterA).to.eql(0)
			expect(counterB).to.eql(0)
			counterA++

		# Synchronous
		eventEmitter.on 'off-test', listenerB = ->
			expect(counterA).to.eql(0)
			expect(counterB).to.eql(0)
			counterB++

		# Correct amount of listeners?
		expect(eventEmitter.listeners('off-test').length).to.eql(2)

		# Remove and check again
		eventEmitter.off('off-test', listenerA)
		expect(eventEmitter.listeners('off-test').length).to.eql(1)

		# Emit and check
		eventEmitter.emitSerial 'off-test', null, (err) ->
			expect(err).to.eql(null)
			expect(counterA).to.eql(0)
			expect(counterB).to.eql(1)
			done()

	# Priorities
	it 'should work with priorities', (done) ->
		# Prepare
		counterA = counterB = counterC = 0

		# Exec First
		listenerA = ->
			expect(counterA).to.eql(0)
			expect(counterB).to.eql(0)
			expect(counterC).to.eql(0)
			counterA++
		listenerA.priority = 500
		eventEmitter.on('priority-test', listenerA)

		# Exec Last
		listenerB = ->
			expect(counterA).to.eql(1)
			expect(counterB).to.eql(0)
			expect(counterC).to.eql(1)
			counterB++
		listenerB.priority = 300
		eventEmitter.on('priority-test', listenerB)

		# Exec Second
		listenerC = ->
			expect(counterA).to.eql(1)
			expect(counterB).to.eql(0)
			expect(counterC).to.eql(0)
			counterC++
		listenerC.priority = 400
		eventEmitter.on('priority-test', listenerC)


		# Correct amount of listeners?
		expect(eventEmitter.listeners('priority-test').length).to.eql(3)

		# Emit and check
		eventEmitter.emitSerial 'priority-test', null, (err) ->
			expect(err).to.eql(null)
			expect(counterA).to.eql(1)
			expect(counterB).to.eql(1)
			expect(counterC).to.eql(1)
			done()
