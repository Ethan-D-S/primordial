extends CharacterBody2D

var speed = 100
var mass = 2
var target: Node2D = null



func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		print("chasing: ", target.global_position)
		# normalize position difference so that the vector will be no greater than 1
		var direction = (target.global_position-global_position).normalized()
		velocity = lerp(velocity, direction * speed, 10*delta)
		
	else:
		target = find_target()
		
	move_and_slide()



func find_target() -> Node2D:
	#get bodies from sight area
	var areas = $sight_area.get_overlapping_areas()
	#print("areas found: ", areas.size())
	for area in areas:
		if area.is_in_group("algae"):
			return area
	# no targets
	return null
		

func eat(mass_eaten):
	mass += mass_eaten
#	grow()


func _on_border_area_entered(area: Area2D) -> void:
	if area.is_in_group("algae"):
		eat(area.mass)
		area.queue_free()
