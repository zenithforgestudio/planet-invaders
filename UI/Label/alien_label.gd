extends Label

class_name AlienLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var pool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	pool = get_tree().get_first_node_in_group("Spawner")
	pivot_offset = self.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_number(new_number: int):
	animation_player.play("ShowDamage")
	text = str(new_number)
	#modulate = "460e2b"
	
func show_text(new_text: String):
	text = str(new_text)
	pivot_offset = size/2
	animation_player.play("ShowDamage")
	
#func show_fire_damage(damage: int):
	#animation_player.play("ShowDamage")
	#text = str(damage)
	#modulate = "ff8274"
	#await animation_player.animation_finished
	#return_to_pool()
	
#func return_to_pool():
	#pool.add_label_to_pool(self)
	
