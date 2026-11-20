extends Node2D

@export_group("Enemies")
@export var enemy_scenes: Array[PackedScene] = []

@export_group("Random Encounters")
@export_range(0.0, 1.0) var encounter_chance: float = 0.08
@export var steps_between_checks: int = 8

@export_group("Mushrooms")
@export var mushroom_scene: PackedScene
@export var mushroom_count: int = 15

@onready var ground: TileMapLayer = $forest

var grass_cells: Array[Vector2i] = []

var player: Node2D
var steps_since_check: int = 0
var encounter_active: bool = false

func _ready():
	randomize()
	player = get_tree().get_first_node_in_group("player")
	find_grass_tiles()
	spawn_mushrooms()

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

#-------------------
#mushrooms
#--------------------
func spawn_mushrooms() -> void:
	if mushroom_scene == null:
		push_warning('NOTHING MUSH SCENE IS ASSIGNEDDDD')
		return
	
	var rng = RandomNumberGenerator.new()
	rng.seed = MushroomManager.forest_seed + hash("forest")
	
	var available_cells = grass_cells.duplicate()
	
	var amount = mini(mushroom_count, available_cells.size())
	
	for i in range(amount):
		var index = rng.randi_range(0, available_cells.size() - 1)
		var cell = available_cells[index]
		available_cells.remove_at(index)
		
		var mushroom_id = "forest_%d_%d" % [cell.x, cell.y]
		
		if MushroomManager.is_collected(mushroom_id):
			continue
			
		var mushroom = mushroom_scene.instantiate()
		
		$objects.add_child(mushroom)
		
		mushroom.global_position = ground.to_global(ground.map_to_local(cell))
		mushroom.mushroom_id = mushroom_id
		mushroom.mushroom_type = "common"
		
		var variant_index = rng.randi_range(0, 35)
		mushroom.set_mushroom_variant(variant_index)
