extends Control

const MAIN_SCENE = "res://scenes/main.tscn"

@onready var title: Label = $title

var title_start_position: Vector2
var animation_time: float = 0.0

const BOUNCE_HEIGHT = 8.0
const BOUNCE_SPEED = 2.0
const PULSE_AMOUNT = 0.025

func _ready() -> void:
	title_start_position = title.position
	
	$play.pressed.connect(_on_play_pressed)

func _process(delta):
	animation_time += delta
	
	var bounce = abs(sin(animation_time * BOUNCE_SPEED))
	title.position.y = title_start_position.y - bounce * BOUNCE_HEIGHT

func _on_play_pressed():
	get_tree().change_scene_to_file(MAIN_SCENE)
