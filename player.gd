extends CharacterBody2D

@export var base_speed = 100
@export var base_mass = 1

signal grew

var speed = base_speed
var mass = base_mass

var scale_factor = 1

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
	grow()
	
func update_speed():
	speed = max(base_speed * base_mass/mass, base_speed)
