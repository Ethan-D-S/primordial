extends Node

const EXPLOSION_SCENE := preload("res://effects/explosion.tscn")

func spawn_explosion(pos: Vector2) -> void:
	print("spawn_explosion called")
	var explosion := EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = pos
