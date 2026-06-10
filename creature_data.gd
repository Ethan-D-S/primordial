extends Node

var creature_table: Dictionary = {
	
	## creature entries
	"algae" : {"energy_on_eat": 1, "GM_type": "algae_GM", "GM_drop_chance": 1},
	"wanderer" : {"energy_on_eat": 1, "GM_type": "wanderer_GM", "GM_drop_chance": 1},
	#player?

}

func get_creature_data(creatureID: String):
	if creature_table.has(creatureID):
		return creature_table[creatureID]
	else: 
		# should produce an error
		return null
