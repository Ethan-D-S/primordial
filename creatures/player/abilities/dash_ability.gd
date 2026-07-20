class_name DashAbility
extends Ability

@export var dash_speed: float = 600
@export var dash_duration: float = .2
# steer strength?

var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ensure parent class is ready
	super()

func _physics_process(delta: float) -> void:
	#reduce dash timer
	if is_dashing:
		dash_timer -= delta
	
		# cancel dash
		if dash_timer <= 0:
			is_dashing = false
			return
	
		player.velocity = dash_direction * dash_speed
		player.move_and_slide()

func activate():
	is_dashing = true
	
	# set dash timer
	dash_timer = dash_duration
	
	# set dash direction
	dash_direction = player.transform.x
