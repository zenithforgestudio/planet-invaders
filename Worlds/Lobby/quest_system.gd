extends Node2D

@onready var tile_2: Tile = $Tile2

@onready var reqeust_count_1: Label = $ReqeustCount1
@onready var request_count_2: Label = $RequestCount2
@onready var request_count_3: Label = $RequestCount3

@onready var alien_request_1: AnimatedSprite2D = $AlienRequest1
@onready var alien_request_2: AnimatedSprite2D = $AlienRequest2
@onready var alien_request_3: AnimatedSprite2D = $AlienRequest3

var alien_request_array: Array = [0, 0, 0, 0, 0, 0, 0, 0]
var labels: Array = []
var alien_sprites: Array = []
var quest_reward: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	labels = [reqeust_count_1, request_count_2, request_count_3]
	alien_sprites = [alien_request_1, alien_request_2, alien_request_3]
	set_alien_array()
	tile_2.add_to_group("QuestTile")
	print("Checking quest tile data...")
	print("current max level:" + str(Global.max_level))
	print("request array: " + str(alien_request_array))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_alien_array():
	var j = 0
	var ongoing_quest: bool = false
	while j < Global.max_level and not ongoing_quest:
		if Global.current_alien_request_array[j] > 0 and ongoing_quest == false:
			ongoing_quest = true
		j += 1
			
	if ongoing_quest == false:
		Global.quest_reward_count = 0 
		for i in range(1, Global.max_level + 1):
			var alien_count = randi_range(1, 3)
			alien_request_array[i] = alien_count
			labels[i - 1].text = str("X"+str(alien_count))
			Global.quest_reward_count += i * alien_request_array[i]
			Global._save()
			
	else:
		for i in range(1, Global.max_level + 1):
			alien_request_array[i] = Global.current_alien_request_array[i]
			labels[i - 1].text = str("X"+str(alien_request_array[i]))
			
			
	#for i in range(1, Global.max_level + 1):
		#var alien_count = randi_range(1, 3)
		#alien_request_array[i] = alien_count
		#labels[i - 1].text = str("X"+str(alien_count))
	
	alien_sprites[0].play("Evo1")
	alien_sprites[1].play("Evo2")
	alien_sprites[2].play("Evo3")
		
		
		
func update_array(alien_level: int, alien: Node2D):
	print("input data: " + str(alien_level) + str(alien))
	if alien_request_array[alien_level] > 0:
		alien_request_array[alien_level] -= 1
		labels[alien_level - 1].text = str("X" + str(alien_request_array[alien_level]))
		alien.clear_current_tile()
		await get_tree().process_frame
		alien.queue_free()
		print("updated request array: " + str(alien_request_array))
		Global.current_alien_request_array = alien_request_array.duplicate()
		Global._save()
	else:
		alien._return_to_previous_or_initial()
		print("invalid alien")
		return
	for i in range(1, alien_request_array.size()):
		print(alien_request_array[i])
		if(alien_request_array[i] != 0):
			return
			
	print("REQUEST COMPLETED!!") 
	Global.mutagen += Global.quest_reward_count
	get_parent().update_mutagen_label(Global.mutagen)
	

	
