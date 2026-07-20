extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_grew() -> void:
	var z = 2.0 / log(get_parent().mass * 2.0 + 1)
	var tween = create_tween()
	tween.tween_method(set_zoom, get_zoom(), Vector2(z, z), 0.4)
