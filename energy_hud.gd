extends HBoxContainer

@export var energy_texture: Texture2D
@export var empty_texture: Texture2D
@export var stored_texture: Texture2D

var player
var energy_list : Array[TextureRect]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# build bubbles based on max energy
	# TODO functionalize this block
	for i in player.max_energy:
		var bubble = TextureRect.new()
		bubble.texture = energy_texture
		add_child(bubble)
		energy_list.append(bubble)
	
	#TODO animate bubble changes
	player.energy_changed.connect(_on_player_energy_changed)
	_on_player_energy_changed(player.energy)
	
func _process(delta: float) -> void:
	pass


# assign texture to bubbles in energy list based on how much energy player has 
func _on_player_energy_changed(current_energy: int) -> void:
	for i in energy_list.size():
		if i < current_energy:
			energy_list[i].texture = energy_texture
		else:
			energy_list[i].texture = empty_texture
	
