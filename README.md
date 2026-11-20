# Catalyst Ecosystem

CatalystEcosystem owns ecosystem behaviour over the shared CatalystSimulation
kernel: species/habitat definitions, resource dynamics, predation, reproduction,
disease and ecosystem model composition. The workspace checkout is
`Ecosystems/catalyst-ecosystem`. It is the first domain simulation planned over
the P3 Simulation service. NPC and automation simulations are separate, deferred
work and are not dependencies of this ecosystem implementation.

The ecosystem will run over a landform built with CatalystLandform. Landform is
in progress and not ready for integration; agree its usable data, coordinate and
revision contract before implementing the binding. CatalystLandform owns the
landform, CatalystEcosystem owns ecological behaviour, and CatalystSimulation
provides execution and acceptance. The first implemented slice is planetary weather, described below. The broader
ecological service and production acceptance remain planned.

## Behaviour and execution

Author portable ecosystem models and domain schemas in Smalltalk through GT.
The configured Simulation service owns evolving accepted state and executes the
model in GemStone/GT or through a compatible external backend such as Repast.
This component does not create a second scheduler, ownership system or transport.

Model values use semantic species/state/action identifiers, not Unreal asset
references. Ecosystem presentation belongs to CatalystEcosystemPlugin: meshes,
textures, materials, animation, appearance variants and domain-specific visual
policy. It uses CatalystSimulatorPlugin for common UE simulation/data management.

## Experimental source mining

The live GT image contains experimental `CESim*` packages. Treat them as mining
inputs, not production dependencies or a verified GemStone/external implementation.
Review the pipeline, identity, command/operation and test concepts against the
portable contract before deciding what to reuse. GT remains the source authority:
inspect, compile and export shared Smalltalk through GT MCP into an independent
checkout, preserving the original experiments until recovery is verified.

See the [GT inventory](https://github.com/BenjaVisionPro/catalyst-workspace/blob/main/Simulation/GT-Prototype-Mining-Inventory.md),
[kernel/service](https://github.com/BenjaVision-Catalyst/catalyst-simulator),
[ecosystem presentation](https://github.com/BenjaVision-Catalyst/catalyst-ecosystem-ue-plugin)
and [implementation plan](https://github.com/BenjaVisionPro/catalyst-workspace/blob/main/Simulation/Catalyst-Simulation-Implementation-Plan.md).

## License

[MIT](LICENSE).

## Planetary weather

`BVC-Ecosystem-Weather` defines `CEPlanetWeatherModel`, a deterministic analytic
field model authored through GT. Load with `BaselineOfCatalystEcosystem` (Core or
Tests); it requires Simulator's optional `Fields` group. The eight regional
high/low pressure systems share planetary circulation, upstream geography and
bounded authored storm/vortex events. Temperature, canonical wind, rain, dust,
cloud fraction and reference-datum pressure are outputs. No creature behaviour or presentation assets enter the model.

The fixed-point DAG is exported by `CEPlanetWeatherModel definition`. Native UE
runs those same bytes through the generic Simulator field interpreter. GT's
`CEPlanetWeatherTests` exercises repeatability, forecast equality, dry/moist
forcing and event fade; `exportVectorsTo:` supplies exact native conformance
vectors and cubic arc-length paths. Exports are data, not independently authored
weather implementations.

The analytic preview has no evolving moisture reservoir or conserved transport
solver. Its complete reproducible state is model/input bytes, seed, event curves
and simulation time. Production Runtime/GemStone acceptance, durable terrain/input
journals, replication, event commands and detailed hazard/rendering integrations
remain open. This low-cost slice is intended to be measured and extended only
where believable weather requires more computation.


The current background profile is `planetary-weather-6-background` over `analytic-field-1`.
Pressure kernels supply their own analytic tangent gradients. Wind follows those
gradients with continuous hemisphere-dependent turning and inflow/outflow; no
Coriolis division becomes singular at the equator. Eighteen GT tests cover replay,
forecast, dry supply, lifecycle, pressure-reference/response, hemisphere and
high/low circulation, plus bounded extreme forcing. The scalar graph remains
bounded at 2091 nodes. These rules are an analytic game approximation, not a
conserved atmospheric solver. Older v1 bundles remain frozen reference artifacts.

Weather Character is uniform slot 15 (0–1), with global enable in slot 48.
It increases the smooth seeded regional extreme roll frequency and amplitude,
as well as ordinary natural strength. Terrain/moisture/biome inputs and explicit
authored event parameters retain their meaning. Disabled output is static climate
with reference pressure and no weather contributions. GT tests cover monotone
extreme windows across four seeds and three days, replay/dry supply, and disable.

Natural weather travel uses uniform 49 (nonnegative multiplier) and uniform 50
(phase offset in simulation seconds). The default reference fixture is 1 / 0.
Only circulation and seeded trajectory wandering use the resulting travel time;
solar heating, regional amplitude/extreme forcing and authored events still use
simulation time. The UE authoring knob maps Character to travel 1/2/4 at its
left/middle/right; the advanced multiplier is independently editable. An edit
anchors the trajectory with `offset += acceptedTime * (oldRate - newRate)`.
Three added GT tests verify fractional/stopped/faster trajectories, unchanged
thermal/extreme clocks, anchored full-channel continuity, repeatable forecasts
and unchanged authored vortex schedules. Exported vectors include all six rates
and their anchored past/now/future cases (240 point cases total).

The v5 profile appends `snowMmHour` as channel nine; `rainMmHour` is now liquid
rain. Both rates use water-equivalent mm/hour. A cubic smoothstep from -1 to +1 C
partitions total precipitation using the already-computed surface temperature.
Subtracting snow from total preserves every fixed-point unit. The split is a game
approximation without a vertical temperature/humidity column or accumulation.
All 240 previous vector cases conserve total precipitation exactly, with every
other channel unchanged. Two added GT tests exercise dry/warm/cold/mixed phase,
continuous conservation through freezing, replay/forecast equality and disable.
Source and program exports remain GT-authoritative.

Frontal precipitation uses `CEPlanetWeatherModel frontalDefinition`, profile
`planetary-weather-frontal-1` (225 nodes), after the 2091-node background stage.
The background adds air-mass temperature as channel ten and uses uniform 51 for
positive-land lapse removal; surface temperature and rain/snow still retain
terrain cooling. The frontal program consumes frozen canonical geometric ridge,
wind and moisture features, with two smooth spatial probes. Native preprocessing
owns tangent scalar geometry, while GT owns all front thresholds and lifting,
moisture/intensity/phase policy. Both execute through Simulator's existing field
interpreter. Metadata freezes stencil and probe parameters as canonical integers.

Cold fronts produce stronger narrow lifting; warm fronts extend precipitation
into the colder side. Moist stationary fronts can remain wet; moisture-starved
fronts remain dry. Rain/snow partition follows the cooled surface temperature,
with a 100 mm/h total cap. Background rainfall and mission timing are preserved.
The model is still an analytic game approximation without a conserved moisture
reservoir or vertical wet-bulb/column physics. Full canonical sampling inputs and
their order are part of replay identity, independently of the editor camera.
Four added GT tests cover lifting/advection/moisture, snow/caps/disable, smooth
forcing/replay and lapse removal. Eight frontal-stage conformance vectors extend
the 240 background vectors. The displayed front and its rain query the same
boundary confidence; visual line geometry never drives simulation.
