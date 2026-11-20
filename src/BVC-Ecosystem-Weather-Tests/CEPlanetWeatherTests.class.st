"
Deterministic analytic planetary fields. Authoritative source authored through GT MCP.
"
Class {
	#name : 'CEPlanetWeatherTests',
	#superclass : 'TestCase',
	#category : 'BVC-Ecosystem-Weather-Tests',
	#package : 'BVC-Ecosystem-Weather-Tests'
}

{ #category : 'exporting' }
CEPlanetWeatherTests class >> exportVectorsTo: directory [
	| f p cases u inputs curves result model file |
	directory ensureCreateDirectory.
	f := self fixture.
	p := f at: 'program'.
	inputs := f at: 'inputs'.
	curves := f at: 'curves'.
	u := f at: 'uniforms'.
	cases := OrderedCollection new.
	#(0 60 1800 3600 7200 10800 43200 86400)
		do: [ :time | 
			cases
				add: (Dictionary new
						at: 'seconds' put: time;
						at: 'seed' put: 1729;
						at: 'uniforms' put: u copy;
						at: 'outputs'
							put: (p
									evaluateAt: time
									seed: 1729
									uniforms: u
									environment: inputs
									inputs: inputs
									curves: curves);
						yourself) ].
	u := u copy.
	u
		at: 17 put: 10000;
		at: 18 put: 0;
		at: 19 put: 108000000;
		at: 20 put: 800000;
		at: 21 put: 9500;
		at: 22 put: 9000.
	#(0 3600 7200 10800)
		do: [ :time | 
			cases
				add: (Dictionary new
						at: 'seconds' put: time;
						at: 'seed' put: 4294969026;
						at: 'uniforms' put: u copy;
						at: 'outputs'
							put: (p
									evaluateAt: time
									seed: 4294969026
									uniforms: u
									environment: inputs
									inputs: inputs
									curves: curves);
						yourself) ].

	#(0 10000)
		do: [ :character | 
			u := (f at: 'uniforms') copy.
			u at: 16 put: character.
			#(0 3600 86400 172800)
				do: [ :time | 
					cases
						add: (Dictionary new
								at: 'seconds' put: time;
								at: 'seed' put: 1729;
								at: 'uniforms' put: u copy;
								at: 'outputs'
									put: (p
											evaluateAt: time
											seed: 1729
											uniforms: u
											environment: inputs
											inputs: inputs
											curves: curves);
								yourself) ] ].
	u := (f at: 'uniforms') copy.
	u at: 49 put: 0.
	#(0 7200)
		do: [ :time | 
			cases
				add: (Dictionary new
						at: 'seconds' put: time;
						at: 'seed' put: 1729;
						at: 'uniforms' put: u copy;
						at: 'outputs'
							put: (p
									evaluateAt: time
									seed: 1729
									uniforms: u
									environment: inputs
									inputs: inputs
									curves: curves);
						yourself) ].
	#(0 2500 5000 10000 20000 40000)
		do: [ :rate | 
			u := (f at: 'uniforms') copy.
			u
				at: 50 put: rate;
				at: 51 put: 7200 * (10000 - rate).
			#(3600 7200 10800)
				do: [ :time | 
					cases
						add: (Dictionary new
								at: 'seconds' put: time;
								at: 'seed' put: 1729;
								at: 'uniforms' put: u copy;
								at: 'outputs'
									put: (p
											evaluateAt: time
											seed: 1729
											uniforms: u
											environment: inputs
											inputs: inputs
											curves: curves);
								yourself) ] ].
	model := CEPlanetWeatherModel definition.
	(directory / 'program.json') ensureDelete.
	directory / 'program.json'
		writeStreamDo: [ :s | s nextPutAll: (STONJSON toString: model) ].
	result := Dictionary new
			at: 'profile' put: 'analytic-field-vectors-1';
			at: 'inputs' put: inputs;
			at: 'curves' put: curves;
			at: 'curveControlPoints' put: #(#(10000 0 0) #(7071 7071 0) #(0 10000 0));
			at: 'cases' put: cases asArray;
			yourself.
	file := directory / 'vectors.json'.
	file ensureDelete.
	file writeStreamDo: [ :s | s nextPutAll: (STONJSON toString: result) ].
	^ cases size * inputs size
]

{ #category : 'fixtures' }
CEPlanetWeatherTests class >> fixture [
	| u points p curve |
	u := Array new: 51 withAll: 0.
	u
		at: 1 put: 10000;
		at: 2 put: 864000000;
		at: 3 put: 216000000;
		at: 6 put: 10000;
		at: 7 put: 10000;
		at: 11 put: 10000;
		at: 13 put: 60000;
		at: 14 put: 10132500;
		at: 15 put: 6000;
		at: 16 put: 5000;
		at: 49 put: 10000;
		at: 50 put: 10000.
	points := #(#(10000 0 0 220000 7000 0 0 10000 0 0 7000 220000 4000) #(0 10000 0 220000 7000 0 0 0 10000 0 7000 220000 4000) #(0 0 10000 -200000 3000 0 0 0 0 10000 3000 -200000 0) #(-10000 0 0 220000 1000 0 0 -10000 0 0 1000 220000 0) #(0 -10000 0 220000 7000 10000 0 0 -10000 0 7000 220000 10000) #(0 0 -10000 -200000 3000 0 0 0 0 -10000 3000 -200000 0)).
	p := CSAnalyticFieldProgram from: CEPlanetWeatherModel definition.
	curve := p buildCurve: #(#(10000 0 0) #(7071 7071 0) #(0 10000 0)).
	^ Dictionary new
		at: 'program' put: p;
		at: 'uniforms' put: u;
		at: 'inputs' put: points;
		at: 'curves' put: {curve};
		yourself
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testAuthoredStormLifecycle [
	| f p u inputs curves evaluate with without peak start end |
	f := self class fixture.
	p := f at: 'program'.
	u := (f at: 'uniforms') copy.
	inputs := f at: 'inputs'.
	curves := f at: 'curves'.
	u
		at: 17 put: 10000;
		at: 18 put: 0;
		at: 19 put: 108000000;
		at: 20 put: 800000;
		at: 21 put: 9500;
		at: 22 put: 9000.
	evaluate := [ :time | 
		p
			evaluateAt: time
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: curves ].
	start := evaluate value: 0.
	peak := evaluate value: 3600.
	end := evaluate value: 10800.
	u at: 17 put: 0.
	self assert: start equals: (evaluate value: 0).
	self assert: end equals: (evaluate value: 10800).
	self deny: peak = (evaluate value: 3600)
]

{ #category : 'tests' }
CEPlanetWeatherTests >> testCharacterChangesExtremeFrequencyAndStrength [
	| b program u counts totals peaks output |
	b := CEPlanetWeatherModel new.
	program := CSAnalyticFieldProgram
			from: (b
					finish: (#(0 0.5 1)
							collect: [ :c | 
								b
									extremeAt: b time
									character: (b c: c)
									stream: 500 ])).
	u := self class fixture at: 'uniforms'.
	counts := #(0 0 0) copy.
	totals := #(0 0 0) copy.
	peaks := #(0 0 0) copy.
	#(1729 33 99 4294969026)
		do: [ :seed | 
			0
				to: 431
				do: [ :tick | 
					output := (program
							evaluateAt: tick * 600
							seed: seed
							uniforms: u
							environment: #()
							inputs: {#()}
							curves: #()) first.
					1
						to: 3
						do: [ :i | 
							| value |
							value := output at: i.
							value > 0 ifTrue: [ counts at: i put: (counts at: i) + 1 ].
							totals at: i put: (totals at: i) + value.
							peaks at: i put: ((peaks at: i) max: value) ].
					self assert: output first <= output second.
					self assert: output second <= output third ] ].
	self assert: counts first equals: 0.
	self assert: counts second > 0.
	self assert: counts third > counts second.
	self assert: totals third > (totals second * 3).
	self assert: peaks third > peaks second
]

{ #category : 'tests' }
CEPlanetWeatherTests >> testCharacterKeepsReplayAndMoistureConstraints [
	| f u inputs program |
	f := self class fixture.
	program := f at: 'program'.
	inputs := (f at: 'inputs')
			collect: [ :row | 
				| copy |
				copy := row copy.
				copy
					at: 5 put: 0;
					at: 11 put: 0;
					at: 13 put: 0.
				copy ].
	#(0 5000 10000)
		do: [ :character | 
			u := (f at: 'uniforms') copy.
			u at: 16 put: character.
			#(0 3600 86400)
				do: [ :time | 
					| a b |
					a := program
							evaluateAt: time
							seed: 1729
							uniforms: u
							environment: inputs
							inputs: inputs
							curves: (f at: 'curves').
					b := program
							evaluateAt: time
							seed: 1729
							uniforms: u
							environment: inputs
							inputs: inputs
							curves: (f at: 'curves').
					self assert: a equals: b.
					a
						do: [ :row | 
							self assert: row fifth equals: 0.
							self assert: row sixth >= 0.
							self assert: row sixth <= 10000.
							self assert: row seventh <= 10000 ] ] ]
]

{ #category : 'tests' }
CEPlanetWeatherTests >> testDisabledWeatherIsStaticClimate [
	| f u inputs program |
	f := self class fixture.
	u := (f at: 'uniforms') copy.
	inputs := f at: 'inputs'.
	program := f at: 'program'.
	u
		at: 49 put: 0;
		at: 16 put: 10000;
		at: 17 put: 10000;
		at: 18 put: 0;
		at: 19 put: 108000000;
		at: 20 put: 1500000;
		at: 21 put: 9500;
		at: 22 put: 10000.
	#(0 3600 7200 86400)
		do: [ :time | 
			| rows |
			rows := program
					evaluateAt: time
					seed: 1729
					uniforms: u
					environment: inputs
					inputs: inputs
					curves: (f at: 'curves').
			rows
				with: inputs
				do: [ :row :input | 
					self assert: row first equals: input fourth.
					self assert: (row copyFrom: 2 to: 7) equals: #(0 0 0 0 0 0).
					self assert: row eighth equals: (u at: 14) ] ]
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testDryPlanetAndMoistureSupply [
	| f p u dry wet a b |
	f := self class fixture.
	p := f at: 'program'.
	u := f at: 'uniforms'.
	dry := (f at: 'inputs')
			collect: [ :row | 
				| x |
				x := row copy.
				x
					at: 5 put: 0;
					at: 6 put: 0;
					at: 11 put: 0;
					at: 13 put: 0.
				x ].
	wet := dry
			collect: [ :row | 
				| x |
				x := row copy.
				x
					at: 5 put: 10000;
					at: 6 put: 10000;
					at: 11 put: 10000;
					at: 13 put: 10000.
				x ].
	a := p
			evaluateAt: 3600
			seed: 1729
			uniforms: u
			environment: dry
			inputs: dry
			curves: #().
	b := p
			evaluateAt: 3600
			seed: 1729
			uniforms: u
			environment: wet
			inputs: wet
			curves: #().
	self assert: (a allSatisfy: [ :r | r fifth = 0 ]).
	self assert: (b anySatisfy: [ :r | r fifth > 0 ])
]

{ #category : 'pressure conformance' }
CEPlanetWeatherTests >> testExtremePressureInputsStayBounded [
	| f u curves row p result |
	f := self class fixture.
	u := (f at: 'uniforms') copy.
	p := f at: 'program'.
	u
		at: 1 put: 30000;
		at: 15 put: 50000.
	curves := Array new: 4 withAll: (Array new: 129 withAll: #(7071 0 7071)).
	0
		to: 3
		do: [ :i | 
			| base |
			base := 17 + (i * 8).
			u
				at: base put: 10000;
				at: base + 1 put: 0;
				at: base + 2 put: 108000000;
				at: base + 3 put: 1500000;
				at: base + 4 put: 9999;
				at: base + 5 put: 10000 ].
	row := (f at: 'inputs') first copy.
	row
		at: 1 put: 7067;
		at: 2 put: 346;
		at: 3 put: 7067.
	result := (p
			evaluateAt: 5400
			seed: 1729
			uniforms: u
			environment: (f at: 'inputs')
			inputs: {row}
			curves: curves) first.
	self assert: result eighth > 0.
	self
		assert: (result at: 2) squared + (result at: 3) squared + (result at: 4) squared
				<= 810000 squared
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testPrecipitationPhaseIsSmoothAndConservative [
	| b p result previous snow warm mixed |
	b := CEPlanetWeatherModel new.
	p := CSAnalyticFieldProgram
			from: (b finish: (b precipitation: (b input: 0) atTemperature: (b input: 1))).
	previous := 0.
	-20000
		to: 20000
		by: 100
		do: [ :temperature | 
			result := (p
					evaluateAt: 0
					seed: 1729
					uniforms: #()
					environment: #()
					inputs: {{123456.
								temperature}}
					curves: #()) first.
			self assert: result first + result second equals: 123456.
			self assert: result first >= previous.
			self assert: result first >= 0.
			self assert: result second >= 0.
			previous := result first ].
	snow := (p
			evaluateAt: 0
			seed: 1729
			uniforms: #()
			environment: #()
			inputs: #(#(123456 -10000))
			curves: #()) first.
	warm := (p
			evaluateAt: 0
			seed: 1729
			uniforms: #()
			environment: #()
			inputs: #(#(123456 10000))
			curves: #()) first.
	mixed := (p
			evaluateAt: 0
			seed: 1729
			uniforms: #()
			environment: #()
			inputs: #(#(100000 0))
			curves: #()) first.
	self assert: snow equals: #(0 123456).
	self assert: warm equals: #(123456 0).
	self assert: mixed equals: #(50000 50000).
	self
		assert: (p
				evaluateAt: 0
				seed: 1729
				uniforms: #()
				environment: #()
				inputs: #(#(0 -100000) #(0 100000))
				curves: #())
		equals: #(#(0 0) #(0 0))
]

{ #category : 'pressure conformance' }
CEPlanetWeatherTests >> testPressureGradientCirculation [
	| f u inputs |
	f := self class fixture.
	u := f at: 'uniforms'.
	inputs := f at: 'inputs'.
	#(-1 1)
		do: [ :hemisphere | 
			#(-10 10)
				do: [ :amplitude | 
					| b s center definition program row result toward rotation radial |
					b := CEPlanetWeatherModel new.
					s := b initialState.
					s
						at: #pressure put: (b c: 0);
						at: #pressureGradient
							put: {b c: 0.
									b c: 0.
									b c: 0}.
					center := {b c: 0.
							b c: 0.
							b c: hemisphere}.
					b
						pressureAt: center
						amplitude: (b c: amplitude)
						threshold: (b c: 0.65)
						state: s.
					definition := b finish: (b windFromPressure: s) , {s at: #pressure}.
					program := CSAnalyticFieldProgram from: definition.
					row := inputs first copy.
					row
						at: 1 put: 6000;
						at: 2 put: 0;
						at: 3 put: 8000 * hemisphere.
					result := (program
							evaluateAt: 3600
							seed: 1729
							uniforms: u
							environment: inputs
							inputs: {row}
							curves: #()) first.
					toward := (result at: 1) * -4800 + ((result at: 3) * 3600 * hemisphere).
					rotation := (result at: 2) * hemisphere.
					radial := (result at: 1) * 6000 + ((result at: 3) * 8000 * hemisphere).
					self assert: toward * amplitude < 0.
					self assert: rotation * amplitude * hemisphere < 0.
					self assert: radial abs < 20000.
					self assert: result fourth * amplitude > 0 ] ]
]

{ #category : 'pressure conformance' }
CEPlanetWeatherTests >> testPressureReferenceAndResponse [
	| f p u inputs curves evaluate a b c changed |
	f := self class fixture.
	p := f at: 'program'.
	u := (f at: 'uniforms') copy.
	inputs := f at: 'inputs'.
	curves := f at: 'curves'.
	evaluate := [ p
			evaluateAt: 3600
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: curves ].
	a := evaluate value.
	u at: 14 put: (u at: 14) * 2.
	b := evaluate value.
	1
		to: a size
		do: [ :i | 
			self assert: (((b at: i) at: 8) - (((a at: i) at: 8) * 2)) abs <= 1.
			self assert: ((a at: i) copyFrom: 1 to: 7) = ((b at: i) copyFrom: 1 to: 7) ].
	u at: 15 put: (u at: 15) * 2.
	c := evaluate value.
	changed := false.
	1
		to: a size
		do: [ :i | 
			self assert: ((b at: i) at: 8) = ((c at: i) at: 8).
			changed := changed
					or: [ ((b at: i) copyFrom: 2 to: 4) ~= ((c at: i) copyFrom: 2 to: 4) ] ].
	self assert: changed
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testSeedReplayAndForecast [
	| f p u inputs clock current prediction later other |
	f := self class fixture.
	p := f at: 'program'.
	u := f at: 'uniforms'.
	inputs := f at: 'inputs'.
	clock := CSAnalyticFieldRuntime new.
	clock advanceTo: 3600.
	current := p
			evaluateAt: clock acceptedSeconds
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: #().
	prediction := p
			evaluateAt: clock acceptedSeconds + 3600
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: #().
	self assert: clock acceptedSeconds equals: 3600.
	self assert: (clock isHistory: 0).
	self assert: (clock isForecast: 7200).
	clock advanceTo: 7200.
	later := p
			evaluateAt: clock acceptedSeconds
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: #().
	self assert: prediction equals: later.
	self deny: current = prediction.
	other := p
			evaluateAt: 3600
			seed: 1730
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: #().
	self deny: current = other.
	self
		assert: current
		equals: (p
				evaluateAt: 3600
				seed: 1729
				uniforms: u
				environment: inputs
				inputs: inputs
				curves: #())
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testSnowAndRainKeepForecastAndDisable [
	| f p u inputs curves future replay off |
	f := self class fixture.
	p := f at: 'program'.
	u := (f at: 'uniforms') copy.
	inputs := f at: 'inputs'.
	curves := f at: 'curves'.
	future := p
			evaluateAt: 10800
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: curves.
	p
		evaluateAt: 3600
		seed: 1729
		uniforms: u
		environment: inputs
		inputs: inputs
		curves: curves.
	replay := p
			evaluateAt: 10800
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: curves.
	self assert: future equals: replay.
	future
		do: [ :row | 
			self assert: row size equals: 9.
			self assert: (row at: 5) >= 0.
			self assert: (row at: 9) >= 0.
			row first <= -10000 ifTrue: [ self assert: (row at: 5) equals: 0 ].
			row first >= 10000 ifTrue: [ self assert: (row at: 9) equals: 0 ] ].
	u at: 49 put: 0.
	off := p
			evaluateAt: 10800
			seed: 1729
			uniforms: u
			environment: inputs
			inputs: inputs
			curves: curves.
	off
		do: [ :row | 
			self assert: (row at: 5) equals: 0.
			self assert: (row at: 9) equals: 0 ]
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testTravelChangePreservesPositionAndForecast [
	| f p u evaluate before predicted |
	f := self class fixture.
	p := f at: 'program'.
	u := (f at: 'uniforms') copy.
	evaluate := [ :time | 
		p
			evaluateAt: time
			seed: 1729
			uniforms: u
			environment: (f at: 'inputs')
			inputs: (f at: 'inputs')
			curves: (f at: 'curves') ].
	before := evaluate value: 7200.
	#(0 2500 5000 10000 20000 40000)
		do: [ :rate | 
			u
				at: 50 put: rate;
				at: 51 put: 7200 * (10000 - rate).
			self assert: (evaluate value: 7200) equals: before.
			predicted := evaluate value: 10800.
			evaluate value: 3600.
			evaluate value: 14400.
			self assert: (evaluate value: 10800) equals: predicted ]
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testTravelMultiplierOnlyScalesTrajectories [
	| b s program f u reference actual referenceTravel outputs time |
	b := CEPlanetWeatherModel new.
	s := b initialState.
	outputs := {s at: #flow}
			, ((0 to: 7) collect: [ :i | b regionalTurn: i state: s ])
			, {s at: #time.
					s at: #heat.
					b
						extremeAt: (s at: #time)
						character: (s at: #character)
						stream: 500}.
	program := CSAnalyticFieldProgram from: (b finish: outputs).
	f := self class fixture.
	u := (f at: 'uniforms') copy.
	time := 7200.
	reference := program
			evaluateAt: time
			seed: 1729
			uniforms: u
			environment: (f at: 'inputs')
			inputs: (f at: 'inputs')
			curves: (f at: 'curves').
	#(0 2500 5000 10000 20000 40000)
		do: [ :rate | 
			u at: 50 put: rate.
			actual := program
					evaluateAt: time
					seed: 1729
					uniforms: u
					environment: (f at: 'inputs')
					inputs: (f at: 'inputs')
					curves: (f at: 'curves').
			u at: 50 put: 10000.
			referenceTravel := program
					evaluateAt: time * rate // 10000
					seed: 1729
					uniforms: u
					environment: (f at: 'inputs')
					inputs: (f at: 'inputs')
					curves: (f at: 'curves').
			1
				to: actual size
				do: [ :i | 
					self
						assert: ((actual at: i) first: 9)
						equals: ((referenceTravel at: i) first: 9).
					self
						assert: ((actual at: i) allButFirst: 9)
						equals: ((reference at: i) allButFirst: 9) ] ]
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests >> testTravelMultiplierPreservesAuthoredSchedules [
	| f p u evaluate reference |
	f := self class fixture.
	p := f at: 'program'.
	u := (f at: 'uniforms') copy.
	u
		at: 1 put: 0;
		at: 13 put: 0;
		at: 16 put: 0;
		at: 17 put: 10000;
		at: 18 put: 0;
		at: 19 put: 108000000;
		at: 20 put: 800000;
		at: 21 put: 9500;
		at: 22 put: 9000.
	evaluate := [ :time | 
		p
			evaluateAt: time
			seed: 1729
			uniforms: u
			environment: (f at: 'inputs')
			inputs: (f at: 'inputs')
			curves: (f at: 'curves') ].	"Compare the event contribution, since natural cloud/heat/dust still evolve without pressure forcing."
	#(0 3600 7200 10800)
		do: [ :time | 
			u
				at: 50 put: 10000;
				at: 17 put: 10000.
			reference := evaluate value: time.
			u at: 17 put: 0.
			reference := reference
					with: (evaluate value: time)
					collect: [ :a :b | a with: b collect: [ :x :y | x - y ] ].
			#(2500 40000)
				do: [ :rate | 
					| actual absent |
					u
						at: 50 put: rate;
						at: 17 put: 10000.
					actual := evaluate value: time.
					u at: 17 put: 0.
					absent := evaluate value: time.	"Wind is the authored vortex with regional/prevailing force zero; pressure is likewise independent of travel."
					1
						to: actual size
						do: [ :i | 
							#(2 3 4 8)
								do: [ :channel | 
									self
										assert: ((actual at: i) at: channel) - ((absent at: i) at: channel)
										equals: ((reference at: i) at: channel) ] ] ] ]
]
