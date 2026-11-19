extends Area2D

@export var destination_scene: PackedScene
@export var destination_marker: StringName = &"playerspawn"

@export var camera_right: int = 1824
@export var camera_bottom: int = 1024

var transitioning = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if transitioning:
		return
		
	if not body.is_in_group("player"):
		return
		
	if destination_scene == null:
		push_warning("No destination was assigned!")
		return
		
	transitioning = true
	call_deferred("change_area", body)

func change_area(body):
	if not is_instance_valid(body):
		transitioning = false
		return
		
	var main = get_tree().current_scene
	var level_root = main.get_node_or_null("levelroot")
	
	if level_root == null:
		push_warning("Could not find levelroot!")
		transitioning = false
		return
		
	var new_level = destination_scene.instantiate()
	
	for child in level_root.get_children():
		child.queue_free()
		
	level_root.add_child(new_level)
	
	var spawn_point = new_level.get_node_or_null(NodePath(destination_marker))
	
	if spawn_point:
		body.global_position = spawn_point.global_position
		update_camera_limits()
	else:
		push_warning("Spawn marker not found: " + str(destination_marker))
		
	transitioning = false
	
func update_camera_limits():
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
		
	var camera = player.get_node_or_null("Camera2D")
	
	if camera == null:
		return
		
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = camera_right
	camera.limit_bottom = camera_bottom
