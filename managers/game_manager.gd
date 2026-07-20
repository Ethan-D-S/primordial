extends Node

# persistent player state variables
var player_mass: float = 1.0
var player_energy: int = 2
var player_stored_energy: int = 0
var player_algae_gm: float = 0.0
var player_wanderer_gm: float = 0.0

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

# save player state : use when exiting levels, or on death
func save_player_state(player: CharacterBody2D) -> void:
	player_mass = player.mass
	player_energy = player.energy
	player_stored_energy = player.stored_energy
	player_algae_gm = player.algaeGM
	player_wanderer_gm = player.wandererGM

# restore player state : use when player is loaded
func restore_player_state(player: CharacterBody2D) -> void:
	player.mass = player_mass
	player.energy = player_energy
	player.stored_energy = player_stored_energy
	player.algaeGM = player_algae_gm
	player.wandererGM = player_wanderer_gm
	
func player_dies(player: CharacterBody2D, save: bool = false) -> void:
	if save: 
		save_player_state(player)
	# load game over screen?
	go_to_biome(current_biome) 
