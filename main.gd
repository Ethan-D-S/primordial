extends Node

#get the algae spawner
@onready var spawner = $SpawnManager


func populate_world(algae_count, wanderer_count):
	for i in algae_count:
		spawner.spawn_algae(spawner.generate_algae_spawn_location())
	for i in wanderer_count:
		spawner.spawn_wanderers(spawner.generate_wanderer_spawn_location())
	
	# hunter test
	spawner.spawn_hunters(spawner.generate_wanderer_spawn_location())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_world(1000, 500)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_algae_respawn_timeout() -> void:
	populate_world(250, 0)
