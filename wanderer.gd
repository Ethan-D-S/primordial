extends CharacterBody2D

var speed = 100
var mass = 2
var target: Node2D = null



func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		# normalize position difference so that the vector will be no greater than 1
		var direction = (target.global_position-global_position).normalized()
		velocity = lerp(velocity, direction * speed, 10*delta)
		
	else:
		target = find_target()
		
	move_and_slide()

# triggers enterer's eat()
func _on_border_body_entered(body: Node2D) -> void:
	if body.mass > mass:
		body.eat(mass)
		queue_free()

func find_target() -> Node2D:
	#get bodies from sight area
	var bodies = $sight_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("algae"):
			return body
	# no targets
	return null
		

func eat(mass_eaten):
	mass += mass_eaten
#	grow()
