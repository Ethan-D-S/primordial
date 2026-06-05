extends Area2D

@export var mass: float = 2.0

var this_creature_type: String = "algae"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	# trigger body's specific eat method w/ mass
	body.eat(mass, this_creature_type)
	queue_free()
