extends CharacterBody2D

var base_speed = 100
var speed = base_speed

var base_mass = 5
var mass = base_mass

var target: Node2D = null

var run_timer: float = 0.0
var run_duration: float = 0.0
var current_direction = Vector2.UP

var this_creature_type = "hunter"

#eating vars
var eating_timer: float = 0.0
var eat_duration: float = 0.5 # time to eat
var being_eaten_by = null
@onready var hunter_sprite = $Sprite

func _ready() -> void:
	# make sprite material (for flash) unique to each instance of the entity
	hunter_sprite.material = hunter_sprite.material.duplicate()
	print("Hunter spawned")

func _physics_process(delta: float) -> void:
	# keep timer consistent with framerate
	run_timer -= delta
	
	# being eaten=
	if being_eaten_by:
		#set_flash(true)
		eating_timer -= delta

		if eating_timer <= 0:
			being_eaten_by.eat(mass, this_creature_type)
			Effects.spawn_explosion(global_position)
			queue_free()
	
	# check that target exists
	if is_instance_valid(target):
		# bias direction toward target, but don't snap perfectly
		var toward_target = (target.global_position - global_position).normalized()
		current_direction = current_direction.lerp(toward_target, 0.4).normalized()
		
	## TODO: functionalize this
		if run_timer <= 0:
			# has valid target, stay focused
			_start_new_run(true)
	else:
		# does not have a valid target, attempt to find one
		target = find_target()
		
		# still no target, wander unfocused
		if run_timer <= 0:
			_start_new_run(false)

	velocity = lerp(velocity, current_direction * speed, 5 * delta)
	move_and_slide()


# uses sight node
func find_target() -> Node2D:
	#get bodies and areas from sight area
	var areas = $sight.get_overlapping_areas()
	var bodies = $sight.get_overlapping_bodies()
	#print("areas found: ", areas.size())
	
	# algae
	#for area in areas:
	#	if area.is_in_group("algae"):
	#		return area
	
	for body in bodies:
		if body.is_in_group("player"):
			print("targeting player")
			return body
	# no targets
	return null
		

func _start_new_run(focused: bool = false) -> void:
	if focused:
		# short pause then recommit, favors current direction
		run_duration = randf_range(0.6, 1.8)
		current_direction = current_direction.rotated(randf_range(-0.3, 0.3))
	else:
		# tumble: longer pause, bigger random reorientation
		run_duration = randf_range(0.3, 1.5)
		# TAU is the circumference of the unit circle in radians
		current_direction = Vector2.from_angle(randf_range(0, TAU))
	run_timer = run_duration


func eat(mass_eaten, creature_type):
	mass += mass_eaten
	grow()

# eating
# TODO: functionalize with can_eat, better grouping, creature data
func _on_touch_area_entered(area: Area2D) -> void:
	if area.is_in_group("algae"):
		area.start_being_eaten_by(self)
	
	# eating player
	elif area.is_in_group("player"):
		area.get_parent().start_being_eaten_by(self)
	
	# eating wanderers
	elif area.is_in_group("wanderer") && area.get_parent().mass < mass:
		area.get_parent().start_being_eaten_by(self)


func _on_touch_area_exited(area: Area2D) -> void:
	if area.is_in_group("algae"):
		area.cancel_eat()
	
	elif area.is_in_group("player"):
		area.get_parent().cancel_eat()
	
	elif area.is_in_group("wanderer"):
		area.get_parent().cancel_eat()

func start_being_eaten_by(predator):
	being_eaten_by = predator
	eating_timer = eat_duration
	set_flash(true)
	
# reset predator/eating vars, end flash
func cancel_eat():
	being_eaten_by = null
	eating_timer = 0.0
	set_flash(false)


func update_speed():
	speed = max(base_speed * base_mass/mass, 100)

func grow():
	# calculate increase with current mass 
	var new_scale = sqrt(mass)
	# assign to scale property
	scale = Vector2(new_scale, new_scale)
	update_speed()

func set_flash(on: bool) -> void:
	hunter_sprite.material.set_shader_parameter("active", on)
