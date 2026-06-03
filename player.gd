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
var max_energy: int = 5

# stored energy is used to grow/ evolve, stored by holding a button
# stored energy is not available for abilites
var stored_energy: int = 0
var max_stored_energy: int = 1

@onready var dash: Node = $Abilities/DashAbility

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
	
# handles ability input
func _input(event):
	if event.is_action_pressed("dash"):
		# TODO: functionalize to a try_activate() or similar
		# check if player has energy
		if energy >= dash.energy_cost:
			spend_energy(dash.energy_cost)
			dash.activate()

		
	
func _physics_process(delta):
	#skip normal movement if dashing
	if is_dashing():
		return
		
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
	

# use when increasing energy
func gain_energy(energy_gained) -> void:
	# check if energy is full
	if energy < max_energy:
		energy += energy_gained
		# connect to UI
		emit_signal("energy_changed", energy)

# use when reducing energy
func spend_energy(energy_spent) -> void:
		if energy > 0:
			energy -= energy_spent
			emit_signal("energy_changed", energy)

func update_speed():
	speed = max(base_speed * base_mass/mass, base_speed)

# boolean check for abilities dashing active
func is_dashing() -> bool:  
	return dash.is_dashing
