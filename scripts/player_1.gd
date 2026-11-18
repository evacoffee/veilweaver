extends CharacterBody2D

const SPEED = 250.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.18
const DASH_COOLDOWN = 0.6

const ENCOUNTER_CHECK_DISTANCE = 80.0

@onready var sprite = $AnimatedSprite2D

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var dash_direction = Vector2.ZERO

var facing = "_front"

var distance_walked = 0.0

func _ready() -> void:
	var cat = get_tree().get_first_node_in_group("cat")
	
	if cat:
		add_collision_exception_with(cat)

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	
	if Input.is_action_just_pressed("dash"):
		if not is_dashing and dash_cooldown <= 0.0:
			if direction != Vector2.ZERO:
				is_dashing = true
				dash_timer = DASH_DURATION
				dash_cooldown = DASH_COOLDOWN
				dash_direction = direction
				
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity = direction * SPEED
		
	var previous_position = global_position
	
	move_and_slide()
	
	if direction != Vector2.ZERO and not is_dashing:
		var distance_moved = global_position.distance_to(previous_position)
		distance_walked += distance_moved
		
		if distance_walked >= ENCOUNTER_CHECK_DISTANCE:
			distance_walked = 0.0
			check_forest_encounter()
			
	update_animation(direction)

func check_forest_encounter():
	var forest = get_tree().get_first_node_in_group("forest_level")
	
	if forest and forest.has_method("check_for_encounter"):
		forest.check_for_encounter()

func update_animation(direction):
	if direction.x < 0:
		facing = "_side"
		sprite.flip_h = true
	elif direction.x > 0:
		facing = "_side"
		sprite.flip_h = false
	elif direction.y < 0:
		facing = "_back"
	elif direction.y > 0:
		facing = "_front"
		
	var animation_name = ""
	
	if is_dashing:
		animation_name = "dash"
	elif direction != Vector2.ZERO:
		animation_name = "run"
	else:
		animation_name = "idle"
		
	sprite.play(animation_name + facing)
