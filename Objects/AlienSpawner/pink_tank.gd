extends Area2D

class_name PinkTank

@onready var aline_spawn_cooldown: Timer = $AlineSpawnCooldown
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var spawn_alien_pos: Marker2D = $SpawnAlienPos
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var root
var can_spawn_alien: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animated_sprite_2d.play("Idle")
	await get_tree().process_frame
	root = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func set_progress_bar_value(mana_value):
	if mana_value >= texture_progress_bar.min_value and mana_value <= texture_progress_bar.max_value:
		texture_progress_bar.value = mana_value



func _on_button_pressed() -> void:
	if can_spawn_alien == true:
		can_spawn_alien = false
		aline_spawn_cooldown.start()
		root.spawn_alien_pink(self.global_position)
		audio_stream_player_2d.pitch_scale = randf_range(0.95, 1.05)
		audio_stream_player_2d.play()
		
		
func play_animation(animation: String):
	animated_sprite_2d.play(animation)
	texture_progress_bar.position.y += 4
	await get_tree().create_timer(0.2).timeout
	texture_progress_bar.position.y -= 4
	
func shake_left_right(duration := 0.3, strength := 8.0, shakes := 4) -> void:
	var tween := create_tween()
	var original_pos = self.position

	for i in range(shakes):
		var offset: Vector2
		if i % 2 == 0:
			offset = Vector2.RIGHT * strength
		else:
			offset = Vector2.LEFT * strength

		tween.tween_property(self, "position", original_pos + offset, duration / (shakes * 2))
		tween.tween_property(self, "position", original_pos, duration / (shakes * 2))

	


func _on_aline_spawn_cooldown_timeout() -> void:
	can_spawn_alien = true
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	can_spawn_alien == true


#func _on_mouse_entered() -> void:
	#self.scale = Vector2(1.1, 1.1)
#
#
#func _on_mouse_exited() -> void:
	#self.scale = Vector2(1, 1)
