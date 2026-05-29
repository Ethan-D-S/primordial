extends CharacterBody2D

var speed = 100
var mass = 2
var target: Node2D = null

var run_timer: float = 0.0
var run_duration: float = 0.0
var current_direction = Vector2.UP


func _physics_process(delta: float) -> void:
	run_timer -= delta

	if is_instance_valid(target):
		# Bias direction toward target, but don't snap perfectly
		var toward_target = (target.global_position - global_position).normalized()
		current_direction = current_direction.lerp(toward_target, 0.15).normalized()
		# Longer runs when chasing — less tumbling near food
		if run_timer <= 0:
			_start_new_run(true)
	else:
		target = find_target()
		if run_timer <= 0:
			_start_new_run(false)

	velocity = lerp(velocity, current_direction * speed, 5 * delta)
	move_and_slide()

func _ready() -> void:
	_start_new_run()

# uses sight node
func find_target() -> Node2D:
	#get bodies from sight area
	var areas = $sight.get_overlapping_areas()
	#print("areas found: ", areas.size())
	for area in areas:
		if area.is_in_group("algae"):
			return area
	# no targets
	return null
		

func _start_new_run(focused: bool = false) -> void:
	if focused:
		# Short pause then recommit — mostly keeps current direction
		run_duration = randf_range(0.6, 1.2)
		current_direction = current_direction.rotated(randf_range(-0.3, 0.3))
	else:
		# Tumble: longer pause, bigger random reorientation
		run_duration = randf_range(0.3, 0.8)
		current_direction = Vector2.from_angle(randf_range(0, TAU))
	run_timer = run_duration


func eat(mass_eaten):
	mass += mass_eaten
#	grow()

# eating static food, like algae
func _on_touch_area_entered(area: Area2D) -> void:
	if area.is_in_group("algae"):
		eat(area.mass)
		area.queue_free()

# contacted by body, like player
func _on_touch_body_entered(body: Node2D) -> void:
	if body.mass > mass:
		body.eat(mass)
		queue_free()
