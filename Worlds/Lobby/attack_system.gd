extends Node2D

@onready var tile_2: Tile = $Tile2
@onready var supply_label: Label = $SupplyLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	tile_2.add_to_group("AttackTile")
	supply_label.text = str(str(Global.attack_supply) + " / " + str(Global.max_attack_supply))
	#print("Current Attack Supply:" + str(Global.attack_supply))
	#print("Attack Supply:" + str(Global.attack_supply))
	#print("Max Supply:" + str(Global.max_attack_supply))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_array(alien_level: int, alien: Node2D):
	if (alien.get_supply_level() + Global.attack_supply) <= Global.max_attack_supply:
		#print("Can you add more aliens?" + str(alien.get_supply_level() + Global.attack_supply <= Global.max_attack_supply))
		#print("Attack Supply: " + str(Global.attack_supply))
		#print("Max Attack Supply:" + str(Global.max_attack_supply))
		print("Attack Supply:" + str(Global.attack_supply))
		print("Max Supply:" + str(Global.max_attack_supply))
		alien.clear_current_tile()
		await get_tree().process_frame
		alien.queue_free()
		#print("Alien added to attack")
		#supply_label.text = str(str(Global.attack_supply) + " / " + str(Global.max_attack_supply))
		#print("Alien level: " + str(alien.get_current_evolution_level()))
		#print("Alien Attack Supply: " + str(alien.get_supply_level()))
		Global.attack_supply += alien.get_supply_level()
		#print(Global.attack_supply)
		Global.current_attacking_alien_array[alien_level] += 1
		supply_label.text = str(str(Global.attack_supply) + " / " + str(Global.max_attack_supply))
		
		#print(Global.current_attacking_alien_array)
		Global._save()
	else:
		alien._return_to_previous_or_initial()
		print("Attack Supply Limit Reached")
