extends StaticBody2D

class_name QuestTile

var alien_request_array: Array = [0, 0, 0, 0, 0, 0, 0, 0]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	set_alien_array()
	print("Checking quest tile data...")
	print("current max level:" + str(Global.max_level))
	print("request array: " + str(alien_request_array))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func set_alien_array():
	for i in range(1, Global.max_level + 1):
		alien_request_array[i] = randi_range(1, 3)

func update_array(alien_level: int, alien: Node2D):
	print("input data: " + str(alien_level) + str(alien))
	if alien_request_array[alien_level] > 0:
		alien_request_array[alien_level] -= 1
		alien.clear_current_tile()
		await get_tree().process_frame
		alien.queue_free()
		print("updated request array: " + str(alien_request_array))
	else:
		alien._return_to_previous_or_initial()
		print("invalid alien")
		return
	for i in range(1, alien_request_array.size()):
		print(alien_request_array[i])
		if(alien_request_array[i] != 0):
			return
			
	print("REQUEST COMPLETED!!") 
	
