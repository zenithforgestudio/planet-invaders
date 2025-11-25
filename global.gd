extends Node

const SAVE_LOCATION = "user://SaveFile3.json"
const SAVE_PASS = "69420AAA69420"

# Local runtime vars
var is_dragging: bool = false
var max_level: int = 3
var current_mana_value: int = 0
var current_evolution_mana_value: int = 0
var horizontal_tile_count: int = 3
var vertical_tile_count: int = 3
var max_mana_value: int = 1000
var texture_progress_max_value
var london_time: String = ""
var http_node_london_time: HTTPRequest
var mutagen: int
var current_alien_request_array: Array = [0, 0, 0, 0, 0, 0, 0, 0]
var current_attacking_alien_array: Array = [0, 0, 0, 0, 0, 0, 0, 0] 
var quest_reward_count: int = 5
var attack_supply: int = 0
var max_attack_supply: int = 8

# Saved Data
enum { ALIEN_TYPE_COUNT = 9 }
var constent_to_save: Dictionary = {
	"mutagen_count": 5,
	"max_level": 3,
	"current_mana_value": 1000,
	"current_mana_evolution_level": 0,
	"horizontal_tile_count": 3,
	"vertical_tile_count": 3,
	"max_mana_value": 1000,
	"tile_aliens_frequency": [],
	"combat_aliens_frequency": [],
	"quest_aliens_frequency": [],
	"quest_reward_count": 3,
	"last_exit_time": "",
	"last_exit_unix_time": 0,
	"london_time": "",
	"texture_progress_max_value": 1000,
	"attack_supply": 0,
	"max_attack_supply": 8
}

func _ready() -> void:
	_init_arrays_if_needed()
	_load()

	http_node_london_time = HTTPRequest.new()
	add_child(http_node_london_time)
	http_node_london_time.request_completed.connect(_on_request_completed_london_time)

	var error = http_node_london_time.request("https://timeapi.io/api/time/current/zone?timeZone=Europe/London")
	if error != OK:
		print("[ERROR] Failed to send HTTP request for London time. Error code:", error)

	var timer = Timer.new()
	timer.name = "LondonTimeUpdateTimer"
	timer.wait_time = 60.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_update_london_time)
	add_child(timer)

func _update_london_time():
	if http_node_london_time == null:
		print("[WARN] HTTP node not found.")
		return

	if http_node_london_time.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_node_london_time.request("https://timeapi.io/api/time/current/zone?timeZone=Europe/London")
	else:
		print("[WARN] HTTP request is already in progress.")

func _on_request_completed_london_time(result, response_code, headers, body):
	if result != OK or response_code != 200:
		print("[ERROR] Failed to fetch London time. Result:", result, "Response Code:", response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY or not json.has("year"):
		print("[ERROR] Invalid response received from TimeAPI.io")
		return

	var new_time_str = "%04d-%02d-%02dT%02d:%02d:%02d" % [
		int(json["year"]),
		int(json["month"]),
		int(json["day"]),
		int(json["hour"]),
		int(json["minute"]),
		int(json["seconds"])
	]

	print("[INFO] Fetched London time:", new_time_str)

	if constent_to_save.has("london_time") and constent_to_save["london_time"] != "":
		var old_time_str = constent_to_save["london_time"]
		var time_diff = _get_time_difference_in_seconds(old_time_str, new_time_str)
		print("[INFO] London time difference:", time_diff, "seconds")
		var mana_gained = add_mana_offline(time_diff)
		print("[INFO] Mana gained while away:", mana_gained)
		current_mana_value = min(max_mana_value, current_mana_value + mana_gained)
	else:
		print("[INFO] No previous London time saved.")

	constent_to_save["london_time"] = new_time_str
	london_time = new_time_str
	_save()

func _get_time_difference_in_seconds(old_time_str: String, new_time_str: String) -> int:
	var old_unix = _iso_to_unix(old_time_str)
	var new_unix = _iso_to_unix(new_time_str)
	return max(0, new_unix - old_unix)

func _iso_to_unix(datetime_str: String) -> int:
	var parts = datetime_str.split("T")
	if parts.size() != 2:
		print("Invalid datetime format:", datetime_str)
		return 0

	var date_parts = parts[0].split("-")
	var time_parts = parts[1].split(":")

	if date_parts.size() != 3 or time_parts.size() < 3:
		print("Invalid date or time parts in:", datetime_str)
		return 0

	var second_str = time_parts[2].split(".")[0].split("+")[0]

	var dt = {
		"year": int(date_parts[0]),
		"month": int(date_parts[1]),
		"day": int(date_parts[2]),
		"hour": int(time_parts[0]),
		"minute": int(time_parts[1]),
		"second": int(second_str)
	}

	return Time.get_unix_time_from_datetime_dict(dt)

func _init_arrays_if_needed():
	for key in ["tile_aliens_frequency", "combat_aliens_frequency", "quest_aliens_frequency"]:
		if constent_to_save[key].size() != 8:
			constent_to_save[key] = []
			for i in range(ALIEN_TYPE_COUNT):
				constent_to_save[key].append(0)

func _save():
	print("[SAVE] Saving game data.")

	constent_to_save["last_exit_time"] = Time.get_datetime_string_from_system(true, true)
	constent_to_save["last_exit_unix_time"] = Time.get_unix_time_from_system()
	constent_to_save["max_mana_value"] = max(current_mana_value, constent_to_save["max_mana_value"])
	constent_to_save["texture_progress_max_value"] = texture_progress_max_value
	constent_to_save["mutagen_count"] = mutagen
	constent_to_save["max_level"] = max_level
	constent_to_save["current_mana_value"] = current_mana_value
	constent_to_save["current_mana_evolution_level"] = current_evolution_mana_value
	constent_to_save["horizontal_tile_count"] = horizontal_tile_count
	constent_to_save["vertical_tile_count"] = vertical_tile_count
	constent_to_save["quest_aliens_frequency"] = current_alien_request_array
	constent_to_save["quest_reward_count"] = quest_reward_count
	constent_to_save["combat_aliens_frequency"] = current_attacking_alien_array
	constent_to_save["attack_supply"] = attack_supply
	constent_to_save["max_attack_supply"] = max_attack_supply
	

	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, SAVE_PASS)
	file.store_var(constent_to_save)
	file.close()

func _load():
	if not FileAccess.file_exists(SAVE_LOCATION):
		print("[LOAD] No save found, keeping defaults.")
		return

	print("[LOAD] Loading game data.")
	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, SAVE_PASS)
	var save_data: Dictionary = file.get_var()
	file.close()

	_init_arrays_if_needed()
	for key in constent_to_save.keys():
		if save_data.has(key):
			constent_to_save[key] = save_data[key]

	max_level = constent_to_save["max_level"]
	current_mana_value = constent_to_save["current_mana_value"]
	current_evolution_mana_value = constent_to_save["current_mana_evolution_level"]
	horizontal_tile_count = constent_to_save["horizontal_tile_count"]
	vertical_tile_count = constent_to_save["vertical_tile_count"]
	max_mana_value = constent_to_save["max_mana_value"]
	texture_progress_max_value = constent_to_save["texture_progress_max_value"]
	london_time = constent_to_save.get("london_time", "")
	mutagen = constent_to_save["mutagen_count"]
	current_alien_request_array = constent_to_save["quest_aliens_frequency"].duplicate()
	quest_reward_count = constent_to_save["quest_reward_count"]
	current_attacking_alien_array = constent_to_save["combat_aliens_frequency"].duplicate()
	max_attack_supply = constent_to_save["max_attack_supply"] 
	attack_supply = constent_to_save["attack_supply"]
	
	

	print("[LOAD] Last local exit time:", constent_to_save["last_exit_time"])

	var now = Time.get_unix_time_from_system()
	var last_exit_unix = constent_to_save.get("last_exit_unix_time", now)
	if last_exit_unix > 0:
		var time_away = now - last_exit_unix
		print("[FALLBACK] Local system time away:", time_away, "seconds")
		print("[FALLBACK] Mana from local time:", add_mana_offline(time_away))
		current_mana_value = min(max_mana_value, current_mana_value + add_mana_offline(time_away))
	else:
		print("[INFO] First run or missing local timestamp — no previous session found.")

func add_mana_offline(time_away: int) -> int:
	var mana: float = 0.0
	var alien_freq = constent_to_save["tile_aliens_frequency"]
	for i in range(1, alien_freq.size()):
		var aliens = alien_freq[i]
		var mana_per_60s = int(pow(i, 1.4))
		var ticks = time_away / 60.0
		mana += aliens * mana_per_60s * ticks
	mana += 2 * (time_away / 60.0)
	return int(mana)
