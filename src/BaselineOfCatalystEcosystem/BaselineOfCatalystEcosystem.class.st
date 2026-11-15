Class {
	#name : 'BaselineOfCatalystEcosystem',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystEcosystem',
	#package : 'BaselineOfCatalystEcosystem'
}

{ #category : 'baselines' }
BaselineOfCatalystEcosystem >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'CatalystSimulator'
				with: [ spec
						repository: 'github://BenjaVision-Catalyst/catalyst-simulator:main/src';
						loads: #('Fields') ].
			spec
				package: 'BVC-Ecosystem-Weather'
				with: [ spec requires: #('CatalystSimulator') ].
			spec
				package: 'BVC-Ecosystem-Weather-Tests'
				with: [ spec requires: #('BVC-Ecosystem-Weather') ].
			spec
				group: 'Core' with: #('BVC-Ecosystem-Weather');
				group: 'Tests' with: #('Core' 'BVC-Ecosystem-Weather-Tests');
				group: 'default' with: #('Core') ]
]
