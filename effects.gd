extends Node

const EXPLOSION_SCENE := preload("res://effects/explosion.tscn")

# when called: instantiate explosion at chosen pos
func spawn_explosion(pos: Vector2) -> void:
	var explosion := EXPLOSION_SCENE.instantiate()
	explosion.global_position = pos
	get_tree().current_scene.add_child(explosion)
	
