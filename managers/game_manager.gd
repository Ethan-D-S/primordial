extends Node

# persistent player state variables
var player_mass: float = 1.0
var player_energy: int = 2
var player_stored_energy: int = 0

var gm := {
	# green
	"algae": 0,
	# blue
	"wanderer": 0,
	# red
	"spitter": 0,
}

var abilities := {
	"dash": {"unlocked": false, "cost_type": "wanderer", "cost": 5},
	"regen": {"unlocked": false, "cost_type": "algae", "cost": 10},
	"enzyme": {"unlocked": false, "cost_type": "spitter", "cost": 5},
}

var grow_cost := 5
var grow_cost_mult := 1.5

# biome
var current_biome: String = "tide_pool"

# levels dictionary
const LEVELS = {
	"tide_pool": "res://levels/TidePool.tscn",
}

# change scene function
func go_to_biome(biome_key: String) -> void:
	#add error handling
	current_biome = biome_key
	get_tree().change_scene_to_file(LEVELS[biome_key])


	
func player_dies(player: CharacterBody2D) -> void:
	# load game over screen?
	go_to_biome(current_biome) 
