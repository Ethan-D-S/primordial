extends Node

## Handles non-ability animations

@onready var idle: AnimatedSprite2D = $idle
@onready var moving: AnimatedSprite2D = $moving
#@onready var dashing: AnimatedSprite2D = $dashing

@onready var player = get_parent()

func _ready() -> void:
	play_idle()


func _physics_process(delta: float) -> void:
	idle.global_position = player.global_position
	moving.global_position = player.global_position
	moving.rotation = player.rotation + player.player_sprite.rotation
	
	# idle.scale = player.player_sprite.scale * 2


func play_idle():
	moving.stop()
	moving.visible = false
	idle.play("idle")

func play_moving():
	# stop idle animation
	idle.stop()
	# play moving animation.
	moving.visible = true
	moving.play("moving")
	
# dash


func _on_player_state_changed(new_state: int) -> void:
	match new_state:
		player.PlayerState.IDLE: play_idle()
		player.PlayerState.MOVING: play_moving()
