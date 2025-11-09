extends Area2D

class_name AlienGrinder

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	#texture_progress_bar.max_value = pow(2, Global.max_level - 1) * 40
	set_texture_bar_max_value(Global.texture_progress_max_value)
	#print(Global.texture_progress_max_value)


func set_texture_bar_max_value(new_max_value) -> void:
	texture_progress_bar.max_value = new_max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func increase_pool_value(extra_value: int):
	play_splat_sound()
	texture_progress_bar.value = min(texture_progress_bar.max_value, texture_progress_bar.value + extra_value)
	Global.current_evolution_mana_value = texture_progress_bar.value  # <-- ADD THIS

	if Global.max_level < 7 and texture_progress_bar.value == texture_progress_bar.max_value:
		Global.max_level += 1
		texture_progress_bar.value = texture_progress_bar.min_value
		Global.current_evolution_mana_value = texture_progress_bar.value  # <-- KEEP STATE CORRECT
		texture_progress_bar.max_value = pow(2, Global.max_level - 1) * 40
		print("alien level increased")
		
	get_parent().save_data()

		
func set_pool_value(new_value):
	var tween = get_tree().create_tween()
	tween.tween_property(texture_progress_bar, "value", new_value, 0.35).set_ease(Tween.EASE_OUT)
	Global.current_evolution_mana_value = new_value


	
func get_current_evolution_mana() -> float:
	return texture_progress_bar.value

func play_splat_sound():
	audio_stream_player_2d.pitch_scale = randf_range(0.95, 1.05)
	audio_stream_player_2d.play()
