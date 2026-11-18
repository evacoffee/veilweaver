extends Node2D

@export_group("Enemies")
@export var enemy_scenes: Array[PackedScene] = []

@export_group("Random Encounters")
@export_range(0.0, 1.0) var encounter_chance: float = 0.08
@export var steps_between_checks: int = 8

@onready var ground: TileMapLayer = $forest

var grass_cells: Array[Vector2i] = []

var player: Node2D
var steps_since_check: int = 0
var encounter_active: bool = false

func _ready():
	randomize()
	player = get_tree().get_first_node_in_group("player")
	find_grass_tiles()

func find_grass_tiles():
	grass_cells.clear()
	
	for cell in ground.get_used_cells():
		var tile_data = ground.get_cell_tile_data(cell)
		
		if tile_data == null:
			continue
			
		if bool(tile_data.get_custom_data("spawnable")):
			grass_cells.append(cell)
			
	print("spawnable grass tiles found: ", grass_cells.size())

func get_random_enemy() -> PackedScene:
	if enemy_scenes.is_empty():
		push_warning("No enemy scenes assigned!")
		return null
		
	return enemy_scenes.pick_random()

func check_for_encounter():
	if encounter_active:
		return
		
	if enemy_scenes.is_empty():
		return
		
	if randf() < encounter_chance:
		encounter_active = true
		
		var selected_enemy = get_random_enemy()
		
		if selected_enemy != null:
			print("Random encounter!")
			start_encounter(selected_enemy)

func start_encounter(enemy_scene: PackedScene):
	print("Encounter enemy: ", enemy_scene.resource_path)

func finish_encounter():
	encounter_active = false
	steps_since_check = 0
