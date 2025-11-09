extends Area2D
class_name PinkAlien

signal board_changed

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var alien_label: AlienLabel = $AlienLabel

var draggable: bool = false
var is_inside_dropable: bool = false

var body_ref: Tile = null
var current_tile: Tile = null
var previous_tile: Tile = null
var offset: Vector2
var initial_pos: Vector2
var current_evolution_level: int = 1
var root: Node
var genetic_potential: int = 10

# -------------------------------------------------------------

func _ready() -> void:
	current_evolution_level = 1
	root = get_tree().current_scene

	if not board_changed.is_connected(root._on_board_changed):
		board_changed.connect(root._on_board_changed)



# -------------------------------------------------------------

func _process(delta: float) -> void:
	label.text = str(previous_tile)

# -------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if not draggable:
		return

	# --- Drag movement ---
	if draggable and event is InputEventMouseMotion and Input.is_action_pressed("click"):
		global_position = event.position - offset

	# --- Mouse button handling ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_drag_start()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			await _on_drag_release()

# -------------------------------------------------------------
# --- DRAG LOGIC ---
# -------------------------------------------------------------

func _on_drag_start() -> void:
	print("[DEBUG] Drag start")
	animated_sprite_2d.speed_scale = 1.5
	initial_pos = global_position
	offset = get_global_mouse_position() - global_position
	Global.is_dragging = true
	previous_tile = current_tile

	if current_tile:
		current_tile.vacate()
		current_tile = null

# -------------------------------------------------------------

func _on_drag_release() -> void:
	print("[DEBUG] Drag released")
	Global.is_dragging = false
	animated_sprite_2d.speed_scale = 1

	if not body_ref:
		_return_to_previous_or_initial()
		return

	print("[DEBUG] Dropped on tile: ", body_ref)

	if body_ref.is_occupied:
		_handle_occupied_drop(body_ref)
	else:
		_handle_free_drop(body_ref)

	await get_tree().create_timer(0.25).timeout
	root.debug_alien_positions()
	
	emit_signal("board_changed")

# -------------------------------------------------------------
# --- TILE INTERACTION ---
# -------------------------------------------------------------

func _handle_occupied_drop(target_tile: Tile) -> void:
	var other_alien = target_tile.get_occupant()

	# Defensive cleanup
	if not is_instance_valid(other_alien):
		print("[DEBUG] Ghost occupant detected, vacating tile.")
		target_tile.vacate()
		_handle_free_drop(target_tile)
		return

	# 🧱 Prevent merging with self
	if other_alien == self:
		print("[DEBUG] Same tile drop detected — returning to tile, no merge.")
		target_tile.occupy(self)
		current_tile = target_tile
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", target_tile.position, 0.2).set_ease(Tween.EASE_OUT)
		return

	print("[DEBUG] Tile occupied by: ", other_alien)

	# --- Merge into Grinder ---
	if other_alien.is_in_group("Grinder"):
		print("[DEBUG] Merging into Grinder")
		other_alien.increase_pool_value(genetic_potential)
		root.emit_particles(other_alien.global_position)
		if previous_tile:
			previous_tile.vacate()
		queue_free()
		return
		
	if other_alien.is_in_group("Spawner"):
		print("[DEBUG] Tried merging with spawner, returning to original tile")
		_return_to_previous_or_initial()
		return

	# --- Merge with another PinkAlien ---
	if other_alien.is_in_group("PinkAlien"):
		var other_evo = other_alien.get_current_evolution_level()
		if check_same_creature(other_evo) and get_current_evolution_level() < Global.max_level:
			print("[DEBUG] Merge successful")

			# Clean both tiles before freeing
			if target_tile:
				target_tile.vacate()
			if previous_tile:
				previous_tile.vacate()

			# Free the other alien safely
			other_alien.current_tile = null
			other_alien.queue_free()

			root.emit_particles(target_tile.global_position)

			# Move into new tile
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", target_tile.position, 0.25).set_ease(Tween.EASE_OUT)
			target_tile.occupy(self)
			current_tile = target_tile

			increase_current_evolution()
			return
		else:
			print("[DEBUG] Merge failed – incompatible or max level reached")
			#_return_to_previous_or_initial()
			_swap_positions_with(other_alien, target_tile)
			if get_current_evolution_level() == Global.max_level:
				root.show_alien_label_text("Max Level Reached")
			return

	# --- Invalid merge target ---
	print("[DEBUG] Invalid merge target – swapping back")
	_swap_with_invalid_target(other_alien, target_tile)

# -------------------------------------------------------------

func _handle_free_drop(target_tile: Tile) -> void:
	print("[DEBUG] Dropped on free tile")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_tile.position, 0.25).set_ease(Tween.EASE_OUT)
	target_tile.occupy(self)
	current_tile = target_tile

# -------------------------------------------------------------

func _swap_with_invalid_target(other_alien: PinkAlien, target_tile: Tile) -> void:
	if not previous_tile:
		_return_to_previous_or_initial()
		return

	print("[DEBUG] Swapping aliens")
	var my_old_tile := previous_tile
	var my_old_position := my_old_tile.position

	var other_tween = get_tree().create_tween()
	other_tween.tween_property(other_alien, "global_position", my_old_position, 0.25).set_ease(Tween.EASE_OUT)
	my_old_tile.occupy(other_alien)
	other_alien.current_tile = my_old_tile

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_tile.position, 0.25).set_ease(Tween.EASE_OUT)
	target_tile.occupy(self)
	current_tile = target_tile

# -------------------------------------------------------------

func _swap_positions_with(other_alien: PinkAlien, target_tile: Tile) -> void:
	if previous_tile == null:
		_return_to_previous_or_initial()
		return

	var from_tile := previous_tile
	var to_tile := target_tile

	# Move other alien to the dragged alien's previous tile
	var tween_other = get_tree().create_tween()
	tween_other.tween_property(other_alien, "global_position", from_tile.position, 0.25).set_ease(Tween.EASE_OUT)
	from_tile.occupy(other_alien)
	other_alien.current_tile = from_tile

	# Move dragged alien to the target tile
	var tween_self = get_tree().create_tween()
	tween_self.tween_property(self, "global_position", to_tile.position, 0.25).set_ease(Tween.EASE_OUT)
	to_tile.occupy(self)
	current_tile = to_tile


func _return_to_previous_or_initial() -> void:
	if previous_tile:
		print("[DEBUG] Returning to previous tile")
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", previous_tile.position, 0.25).set_ease(Tween.EASE_OUT)
		previous_tile.occupy(self)
		current_tile = previous_tile
	else:
		print("[DEBUG] No previous tile – returning to initial position")
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", initial_pos, 0.25).set_ease(Tween.EASE_OUT)

# -------------------------------------------------------------
# --- SIGNALS ---
# -------------------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("dropable"):
		is_inside_dropable = true
		body_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("dropable") and body == body_ref:
		is_inside_dropable = false
		body_ref = null

func _on_mouse_entered() -> void:
	if not Global.is_dragging:
		draggable = true
		scale = Vector2(1.2, 1.2)

func _on_mouse_exited() -> void:
	if not Global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)

# -------------------------------------------------------------
# --- HELPERS ---
# -------------------------------------------------------------

func set_current_tile(tile: Tile):
	current_tile = tile

func get_current_evolution_level():
	return current_evolution_level

func check_same_creature(other_evo: int) -> bool:
	return self.current_evolution_level == other_evo

func increase_current_evolution():
	current_evolution_level += 1
	genetic_potential = pow(2, current_evolution_level - 1) * 10
	collision_shape_2d.shape.radius += int(current_evolution_level / 2)
	animated_sprite_2d.play("Evo" + str(current_evolution_level))
	audio_stream_player_2d.pitch_scale = randf_range(0.95, 1.05)
	audio_stream_player_2d.play()

	if current_tile:
		assign_tile(current_tile)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.2).set_ease(Tween.EASE_OUT)
	await tween.finished

	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT)

func assign_tile(tile: Tile):
	current_tile = tile
	previous_tile = tile

func _on_mana_generation_timer_timeout() -> void:
	var mana_count = mana_generation_count()
	root.increase_pink_mana(mana_count)
	alien_label.show_number(mana_count)

func mana_generation_count() -> int:
	return int(pow(current_evolution_level, 1.4) * 2)
