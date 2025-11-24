extends Control



@onready var animated_sprite_2d0: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton/AnimatedSprite2D
@onready var animated_sprite_2d1: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton2/AnimatedSprite2D
@onready var animated_sprite_2d2: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton3/AnimatedSprite2D
@onready var animated_sprite_2d3: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton4/AnimatedSprite2D
@onready var animated_sprite_2d4: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton5/AnimatedSprite2D
@onready var animated_sprite_2d5: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton6/AnimatedSprite2D
@onready var animated_sprite_2d6: AnimatedSprite2D = $ScrollContainer/HBoxContainer/VBoxContainer/TextureButton7/AnimatedSprite2D

var is_on_screen: bool = false

var pink_alien_texture_arrays: Array = [] 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	position.x = 450
	pink_alien_texture_arrays = [animated_sprite_2d0, animated_sprite_2d1, animated_sprite_2d2, animated_sprite_2d3, animated_sprite_2d4, animated_sprite_2d5, animated_sprite_2d6]
	for i in range(Global.max_level):
		pink_alien_texture_arrays[i].material = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_eneter_leave_screen_button_pressed() -> void:
	move_with_tween(is_on_screen)
	is_on_screen = !is_on_screen


func move_with_tween(is_viewable: bool):
	var tween = get_tree().create_tween()
	var target_x: float

	if is_viewable:
		target_x = 450
	else:
		target_x = 220

	tween.tween_property(self, "position:x", target_x, 0.5) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)


func _on_texture_button_pressed() -> void:
	#print("menu button pressed!")
	Global.mutagen += 1
	print(Global.mutagen)
	
func update_hidden_textures():
	for i in range(Global.max_level):
		pink_alien_texture_arrays[i].material = null
