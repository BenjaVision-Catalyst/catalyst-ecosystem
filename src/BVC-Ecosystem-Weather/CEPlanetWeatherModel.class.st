"
Deterministic analytic planetary fields. Authoritative source authored through GT MCP.
"
Class {
	#name : 'CEPlanetWeatherModel',
	#superclass : 'CSFieldBuilder',
	#category : 'BVC-Ecosystem-Weather',
	#package : 'BVC-Ecosystem-Weather'
}

{ #category : 'planet weather' }
CEPlanetWeatherModel class >> definition [
	^ self new build
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> basisAt: phase latitude: latitude [
	| co si radial pole u v |
	co := self sine: (self add: phase b: (self c: 0.25)).
	si := self sine: phase.
	radial := self
			root: (self
					max: (self c: 0)
					b: (self sub: (self c: 1) b: (self mul: latitude b: latitude))).
	pole := #(3 4 5) collect: [ :i | self uniform: i ].
	u := #(6 7 8) collect: [ :i | self uniform: i ].
	v := #(9 10 11) collect: [ :i | self uniform: i ].
	^ self
		normalized: (self
				vector: (self scaled: pole by: latitude)
				plus: (self
						vector: (self scaled: u by: (self mul: co b: radial))
						plus: (self scaled: v by: (self mul: si b: radial))))
]

{ #category : 'building' }
CEPlanetWeatherModel >> build [
	| s slope rain heat dust outputs definition pressure enabled wind cloud |
	s := self initialState.
	0 to: 7 do: [ :i | self regional: i state: s ].
	0 to: 3 do: [ :i | self event: i state: s ].
	s at: #wind put: (self windFromPressure: s).
	slope := self
			max: (self c: 0)
			b: (self
					sub: (self c: 0)
					b: (self dot: (self normalized: (s at: #wind)) with: (s at: #normal))).
	rain := self
			min: (self c: 100)
			b: (self
					mul: (s at: #rain)
					b: (self add: (self c: 1) b: (self mul: slope b: (self c: 3)))).
	heat := self sub: (s at: #heat) b: (self mul: rain b: (self c: 0.08)).
	dust := self
			mul: (s at: #dust)
			b: (self sub: (self c: 1) b: (self smooth: (self div: rain b: (self c: 5)))).
	enabled := s at: #enabled.
	heat := self
			add: (self input: 3)
			b: (self mul: enabled b: (self sub: heat b: (self input: 3))).
	wind := self scaled: (s at: #wind) by: enabled.
	rain := self mul: rain b: enabled.
	dust := self
			mul: (self min: (self c: 1) b: (self max: (self c: 0) b: dust))
			b: enabled.
	cloud := self
			mul: (self min: (self c: 1) b: (self max: (self c: 0) b: (s at: #cloud)))
			b: enabled.
	pressure := self
			mul: (self uniform: 13)
			b: (self
					add: (self c: 1)
					b: (self div: (self mul: (s at: #pressure) b: enabled) b: (self c: 1013.25))).
	outputs := {heat} , wind
			, {rain.
					dust.
					cloud.
					pressure}.
	definition := self finish: outputs.
	definition
		at: 'channels'
			put: #('temperatureC' 'windX' 'windY' 'windZ' 'rainMmHour' 'dust' 'cloud' 'pressureHpa');
		at: 'domain' put: 'planetary-weather-4'.
	^ definition
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> direction: position toward: center [
	^ self
		normalized: (self
				vector: center
				plus: (self
						scaled: position
						by: (self sub: (self c: 0) b: (self dot: position with: center))))
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> event: i state: s [
	| p base progress life center core parent size velocity swirl inflow factor stormWet contribution |
	p := s at: #p.
	base := 16 + (i * 8).
	progress := self
			div: (self sub: (s at: #time) b: (self uniform: base + 1))
			b: (self max: (self c: 1) b: (self uniform: base + 2)).
	life := self
			mul: (self smooth: (self div: progress b: (self c: 0.1)))
			b: (self smooth: (self div: (self sub: (self c: 1) b: progress) b: (self c: 0.2))).
	life := self mul: life b: (self uniform: base).
	center := self
			normalized: ((0 to: 2)
					collect: [ :axis | 
						self
							curve: i
							axis: axis
							time: (self smooth: progress) ]).
	size := self uniform: base + 4.
	core := self
			mul: life
			b: (self
					weight: p
					center: center
					threshold: size).
	contribution := self mul: (self sub: (self c: 1) b: size) b: (self c: 12).
	contribution := self
			max: (self c: 0.2)
			b: (self sub: (self c: 1) b: contribution).
	parent := self
			mul: life
			b: (self
					weight: p
					center: center
					threshold: contribution).
	velocity := self uniform: base + 3.
	inflow := self direction: p toward: center.
	swirl := self normalized: (self cross: center with: p).
	factor := self mul: core b: velocity.
	contribution := self
			vector: swirl
			plus: (self scaled: inflow by: (self c: 0.2)).
	contribution := self
			vector: (self scaled: contribution by: factor)
			plus: (self scaled: p by: (self mul: factor b: (self c: 0.2))).
	s at: #vortexWind put: (self vector: (s at: #vortexWind) plus: contribution).
	self
		pressureAt: center
		amplitude: (self
				mul: life
				b: (self
						sub: (self c: 0)
						b: (self add: (self c: 4) b: (self mul: velocity b: (self c: 0.15)))))
		threshold: (self
				max: (self c: 0.2)
				b: (self
						sub: (self c: 1)
						b: (self mul: (self sub: (self c: 1) b: size) b: (self c: 12))))
		state: s.
	stormWet := self uniform: base + 5.
	contribution := self mul: (self mul: parent b: stormWet) b: (self c: 30).
	s at: #rain put: (self add: (s at: #rain) b: contribution).
	s at: #cloud put: (self max: (s at: #cloud) b: parent).
	s at: #heat put: (self sub: (s at: #heat) b: (self mul: parent b: (self c: 3)))
]

{ #category : 'building' }
CEPlanetWeatherModel >> extremeAt: time character: character stream: stream [
	| square chance roll pulse |
	square := self mul: character b: character.
	chance := self add: (self c: 0.01) b: (self mul: square b: (self c: 0.34)).
	roll := self
			mul: (self
					add: (self c: 1)
					b: (self
							noise: time
							period: 10800
							stream: stream))
			b: (self c: 0.5).
	pulse := self
			smooth: (self
					div: (self sub: roll b: (self sub: (self c: 1) b: chance))
					b: (self c: 0.1)).
	^ self mul: (self mul: square b: (self c: 4)) b: pulse
]

{ #category : 'building' }
CEPlanetWeatherModel >> initialState [
	| s p pole u v t lat band tangent amplitude phase solar daily heat character base travelTime |
	s := Dictionary new.
	character := self
			min: (self c: 1)
			b: (self max: (self c: 0) b: (self uniform: 15)).
	base := self add: (self c: 0.35) b: (self mul: character b: (self c: 1.3)).
	p := #(0 1 2) collect: [ :i | self input: i ].
	pole := #(3 4 5) collect: [ :i | self uniform: i ].
	u := #(6 7 8) collect: [ :i | self uniform: i ].
	v := #(9 10 11) collect: [ :i | self uniform: i ].
	t := self time.
	travelTime := self
			add: (self mul: t b: (self max: (self c: 0) b: (self uniform: 49)))
			b: (self uniform: 50).
	lat := self dot: p with: pole.
	band := self sub: (self mul: lat b: lat) b: (self c: 0.3333).
	amplitude := self mul: (self mul: (self uniform: 12) b: (self c: 3)) b: base.
	tangent := self
			vector: pole
			plus: (self scaled: p by: (self sub: (self c: 0) b: lat)).
	phase := self div: t b: (self max: (self c: 60) b: (self uniform: 1)).
	solar := self
			vector: (self scaled: u by: (self sine: (self add: phase b: (self c: 0.25))))
			plus: (self scaled: v by: (self sine: phase)).
	daily := self mul: (self dot: p with: solar) b: (self c: 5).
	daily := self
			mul: daily
			b: (self sub: (self c: 1) b: (self mul: (self input: 5) b: (self c: 0.8))).
	heat := self add: (self input: 3) b: daily.
	heat := self
			add: heat
			b: (self mul: (self sub: (self input: 11) b: (self input: 3)) b: (self c: 0.1)).
	s
		at: #p put: p;
		at: #character put: character;
		at: #characterBase put: base;
		at: #enabled
			put: (self min: (self c: 1) b: (self max: (self c: 0) b: (self uniform: 48)));
		at: #pole put: pole;
		at: #time put: t;
		at: #travelTime put: travelTime;
		at: #strength put: (self uniform: 0);
		at: #flow
			put: (self div: travelTime b: (self max: (self c: 60) b: (self uniform: 2)));
		at: #normal put: (#(7 8 9) collect: [ :i | self input: i ]);
		at: #pressure
			put: (self mul: (self sub: (self c: 0) b: amplitude) b: (self mul: band b: band));
		at: #pressureGradient
			put: (self
					scaled: tangent
					by: (self mul: (self mul: amplitude b: (self c: -4)) b: (self mul: lat b: band)));
		at: #vortexWind
			put: {self c: 0.
					self c: 0.
					self c: 0};
		at: #heat put: heat;
		at: #rain put: (self c: 0);
		at: #cloud put: (self c: 0);
		at: #dust put: (self c: 0).
	^ s
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> pressureAt: center amplitude: amplitude threshold: threshold state: s [
	| p d q weight slope tangent derivative |
	p := s at: #p.
	d := self dot: p with: center.
	q := self
			min: (self c: 1)
			b: (self
					max: (self c: 0)
					b: (self
							div: (self sub: d b: threshold)
							b: (self max: (self c: 0.0001) b: (self sub: (self c: 1) b: threshold)))).
	weight := self smooth: q.
	slope := self mul: (self mul: (self c: 6) b: q) b: (self sub: (self c: 1) b: q).
	tangent := self
			vector: center
			plus: (self scaled: p by: (self sub: (self c: 0) b: d)).
	derivative := self
			div: (self mul: amplitude b: slope)
			b: (self max: (self c: 0.0001) b: (self sub: (self c: 1) b: threshold)).
	s
		at: #pressure
		put: (self add: (s at: #pressure) b: (self mul: amplitude b: weight)).
	s
		at: #pressureGradient
		put: (self
				vector: (s at: #pressureGradient)
				plus: (self scaled: tangent by: derivative))
]

{ #category : 'building' }
CEPlanetWeatherModel >> regional: i state: s [
	| p t latitude sign turn center upstream weight carried wet regime force sampleWet pathWet sourceDust wetness downwind lee contribution severity |
	p := s at: #p.
	t := s at: #time.
	severity := self
			add: (s at: #characterBase)
			b: (self
					extremeAt: t
					character: (s at: #character)
					stream: i * 8 + 500).
	latitude := self c: (i - 3.5) / 4.8.
	sign := (3 * ((i - 3.5) / 4.8) squared - 1) sign.
	turn := self regionalTurn: i state: s.
	center := self basisAt: turn latitude: latitude.
	upstream := self
			basisAt: (self sub: turn b: (self c: sign * 0.08))
			latitude: latitude.
	weight := self
			weight: p
			center: center
			threshold: (self c: 0.65).
	sampleWet := self
			div: (self add: (self table: 4 at: upstream) b: (self table: 10 at: upstream))
			b: (self c: 2).
	pathWet := self
			add: (self table: 4 at: center)
			b: (self mul: (self table: 12 at: center) b: (self c: 0.5)).
	carried := self
			add: (self mul: sampleWet b: (self c: 0.65))
			b: (self mul: pathWet b: (self c: 0.35)).
	wetness := self
			div: (self add: (self input: 4) b: (self input: 10))
			b: (self c: 2).
	wet := self
			min: (self c: 1)
			b: (self
					add: (self mul: carried b: (self c: 0.75))
					b: (self mul: wetness b: (self c: 0.25))).
	regime := self
			smooth: (self
					add: (self c: 0.5)
					b: (self
							mul: (self
									noise: t
									period: 7200
									stream: i * 8 + 101)
							b: (self c: 0.5))).
	force := self
			mul: (s at: #strength)
			b: (self add: (self c: 6) b: (self mul: regime b: (self c: 14))).
	force := self mul: force b: (self c: (i even ifTrue: [ -1 ] ifFalse: [ 1 ])).
	force := self mul: force b: severity.
	self
		pressureAt: center
		amplitude: force
		threshold: (self c: 0.65)
		state: s.
	downwind := self
			max: (self c: 0)
			b: (self sub: (self table: 6 at: upstream) b: (self input: 6)).
	lee := self
			sub: (self c: 1)
			b: (self smooth: (self mul: downwind b: (self c: 0.8))).
	contribution := self
			mul: (self mul: weight b: regime)
			b: (self c: (i even ifTrue: [ 1 ] ifFalse: [ 0.05 ])).
	contribution := self
			mul: contribution
			b: (self max: (self c: 0) b: (self sub: wet b: (self c: 0.3))).
	contribution := self
			mul: contribution
			b: (self mul: (self mul: (s at: #strength) b: severity) b: (self c: 24)).
	s at: #rain put: (self add: (s at: #rain) b: (self mul: contribution b: lee)).
	s
		at: #cloud
		put: (self
				max: (s at: #cloud)
				b: (self
						mul: (self mul: (self mul: weight b: wet) b: severity)
						b: (self c: (i even ifTrue: [ 1 ] ifFalse: [ 0.3 ])))).
	sourceDust := self max: (self c: 0) b: (self sub: (self c: 0.5) b: sampleWet).
	contribution := self
			mul: (self mul: weight b: sourceDust)
			b: (self sub: (self c: 1) b: (self smooth: wet)).
	s
		at: #dust
		put: (self
				add: (s at: #dust)
				b: (self mul: (self mul: contribution b: severity) b: (self c: 2))).
	contribution := self
			mul: weight
			b: (self
					noise: t
					period: 14400
					stream: i * 8 + 102).
	s
		at: #heat
		put: (self
				add: (s at: #heat)
				b: (self mul: (self mul: contribution b: (s at: #characterBase)) b: (self c: 4)))
]

{ #category : 'building' }
CEPlanetWeatherModel >> regionalTurn: i state: s [
	| sign turn |
	sign := (3 * ((i - 3.5) / 4.8) squared - 1) sign.
	turn := self mul: (s at: #flow) b: (self c: sign).
	turn := self add: turn b: (self c: i / 8).
	turn := self
			add: turn
			b: (self
					mul: (self
							noise: (s at: #travelTime)
							period: 10800
							stream: i * 8 + 100)
					b: (self c: 0.14)).
	^ turn
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> weight: position center: center threshold: threshold [
	| d |
	d := self dot: position with: center.
	^ self
		smooth: (self
				div: (self sub: d b: threshold)
				b: (self max: (self c: 0.0001) b: (self sub: (self c: 1) b: threshold)))
]

{ #category : 'planet weather' }
CEPlanetWeatherModel >> windFromPressure: s [
	| p g lat hemisphere rotation inflow wind magnitude divisor peak |
	p := s at: #p.
	g := s at: #pressureGradient.
	lat := self dot: p with: (s at: #pole).
	hemisphere := self
			div: lat
			b: (self root: (self add: (self mul: lat b: lat) b: (self c: 0.04))).
	rotation := self scaled: (self cross: p with: g) by: hemisphere.
	inflow := self scaled: g by: (self c: -0.2).
	wind := self
			scaled: (self vector: rotation plus: inflow)
			by: (self uniform: 14).
	peak := self c: 1.
	wind
		do: [ :component | 
			peak := self
					max: peak
					b: (self max: component b: (self sub: (self c: 0) b: component)) ].
	divisor := self max: (self c: 1) b: (self div: peak b: (self c: 80)).
	wind := self scaled: wind by: (self div: (self c: 1) b: divisor).
	magnitude := self root: (self max: (self c: 0) b: (self dot: wind with: wind)).
	divisor := self max: (self c: 1) b: (self div: magnitude b: (self c: 80)).
	^ self
		vector: (self scaled: wind by: (self div: (self c: 1) b: divisor))
		plus: (s at: #vortexWind)
]
