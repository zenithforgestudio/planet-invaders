extends Area2D

class_name EggSpawner

var can_spawn_alien: bool = true
var root

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	root = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_animation(animation: String):
	animated_sprite_2d.play(animation)


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

	


func _on_button_pressed() -> void:
	root.spawn_alien_pink(self.global_position)
	audio_stream_player_2d.pitch_scale = randf_range(0.95, 1.05)
	audio_stream_player_2d.play()
	#if can_spawn_alien == true:
		#animated_sprite_2d.play("Push")
		#can_spawn_alien = false
		#root.spawn_alien_pink(self.global_position)
		#audio_stream_player_2d.pitch_scale = randf_range(0.95, 1.05)
		#audio_stream_player_2d.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	can_spawn_alien = true
