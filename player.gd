extends CharacterBody2D

@export var base_speed = 100
@export var base_mass = 1

signal grew
signal energy_changed(current_energy: int)

var speed = base_speed
var mass = base_mass

var scale_factor = 1

# energy is consumed by abilities, gained by eating etc.
var energy: int = 2
var max_energy: int = 3

# stored energy is used to grow/ evolve, stored by holding a button
# stored energy is not available for abilites
var stored_energy: int = 0
var max_stored_energy: int = 1

func _ready():
	# get center coords of screen
	var center_position = get_viewport_rect().size / 2
	
	# set position to center
	position = center_position
	#ensure starting size is correct for mass
	grow()


func get_input():
	look_at(get_global_mouse_position())
	velocity = transform.x * Input.get_axis("down", "move_forward") * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

# update scale based on mass
func grow():
	# calculate increase with current mass 
	var new_scale = sqrt(mass) * scale_factor
	# assign to scale property
	scale = Vector2(new_scale, new_scale)
	update_speed()
	emit_signal("grew")
	
func eat(mass_eaten):
	
	if not $EatSound.playing:
		$EatSound.play()
	
	mass += mass_eaten
	gain_energy(1)
	grow()
	

func gain_energy(energy_gained):
	energy += energy_gained
	emit_signal("energy_changed", energy)

func update_speed():
	speed = max(base_speed * base_mass/mass, base_speed)
