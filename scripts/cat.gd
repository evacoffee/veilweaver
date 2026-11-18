extends CharacterBody2D

const SPEED = 180.0
const FOLLOW_DISTANCE = 85.0
const STOP_DISTANCE = 12.0

const TELEPORT_DISTANCE = 1000.0
const TELEPORT_OFFSET = 35.0
const TELEPORT_ATTEMPTS = 20
const POOF_DELAY = 0.6

@onready var sprite = $AnimatedSprite2D
@onready var poof = $poof
@onready var collision_shape = $CollisionShape2D

var player: CharacterBody2D

var facing = "_back"
var follow_offset = Vector2(0, FOLLOW_DISTANCE)

var teleport_destination = Vector2.ZERO
var teleport_phase = 0
var teleport_timer = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		add_collision_exception_with(player)
		
	poof.emitting = false
	poof.local_coords = false

func _physics_process(delta):
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if teleport_phase != 0:
		update_teleport(delta)
		return
		
	var player_direction = player.velocity.normalized()
	
	if player_direction != Vector2.ZERO:
		
		if absf(player_direction.x) > absf(player_direction.y):
			
			facing = "_side"
			
			if player_direction.x > 0:
				follow_offset = Vector2(-FOLLOW_DISTANCE, 0)
				sprite.flip_h = true
			else:
				follow_offset = Vector2(FOLLOW_DISTANCE, 0)
				sprite.flip_h = false
				
		elif player_direction.y < 0:
			
			facing = "_back"
			follow_offset = Vector2(0, FOLLOW_DISTANCE)
			sprite.flip_h = false
			
		else:
			facing = "_front"
			follow_offset = Vector2(0, -FOLLOW_DISTANCE)
			sprite.flip_h = false
			
	var target_position = player.global_position + follow_offset
	var distance = global_position.distance_to(target_position)
	
	var viewport_rect = get_viewport().get_visible_rect()
	var cat_screen_position = get_viewport().get_canvas_transform() * global_position
	
	if not viewport_rect.has_point(cat_screen_position):
		if try_teleport():
			return
			
	if distance > STOP_DISTANCE:
		var direction = global_position.direction_to(target_position)
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	
	update_animation(distance)

func update_animation(distance):
	var animation_name: String
	
	if distance > STOP_DISTANCE:
		animation_name = "run" + facing
	else:
		animation_name = "idle_sit"
		
	if sprite.animation != animation_name:
		sprite.play(animation_name)

func is_position_clear(check_position: Vector2) -> bool:
	var shape = collision_shape.shape
	
	if shape == null:
		return false
		
	var query = PhysicsShapeQueryParameters2D.new()
	
	query.shape = shape
	
	var shape_transform = collision_shape.global_transform
	shape_transform.origin = check_position + (collision_shape.global_position - global_position)
	
	query.transform = shape_transform
	query.collision_mask = collision_mask
	query.exclude = [get_rid(), player.get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false
	
	var results = get_world_2d().direct_space_state.intersect_shape(query, 1)
	
	return results.is_empty()

func try_teleport() -> bool:
	
	for i in range(TELEPORT_ATTEMPTS):
		
		var offset = follow_offset + Vector2(randf_range(-TELEPORT_OFFSET, TELEPORT_OFFSET), randf_range(-TELEPORT_OFFSET, TELEPORT_OFFSET))
		
		var destination = player.global_position + offset
		
		if is_position_clear(destination):
			teleport_destination = destination
			teleport_phase = 1
			teleport_timer = POOF_DELAY
			
			velocity = Vector2.ZERO
			
			poof.global_position = global_position
			poof.emitting = false
			poof.restart()
			poof.emitting = true
			
			sprite.visible = false
			collision_shape.set_deferred("disabled", true)
			
			return true
			
	return false

func update_teleport(delta):
	teleport_timer -= delta
	
	if teleport_timer > 0:
		return
		
	if teleport_phase == 1:
		global_position = teleport_destination
		
		collision_shape.set_deferred("disabled", false)
		
		poof.global_position = global_position
		poof.emitting = false
		poof.restart()
		poof.emitting = true
		sprite.visible = true
		teleport_phase = 2
		teleport_timer = POOF_DELAY
		
	elif teleport_phase == 2:
		teleport_phase = 0
