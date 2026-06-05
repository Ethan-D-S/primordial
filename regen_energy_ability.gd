class_name RegenEnergyAbility
extends Ability

# this should activate when player is in a sunlight area
# sunlight areas moving around could make this a bit more engaging

# player freezes while regenerating, making them vulnerable, hollow-knight style
# time from button press to effect
@export var regen_duration: float = 2.0
@export var energy_regen: int = 1

var regen_timer: float = 0.0
var is_active: bool = false




func _ready() -> void:
	# ensure parent class is ready
	super()

func _physics_process(delta: float) -> void:
	#reduce regen timer
	if is_active:
		regen_timer -= delta
		player.velocity = Vector2.ZERO
	
		# cancel regen
		if regen_timer <= 0:
			is_active = false
			player.gain_energy(energy_regen)
			return
	

func activate():
	if is_active:
		return
	is_active = true
	regen_timer = regen_duration
