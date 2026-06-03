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
	
	player.energy_changed.connect(_on_player_energy_changed)
	_on_player_energy_changed(player.energy)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_energy_changed(current_energy: int) -> void:
	for i in energy_list.size():
		if i < current_energy:
			energy_list[i].texture = energy_texture
		else:
			energy_list[i].texture = empty_texture
	
