extends Node

const SAVE_LOCATION = "user://SaveFile3.json"
const SAVE_PASS = "69420AAA69420"

# Node references

# Local runtime vars
var is_dragging: bool = false

var max_level: int = 3
var current_mana_value: int = 0
var current_evolution_mana_value: int = 0
var horizontal_tile_count: int = 3
var vertical_tile_count: int = 3
var max_mana_value: int = 1000
var texture_progress_max_value

# Saved Data
var constent_to_save: Dictionary = {
	"max_level": 3,
	"current_mana_value": 1000,
	"current_mana_evolution_level": 0,

	"horizontal_tile_count": 3,
	"vertical_tile_count": 3,

	"max_mana_value": 1000,

	"tile_aliens_frequency": [],
	"combat_aliens_frequency": [],
	"quest_aliens_frequency": [],

	"last_exit_time": "",
	"last_exit_unix_time": 0,

	"texture_progress_max_value": 1000
}

func _ready() -> void:
	_init_arrays_if_needed()
	_load()

func _init_arrays_if_needed():
	if constent_to_save["tile_aliens_frequency"].size() != 9:
		constent_to_save["tile_aliens_frequency"] = []
		for i in range(9):
			constent_to_save["tile_aliens_frequency"].append(0)

	if constent_to_save["combat_aliens_frequency"].size() != 9:
		constent_to_save["combat_aliens_frequency"] = []
		for i in range(9):
			constent_to_save["combat_aliens_frequency"].append(0)

	if constent_to_save["quest_aliens_frequency"].size() != 9:
		constent_to_save["quest_aliens_frequency"] = []
		for i in range(9):
			constent_to_save["quest_aliens_frequency"].append(0)

func _save() -> void:
	print("saving data!")

	constent_to_save["last_exit_time"] = Time.get_datetime_string_from_system(true, true)
	constent_to_save["last_exit_unix_time"] = Time.get_unix_time_from_system()

	constent_to_save["max_mana_value"] = max(current_mana_value, constent_to_save["max_mana_value"])
	constent_to_save["texture_progress_max_value"] = texture_progress_max_value

	constent_to_save["max_level"] = max_level
	constent_to_save["current_mana_value"] = current_mana_value
	constent_to_save["current_mana_evolution_level"] = current_evolution_mana_value
	constent_to_save["horizontal_tile_count"] = horizontal_tile_count
	constent_to_save["vertical_tile_count"] = vertical_tile_count

	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, SAVE_PASS)
	file.store_var(constent_to_save)
	file.close()

func _reset() -> void:
	print("resetting data!")

	max_level = 3
	current_mana_value = 1000
	current_evolution_mana_value = 0
	horizontal_tile_count = 3
	vertical_tile_count = 3
	max_mana_value = 1000

	texture_progress_max_value = pow(2, Global.max_level - 1) * 40

	constent_to_save["max_level"] = 3
	constent_to_save["current_mana_value"] = 1000
	constent_to_save["current_mana_evolution_level"] = 0
	constent_to_save["horizontal_tile_count"] = 3
	constent_to_save["vertical_tile_count"] = 3
	constent_to_save["max_mana_value"] = 1000
	constent_to_save["last_exit_time"] = ""
	constent_to_save["last_exit_unix_time"] = 0
	constent_to_save["texture_progress_max_value"] = 1000

	constent_to_save["tile_aliens_frequency"] = []
	constent_to_save["combat_aliens_frequency"] = []
	constent_to_save["quest_aliens_frequency"] = []
	for i in range(9):
		constent_to_save["tile_aliens_frequency"].append(0)
		constent_to_save["combat_aliens_frequency"].append(0)
		constent_to_save["quest_aliens_frequency"].append(0)

	_save()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_LOCATION):
		print("No save found, keeping defaults.")
		return

	print("loading data!")
	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, SAVE_PASS)
	var save_data: Dictionary = file.get_var()
	file.close()

	# Initialize arrays first — BEFORE data assignment
	_init_arrays_if_needed()

	# Now safely copy saved values
	for key in constent_to_save.keys():
		if save_data.has(key):
			constent_to_save[key] = save_data[key]

	max_level = constent_to_save["max_level"]
	current_mana_value = constent_to_save["current_mana_value"]
	current_evolution_mana_value = constent_to_save["current_mana_evolution_level"]
	horizontal_tile_count = constent_to_save["horizontal_tile_count"]
	vertical_tile_count = constent_to_save["vertical_tile_count"]
	max_mana_value = constent_to_save["max_mana_value"]

	# Load saved texture progress max
	texture_progress_max_value = constent_to_save["texture_progress_max_value"]

	print("Last exit:", constent_to_save["last_exit_time"])

	var now = Time.get_unix_time_from_system()
	var last_exit_unix = constent_to_save.get("last_exit_unix_time", now)

	if last_exit_unix > 0:
		var time_away = now - last_exit_unix
		print("Time away: " + str(round(time_away)) + " seconds")
	else:
		print("First run or missing timestamp — no previous session found.")
