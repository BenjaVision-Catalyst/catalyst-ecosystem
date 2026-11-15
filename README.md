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
systems share planetary circulation, upstream geography and bounded authored
storm/vortex events. Temperature, canonical wind, rain, dust and cloud fraction
are outputs. No creature behaviour or presentation assets enter the model.

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
