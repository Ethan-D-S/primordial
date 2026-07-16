extends CharacterBody2D

enum State { WANDER, STALK, CHARGE, BURST, SEARCH }

var base_speed = 90
var speed = base_speed
var base_mass = 10
var mass = base_mass
var target: Node2D = null
var run_timer: float = 0.0
var run_duration: float = 0.0
var current_direction = Vector2.UP
var target_speed: float = 0.0
var this_creature_type = "hunter"

var state: State = State.WANDER

# --- stalking ---
var angle_spread: float = 0.5          # radians, random cone around the direction-to-target
var stalk_speed_mult: float = 0.6
var burst_interval_min: float = 2.5
var burst_interval_max: float = 5.0
var burst_timer: float = 0.0

# --- charge (telegraph) ---
var charge_duration: float = 0.4

# --- burst ---
var burst_speed_mult: float = 3.0
var burst_duration: float = 0.5
var burst_direction: Vector2 = Vector2.ZERO
var burst_timer_active: float = 0.0

# --- losable / search ---
@export var search_duration: float = 2.0       # how long it chases the last known position
@export var reacquire_cooldown: float = 3.0     # cooldown before it can pick a new target after fully losing one
var search_timer: float = 0.0
var reacquire_timer: float = 0.0
var last_known_position: Vector2 = Vector2.ZERO

# --- retargeting (distraction) ---
@export var retarget_hysteresis: float = 0.8    # candidate must be this fraction of current distance (or closer) to steal aggro

# --- eating ---
var eating_timer: float = 0.0
var eat_duration: float = 0.5
var being_eaten_by = null

@onready var hunter_sprite = $Sprite


func _ready() -> void:
	hunter_sprite.material = hunter_sprite.material.duplicate()
	print("Hunter spawned")


func _physics_process(delta: float) -> void:
	match state:
		State.WANDER:
			tick_wander(delta)
		State.STALK:
			tick_stalk(delta)
		State.CHARGE:
			tick_charge(delta)
		State.BURST:
			tick_burst(delta)
		State.SEARCH:
			tick_search(delta)

	if being_eaten_by:
		eating_timer -= delta
		if eating_timer <= 0:
			being_eaten_by.eat(mass, this_creature_type)
			Effects.spawn_explosion(global_position)
			queue_free()
			return

	var accel = 10.0 if state == State.BURST else 5.0
	velocity = lerp(velocity, current_direction * target_speed, accel * delta)
	move_and_slide()


# ---------------- WANDER ----------------

func tick_wander(delta: float) -> void:
	run_timer -= delta
	if run_timer <= 0:
		_start_new_wander_leg()

	target_speed = speed

	if reacquire_timer > 0:
		reacquire_timer -= delta
		return

	var found = find_target()
	if found:
		target = found
		state = State.STALK
		burst_timer = randf_range(burst_interval_min, burst_interval_max)


func _start_new_wander_leg() -> void:
	run_duration = randf_range(0.3, 1.5)
	current_direction = Vector2.from_angle(randf_range(0, TAU))
	run_timer = run_duration


# ---------------- STALK ----------------

func tick_stalk(delta: float) -> void:
	if not is_instance_valid(target):
		target = null
		state = State.WANDER
		return

	if not is_on_screen(target):
		_enter_search()
		return

	run_timer -= delta
	burst_timer -= delta

	if run_timer <= 0:
		var toward_target = (target.global_position - global_position).normalized()
		current_direction = toward_target.rotated(randf_range(-angle_spread, angle_spread))
		run_duration = randf_range(0.6, 1.8)
		run_timer = run_duration
		_try_retarget()

	target_speed = speed * stalk_speed_mult

	if burst_timer <= 0:
		_enter_charge()


func _try_retarget() -> void:
	var candidate = find_target()
	if candidate and candidate != target:
		var current_dist = global_position.distance_to(target.global_position)
		var candidate_dist = global_position.distance_to(candidate.global_position)
		if candidate_dist < current_dist * retarget_hysteresis:
			target = candidate


# ---------------- CHARGE ----------------

func _enter_charge() -> void:
	state = State.CHARGE
	set_flash(true)


func tick_charge(delta: float) -> void:
	if not is_instance_valid(target):
		set_flash(false)
		target = null
		state = State.WANDER
		return

	charge_duration -= delta
	target_speed = 0.0  # freeze in place as the telegraph

	if charge_duration <= 0:
		charge_duration = 0.4  # reset for next time (see note below re: @export)
		_enter_burst()


# ---------------- BURST ----------------

func _enter_burst() -> void:
	state = State.BURST
	set_flash(false)
	burst_direction = (target.global_position - global_position).normalized()
	burst_timer_active = burst_duration


func tick_burst(delta: float) -> void:
	burst_timer_active -= delta
	current_direction = burst_direction
	target_speed = speed * burst_speed_mult

	if burst_timer_active <= 0:
		if is_instance_valid(target) and is_on_screen(target):
			state = State.STALK
			run_timer = 0.0
			burst_timer = randf_range(burst_interval_min, burst_interval_max)
		else:
			_enter_search()


# ---------------- SEARCH (losable) ----------------

func _enter_search() -> void:
	state = State.SEARCH
	search_timer = search_duration
	last_known_position = target.global_position if is_instance_valid(target) else global_position


func tick_search(delta: float) -> void:
	search_timer -= delta

	var to_last_known = last_known_position - global_position
	if to_last_known.length() > 4.0:
		current_direction = to_last_known.normalized()
		target_speed = speed * stalk_speed_mult
	else:
		target_speed = 0.0

	if is_instance_valid(target) and is_on_screen(target):
		state = State.STALK
		run_timer = 0.0
		return

	if search_timer <= 0:
		target = null
		state = State.WANDER
		reacquire_timer = reacquire_cooldown


# ---------------- targeting / vision helpers ----------------

func find_target() -> Node2D:
	var bodies = $sight.get_overlapping_bodies()
	var nearest: Node2D = null
	var nearest_dist: float = INF

	for body in bodies:
		if body.is_in_group("player") or body.is_in_group("wanderer"):
			var d = global_position.distance_squared_to(body.global_position)
			if d < nearest_dist:
				nearest = body
				nearest_dist = d

	return nearest


func is_on_screen(node: Node2D) -> bool:
	var screen_rect = get_viewport().get_visible_rect()
	var screen_pos = get_viewport().get_canvas_transform() * node.global_position
	return screen_rect.has_point(screen_pos)


# ---------------- eating (unchanged) ----------------

func eat(mass_eaten, creature_type):
	mass += mass_eaten
	grow()


func _on_touch_area_entered(area: Area2D) -> void:
	if area.is_in_group("algae"):
		area.start_being_eaten_by(self)
	elif area.is_in_group("player"):
		area.get_parent().start_being_eaten_by(self)
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


func cancel_eat():
	being_eaten_by = null
	eating_timer = 0.0
	set_flash(false)


func update_speed():
	speed = max(base_speed * base_mass / mass, 100)


func grow():
	var new_scale = sqrt(mass)
	scale = Vector2(new_scale, new_scale)
	update_speed()


func set_flash(on: bool) -> void:
	hunter_sprite.material.set_shader_parameter("active", on)
