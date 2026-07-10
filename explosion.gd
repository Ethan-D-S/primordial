extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 
	#$CPUParticles2D.scale = Vector2(4.0, 4.0)
	$CPUParticles2D.finished.connect(_on_particles_finished)
	$CPUParticles2D.emitting = true

func _on_particles_finished() -> void:
	queue_free()
