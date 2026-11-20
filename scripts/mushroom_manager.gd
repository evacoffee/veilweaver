extends Node

const SAVE_PATH = "user://mushroom_save.cfg"

var inventory: Dictionary = {}
var collected_mushrooms: Array = []
var forest_seed: int = 0

func _ready() -> void:
	load_data()

func new_game() -> void:
	inventory.clear()
	collected_mushrooms.clear()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	forest_seed = rng.seed
	
	save_data()

func collect_mushroom(mushroom_id: String, mushroom_type: String) -> void:
	if collected_mushrooms.has(mushroom_id):
		return
	
	collected_mushrooms.append(mushroom_id)
	
	inventory[mushroom_type] = int(inventory.get(mushroom_type, 0)) + 1
	
	save_data()

func is_collected(mushroom_id: String) -> bool:
	return collected_mushrooms.has(mushroom_id)

func save_data() -> void:
	var config = ConfigFile.new()
	
	config.set_value("inventory", "items", inventory)
	config.set_value("inventory", "collected", collected_mushrooms)
	config.set_value("world", "forest_seed", forest_seed)
	
	config.save(SAVE_PATH)

func load_data() -> void:
	var config = ConfigFile.new()
	
	if config.load(SAVE_PATH) != OK:
		return
	
	inventory = config.get_value("inventory", "items", {})
	collected_mushrooms = config.get_value("inventory", "collected", [])
	forest_seed = config.get_value("world", "forest_seed", 0)
