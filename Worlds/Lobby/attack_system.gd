extends Node2D

@onready var tile_2: Tile = $Tile2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	tile_2.add_to_group("AttackTile")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
