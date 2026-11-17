extends CharacterBody2D

const SPEED = 150.0
const FOLLOW_DISTANCE = 50.0

const TELEPORT_DISTANCE = 1000.0
const TELEPORT_OFFSET = 65.0

@onready var sprite = $AnimatedSprite2D

var player: CharacterBody2D
var facing = "_front"
var follow_offset = Vector2(0, 75)

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)

func _physics_process(_delta):
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var player_direction = player.velocity.normalized()
	
	if player_direction != Vector2.ZERO:
		if absf(player_direction.x) > absf(player_direction.y):
			if player_direction.x > 0:
				follow_offset = Vector2(-FOLLOW_DISTANCE, 0)
				facing = "_side"
				sprite.flip_h = true
			else:
				follow_offset = Vector2(FOLLOW_DISTANCE, 0)
				facing = "_side"
				sprite.flip_h = false
		elif player_direction.y < 0:
			follow_offset = Vector2(0, FOLLOW_DISTANCE)
			facing = "_back"
			sprite.flip_h = false
		else:
			follow_offset = Vector2(0, -FOLLOW_DISTANCE)
			facing = "_front"
			sprite.flip_h = false
			
	var target_position = player.global_position + follow_offset
	var distance = global_position.distance_to(target_position)
	
	if distance > 12.0:
		var direction = global_position.direction_to(target_position)
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	check_teleport()
	update_animation(distance)

func update_animation(distance):
	if distance > 12.0:
		sprite.play("run" + facing)
	else:
		sprite.play("idle_sit")

#-------------
#teleportations
#-------------
func check_teleport():
	var distance = global_position.distance_to(player.global_position)
	
	if distance > TELEPORT_DISTANCE:
		var offset = Vector2(randf_range(-TELEPORT_OFFSET, TELEPORT_OFFSET), randf_range(-TELEPORT_OFFSET, TELEPORT_OFFSET))
		global_position = player.global_position + offset
