extends CharacterBody2D

@export var speed = 400
@export var scale_factor = 0.05

func _ready():
	# get center coords of screen
	var center_position = get_viewport_rect().size / 2
	
	# set position to center
	position = center_position


func get_input():
	look_at(get_global_mouse_position())
	velocity = transform.x * Input.get_axis("down", "move_forward") * speed

func _physics_process(delta):
	get_input()
	move_and_slide()


func grow():
	
	scale += scale * scale_factor
	#proportionate slowdown for growth
	speed *= 1/(1+scale_factor)

func eat():
	if not $EatSound.playing:
		$EatSound.play()
	grow()
