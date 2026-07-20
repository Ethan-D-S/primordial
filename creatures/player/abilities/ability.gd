class_name Ability
extends Node

# most of this is built to be overridden in the child classes

@export var energy_cost: float = 0.0
@export var cooldown_duration: float = 0.0
@export var on_cooldown: bool = false
@export var cooldown_timer: float = 0.0

var player: Node

func _ready() -> void:
	# ensure abilities have access to the player
	player = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
