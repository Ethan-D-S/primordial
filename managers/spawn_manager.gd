extends Node2D

@export var algae_scene: PackedScene
@export var wanderer_scene: PackedScene
@export var hunter_scene: PackedScene

# world dimensions: change when intended world size changes
const WORLD_WIDTH = 19200.0
const WORLD_HEIGHT = 10800.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# could generalize this to spawn anything
func spawn_algae(position: Vector2):
	var new_algae = algae_scene.instantiate()
	new_algae.global_position = position
	add_child(new_algae)
	
func generate_algae_spawn_location():
	var x = randf_range(0, WORLD_WIDTH)
	var y = randf_range(0, WORLD_HEIGHT)
	return Vector2(x, y)
	
func spawn_wanderers(position: Vector2):
	var new_wanderer = wanderer_scene.instantiate()
	new_wanderer.global_position = position
	add_child(new_wanderer)
	
func generate_wanderer_spawn_location():
	var x = randf_range(0, WORLD_WIDTH)
	var y = randf_range(0, WORLD_HEIGHT)
	return Vector2(x, y)

func spawn_hunters(position: Vector2):
	var new_hunter = hunter_scene.instantiate()
	new_hunter.global_position = position
	add_child(new_hunter)
