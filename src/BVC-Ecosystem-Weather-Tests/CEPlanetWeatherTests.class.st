"
Deterministic analytic planetary fields. Authoritative source authored through GT MCP.
"
Class {
	#name : 'CEPlanetWeatherTests',
	#superclass : 'TestCase',
	#category : 'BVC-Ecosystem-Weather-Tests',
	#package : 'BVC-Ecosystem-Weather-Tests'
}

{ #category : 'conformance' }
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
	model := CEPlanetWeatherModel definition.
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
	file writeStreamDo: [ :s | s nextPutAll: (STONJSON toString: result) ].
	^ cases size * inputs size
]

{ #category : 'weather conformance' }
CEPlanetWeatherTests class >> fixture [
	| u points p curve |
	u := Array new: 48 withAll: 0.
	u
		at: 1 put: 10000;
		at: 2 put: 864000000;
		at: 3 put: 216000000;
		at: 6 put: 10000;
		at: 7 put: 10000;
		at: 11 put: 10000;
		at: 13 put: 60000.
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
