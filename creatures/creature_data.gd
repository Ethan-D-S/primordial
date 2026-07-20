extends Node

var creature_table: Dictionary = {
	
	## creature entries
	"algae" : {"energy_on_eat": 1, "GM_type": "algae_GM", "GM_drop_chance": 1},
	"wanderer" : {"energy_on_eat": 1, "GM_type": "wanderer_GM", "GM_drop_chance": 1},
	"hunter" : {"energy_on_eat": 10, "GM_type": "hunter_GM", "GM_drop_chance": 1},
	"player" : {"energy_on_eat": 0, "GM_type": "none", "GM_drop_chance": 0 },

}

func get_creature_data(creatureID: String):
	if creature_table.has(creatureID):
		return creature_table[creatureID]
	else: 
		# should produce an error
		return null
