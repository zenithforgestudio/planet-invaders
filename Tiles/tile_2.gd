extends StaticBody2D

class_name  Tile

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var is_occupied: bool = false
var occupant: Area2D = null


func occupy(entity: Node) -> void:
	occupant = entity
	is_occupied = true
	label.text = "Occupied"

func vacate() -> void:
	occupant = null
	is_occupied = false

func get_occupant() -> Area2D:
	if occupant == null or !is_instance_valid(occupant):
		#print("[DEBUG] Tile occupant is invalid or freed — auto-vacating.")
		vacate()
		return null
	return occupant


func set_color(r,g, b, a):
	sprite_2d.modulate = Color(r,g, b, a)
	
func set_transparency(a):
	sprite_2d.modulate.a = a

func _is_occupied():
	return is_occupied
	
func _process(delta: float) -> void:
	label.text = str(is_occupied)
