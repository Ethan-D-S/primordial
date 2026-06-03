class_name Ability
extends Node

# most of this is built to be overridden in the child classes

@export var energy_cost: float = 0.0
@export var cooldown_duration: float = 0.0
@export var on_cooldown: bool = false
@export var cooldown_timer: float = 0.0

var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
