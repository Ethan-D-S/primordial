extends CharacterBody2D

## Starting variables
@export var base_speed = 100
@export var base_mass: float = 1

## Updating variables
var speed = base_speed
var mass: float = base_mass
@export var max_mass: float = 5.0
#var is_moving: bool = false

## signals
signal grew
signal energy_changed(current_energy: int)
signal state_changed(new_state: PlayerState)

# GM quantities: probably should port to a dedicated data structure
var algaeGM : float = 0.0
var wandererGM : float = 0.0

# 
var scale_factor: float = 1

# energy is consumed by abilities, gained by eating etc.
var energy: int = 2
var max_energy: int = 5

# stored energy is used to grow/ evolve, stored by holding a button
# stored energy is not available for abilites
var stored_energy: int = 0
var max_stored_energy: int = 1

#eating vars
var eating_timer: float = 0.0
var eat_duration: float = 1.0 # time to eat
var being_eaten_by = null

@onready var player_sprite = $Sprite

@onready var dash: Node = $Abilities/DashAbility
@onready var regen: Node = $Abilities/RegenEnergyAbility
@onready var creature_data = CreatureData # ref autoload

var this_creature_type = "player"

## Player States
enum PlayerState {IDLE, MOVING}

# setter for movement states
var current_state: PlayerState = PlayerState.IDLE:
	set(value):
		if value != current_state:
			current_state = value
			# emit signal when states change
			emit_signal("state_changed", value)

func _ready():
	#GameManager.restore_player_state(self)
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
	## Dash
	if event.is_action_pressed("dash"):
		# TODO: functionalize to a try_activate() or similar
		# check if player has energy
		if energy >= dash.energy_cost:
			spend_energy(dash.energy_cost)
			dash.activate()
	
	## Regen
	if event.is_action_pressed("regenerate"):
		
		if energy < max_energy:
			regen.activate()

func _physics_process(delta):
	#skip normal movement when abilities take precedence
	if is_dashing() or is_regenerating():
		return
		
	get_input()
	
	# being eaten
	if being_eaten_by:
		#set_flash(true)
		eating_timer -= delta

		if eating_timer <= 0:
			being_eaten_by.eat(mass, this_creature_type)
			queue_free()
	
	#update player state
	if velocity != Vector2.ZERO:
		#emits to Animations
		current_state = PlayerState.MOVING
	else:
		current_state = PlayerState.IDLE
	
	move_and_slide()


# update scale based on mass
func grow():
	# calculate increase with current mass 
	var new_scale = sqrt(mass) * scale_factor
	# assign to scale property
	scale = Vector2(new_scale, new_scale)
	update_speed()
	emit_signal("grew")

func die() -> void:
	pass
	#GameManager.save_player_state(self)
	#GameManager game over screen or instant respawn

# TODO: functionalize with can_eat, better grouping, creature data
func _on_touch_area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	# eating algae
	if area.is_in_group("algae"):
		area.start_being_eaten_by(self)
	# eating wanderer
	if entity.is_in_group("wanderer") && entity.mass < mass:
		entity.start_being_eaten_by(self)


func _on_touch_area_exited(area: Area2D) -> void:
		if area.is_in_group("algae"):
			area.cancel_eat()


func eat(mass_eaten, creature_type):
	
	
	if not $EatSound.playing:
		$EatSound.play()
		
	# look up entry for creature type
	var data = creature_data.get_creature_data(creature_type)
	
	gain_mass(mass_eaten )
	gain_energy(data["energy_on_eat"])
	#grow()

func start_being_eaten_by(predator):
	being_eaten_by = predator
	eating_timer = eat_duration
	set_flash(true)

# reset predator/eating vars, end flash
func cancel_eat():
	being_eaten_by = null
	eating_timer = 0.0
	set_flash(false)

func set_flash(on: bool) -> void:
	player_sprite.material.set_shader_parameter("active", on)


## STAT MUTATORS

func gain_mass(mass_gained) -> void:
	# check if maximum mass has been reached
	if mass < max_mass:
		mass += mass_gained
		# emit signal for effects/animations?
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

# boolean check for abilities and movement active
func is_dashing() -> bool:  
	return dash.is_dashing
func is_regenerating() -> bool:
	return regen.is_active
func is_moving() -> bool:
	if velocity:
		return true
	return false
