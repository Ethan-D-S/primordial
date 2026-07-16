extends CharacterBody2D

## Hunter creature: patrols like a Wanderer until it spots prey, then stalks,
## periodically charges up, and bursts toward its target.
##
## State flow: WANDER -> (spots prey) -> STALK -> (burst timer expires) -> CHARGE
## -> BURST -> back to STALK, or -> SEARCH if the target leaves the screen at any point.
## SEARCH either re-acquires the target or gives up and returns to WANDER.

enum State { WANDER, STALK, CHARGE, BURST, SEARCH }

var base_speed = 90
var speed = base_speed
var base_mass = 10
var mass = base_mass
var target: Node2D = null
var current_direction = Vector2.UP
var target_speed: float = 0.0
var this_creature_type = "hunter"

var state: State = State.WANDER

# Shared by WANDER and STALK: counts down to the next random-direction repick.
var redirect_timer: float = 0.0
var redirect_duration: float = 0.0

@export_group("Stalking")
## Half-width (radians) of the random cone around the direction-to-target
## used when picking a new stalking heading. 0 = beeline, larger = wobblier.
@export var angle_spread: float = 0.5
## Stalk speed as a fraction of the hunter's current (mass-adjusted) speed.
@export var stalk_speed_mult: float = 0.6
## Random range (seconds) between bursts while stalking.
@export var burst_interval_min: float = 2.5
@export var burst_interval_max: float = 5.0
var next_burst_timer: float = 0.0

@export_group("Charge & Burst")
## How long the hunter freezes and flashes before bursting.
@export var charge_duration: float = 0.4
## Burst speed as a multiple of the hunter's current (mass-adjusted) speed.
@export var burst_speed_mult: float = 3.0
## How long the burst lasts once launched.
@export var burst_duration: float = 0.5
var charge_timer: float = 0.0
var burst_direction: Vector2 = Vector2.ZERO
var burst_timer: float = 0.0
var charge_flash_frame: int = 0
var charge_flash_on: bool = false

@export_group("Search (losable)")
## How long the hunter waits, frozen, hoping the target reappears on screen.
@export var search_duration: float = 2.0
## Cooldown after fully giving up before the hunter is allowed to pick a new target.
@export var reacquire_cooldown: float = 3.0
var search_timer: float = 0.0
var reacquire_timer: float = 0.0

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

	if _tick_eating(delta):
		return

	var accel = 10.0 if state == State.BURST else 5.0
	velocity = lerp(velocity, current_direction * target_speed, accel * delta)
	move_and_slide()


## Returns true once redirect_timer has expired, resetting it to redirect_duration.
## Callers are responsible for setting redirect_duration and current_direction
## for their own state before or after calling this.
func _redirect_due(delta: float) -> bool:
	redirect_timer -= delta
	if redirect_timer <= 0:
		redirect_timer = redirect_duration
		return true
	return false


# ---------------- WANDER ----------------

func tick_wander(delta: float) -> void:
	if _redirect_due(delta):
		redirect_duration = randf_range(0.3, 1.5)
		current_direction = Vector2.from_angle(randf_range(0, TAU))

	target_speed = speed

	if reacquire_timer > 0:
		reacquire_timer -= delta
		return

	var found = find_target()
	if found:
		target = found
		state = State.STALK
		next_burst_timer = randf_range(burst_interval_min, burst_interval_max)


# ---------------- STALK ----------------

func tick_stalk(delta: float) -> void:
	if not is_instance_valid(target):
		target = null
		state = State.WANDER
		return

	if not is_on_screen(target):
		_enter_search()
		return

	if _redirect_due(delta):
		redirect_duration = randf_range(0.6, 1.8)
		var toward_target = (target.global_position - global_position).normalized()
		current_direction = toward_target.rotated(randf_range(-angle_spread, angle_spread))

	target_speed = speed * stalk_speed_mult

	next_burst_timer -= delta
	if next_burst_timer <= 0:
		_enter_charge()


# ---------------- CHARGE ----------------

func _enter_charge() -> void:
	state = State.CHARGE
	charge_timer = charge_duration
	charge_flash_frame = 0
	charge_flash_on = false


func tick_charge(delta: float) -> void:
	if not is_instance_valid(target):
		set_flash(false)
		target = null
		state = State.WANDER
		return

	charge_timer -= delta
	target_speed = 0.0  # freeze in place as the telegraph

	# Strobe the flash every 2 physics frames for a rapid warning flicker.
	charge_flash_frame += 1
	if charge_flash_frame % 2 == 0:
		charge_flash_on = !charge_flash_on
		set_flash(charge_flash_on)

	if charge_timer <= 0:
		_enter_burst()


# ---------------- BURST ----------------

func _enter_burst() -> void:
	state = State.BURST
	set_flash(false)
	burst_direction = (target.global_position - global_position).normalized()
	burst_timer = burst_duration


func tick_burst(delta: float) -> void:
	current_direction = burst_direction
	target_speed = speed * burst_speed_mult

	burst_timer -= delta
	if burst_timer <= 0:
		if is_instance_valid(target) and is_on_screen(target):
			state = State.STALK
			redirect_timer = 0.0
			next_burst_timer = randf_range(burst_interval_min, burst_interval_max)
		else:
			_enter_search()


# ---------------- SEARCH (losable) ----------------

func _enter_search() -> void:
	state = State.SEARCH
	search_timer = search_duration


func tick_search(delta: float) -> void:
	search_timer -= delta
	target_speed = 0.0  # hold position while waiting for the target to reappear

	if is_instance_valid(target) and is_on_screen(target):
		state = State.STALK
		redirect_timer = 0.0
		return

	if search_timer <= 0:
		target = null
		state = State.WANDER
		reacquire_timer = reacquire_cooldown


# ---------------- targeting / vision helpers ----------------

## Returns the nearest valid prey (player or wanderer) in sight, or null.
## Distraction emerges naturally here: a closer wanderer will always beat
## a farther-away player when a target is being freshly chosen.
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


## True if the given node is within the current camera's visible area.
func is_on_screen(node: Node2D) -> bool:
	var screen_rect = get_viewport().get_visible_rect()
	var screen_pos = get_viewport().get_canvas_transform() * node.global_position
	return screen_rect.has_point(screen_pos)


# ---------------- eating ----------------

## Advances the "being eaten" timer if applicable. Returns true if this
## creature was consumed this frame (caller should stop further processing).
func _tick_eating(delta: float) -> bool:
	if not being_eaten_by:
		return false
	eating_timer -= delta
	if eating_timer <= 0:
		being_eaten_by.eat(mass, this_creature_type)
		Effects.spawn_explosion(global_position)
		queue_free()
		return true
	return false


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
