extends Area2D

@export var mass: float = 0.5

var this_creature_type: String = "algae"
#eating vars
var eating_timer: float = 0.0
var eat_duration: float = 0.5 # time to eat
var being_eaten_by = null
@onready var algae_sprite = $Sprite

func set_flash(on: bool) -> void:
	algae_sprite.material.set_shader_parameter("active", on)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	algae_sprite.material = algae_sprite.material.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if being_eaten_by:
		#modulate flash
		eating_timer -= delta

		if eating_timer <= 0:
			being_eaten_by.eat(mass, this_creature_type)
			queue_free()
			

# helper to identify eater and start the timer.
# takes over responsibility for algae being eaten from the predator.
func start_being_eaten_by(predator):
	being_eaten_by = predator
	eating_timer = eat_duration
	set_flash(true)
	
# reset predator/eating vars, end flash
func cancel_eat():
	being_eaten_by = null
	eating_timer = 0.0
	set_flash(false)
