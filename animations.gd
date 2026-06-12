extends Node

## Handles non-ability animations

@onready var idle: AnimatedSprite2D = $idle
#@onready var moving: AnimatedSprite2D = $moving
#@onready var dashing: AnimatedSprite2D = $dashing

@onready var player = get_parent()

func _ready() -> void:
	play_idle()
	
func _physics_process(delta: float) -> void:
	print("player sprite scale: ", player.player_sprite.scale)
	idle.global_position = player.global_position
	idle.scale = player.player_sprite.scale

func play_idle():
	idle.play("idle")

#func play_moving():
	#movement.play("move")
	
# dash
