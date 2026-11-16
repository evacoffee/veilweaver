extends CharacterBody2D

const SPEED = 250.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.18
const DASH_COOLDOWN = 0.6

@onready var sprite = $AnimatedSprite2D

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var dash_direction = Vector2.ZERO

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
		
	move_and_slide()
	
	update_animation(direction)

func update_animation(direction):
	if is_dashing:
		sprite.play("dash")
		
	elif direction != Vector2.ZERO:
		sprite.play("run")
		
	else:
		sprite.play("idle")
		
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
