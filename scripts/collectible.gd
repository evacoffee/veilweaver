extends Area2D

var mushroom_id: String = ""
var mushroom_type: String = "common"
var already_collected: bool = false

@onready var pickup_sound: AudioStreamPlayer2D = $collectsound

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if already_collected:
		return
	
	if not body.is_in_group("player"):
		return
		
	already_collected = true
	
	MushroomManager.collected_mushroom(mushroom_id, mushroom_type)
	
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	
	if pickup_sound.stream:
		pickup_sound.finished.connect(queue_free)
		pickup_sound.play()
	else:
		queue_free()

func set_mushroom_variant(variant_index: int) -> void:
	var column = variant_index & 8
	var row = variant_index / 8
	
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(column * 16, row * 16, 16, 16)
	
	mushroom_type = "mushroom_%02d" % variant_index
