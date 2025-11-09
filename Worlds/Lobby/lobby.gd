extends Node2D

class_name Root

@onready var back_ground: Sprite2D = $BackGround
@onready var pink_tank: PinkTank = $PinkTank
@onready var pink_particles_effect: CPUParticles2D = $PinkParticlesEffect
@onready var alien_grinder: Area2D = $AlienGrinder
@onready var alien_label: AlienLabel = $Marker2D/AlienLabel


@export var gradient_colors: Array[Color] = [
	Color("f5a097"),  # Orange
	Color("e86a73"),  # Orange-Pink
	Color("bc4a9b"),  # Pink-Orange
	Color("793a80")   # Pink
]


const TILE = preload("uid://bt0chqy8r1ca2")
const ALIEN_1 = preload("uid://4ful311i8fk8")


const HORIZONTAL_TILE_OFFSET: int = 78
const VERTICAL_TILE_OFFSET: int = 300
const TILE_SIZE: int = 88
const TILE_SPACING: int = 10

var horizontal_size: int = 3
var vertical_size: int = 3
var tiles
var max_mana_value: int = 1000
#var current_mana_value: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	#Global._load()
	#current_mana_value = Global.current_mana_value
	alien_grinder.set_pool_value(Global.current_evolution_mana_value)
	horizontal_size = Global.horizontal_tile_count
	vertical_size = Global.vertical_tile_count
	for i in range (vertical_size):
		for j in range (horizontal_size):
			var tile: Tile = TILE.instantiate()
			add_child(tile)
			tile.position = Vector2(HORIZONTAL_TILE_OFFSET, VERTICAL_TILE_OFFSET) + Vector2(j * (TILE_SIZE + TILE_SPACING), i * (TILE_SIZE + TILE_SPACING))
	tiles = get_tree().get_nodes_in_group("dropable")
	
	pink_tank.global_position = tiles[0].global_position
	tiles[0].occupy(pink_tank)
	pink_tank.set_progress_bar_value(Global.current_mana_value)
	alien_grinder.global_position = tiles[1].global_position
	tiles[1].occupy(alien_grinder)
	load_grinder_progress()
	load_aliens()
	
func load_grinder_progress() -> void:
	#print("Grinder value: " + str(Global.current_evolution_mana_value))
	alien_grinder.set_pool_value(Global.current_evolution_mana_value)
	
	
	
func load_aliens() -> void:
	# Remove only PinkAliens, keep Tank + Grinder
	for tile in tiles:
		var occ = tile.get_occupant()
		if occ != null and occ.is_in_group("PinkAlien"):
			occ.queue_free()
			tile.vacate()

	var freq: Array = Global.constent_to_save["tile_aliens_frequency"]

	print("\n[DEBUG] --- Loading Aliens ---")
	print("[DEBUG] Frequency array:", freq)

	# Loop over levels 1..max
	for level in range(1, freq.size()):
		var count = freq[level]
		print("[DEBUG] Spawning ", count, " aliens of level", level)
		for i in range(count):
			_spawn_alien_of_level(level)

	print("[DEBUG] Finished loading aliens.\n")

		
func _spawn_alien_of_level(level: int) -> void:
	# find a free tile
	
	for tile in tiles:
		if tile._is_occupied() == false:
			var alien: PinkAlien = ALIEN_1.instantiate()
			add_child(alien)
			alien.global_position = tile.global_position
			tile.occupy(alien)
			alien.assign_tile(tile)

			# upgrade to the correct level
			for i in range(level - 1):
				alien.increase_current_evolution()
				
			#alien.board_changed.connect(self._on_board_changed)
			return

func _on_board_changed():
	print("new board state, saving...")
	save_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	back_ground.global_position.y -= 10 * delta
	if back_ground.global_position.y <= -7000:
		back_ground.global_position.y = 0
	
	
func show_alien_label_text(new_text: String):
	alien_label.show_text(new_text)
	

	
func set_current_mana_value(new_mana_value: int) -> void:
	Global.current_mana_value = new_mana_value
	pink_tank.set_progress_bar_value(new_mana_value)


func increase_pink_mana(mana_value: int):
	set_current_mana_value(Global.current_mana_value + mana_value)

func spawn_alien_pink(pos: Vector2):
	pink_tank.play_animation("Push")
	
	if Global.current_mana_value < 100:
		show_alien_label_text("Not enough \ngenoplasm!")
		return
	
	var spawned_alien = false
	tiles = get_tree().get_nodes_in_group("dropable")
	for tile in tiles:
		if tile._is_occupied() == false:
			emit_particles(pink_tank.global_position)
			spawned_alien = true
			var alien: PinkAlien = ALIEN_1.instantiate()
			add_child(alien)
			alien.global_position = pos
			alien.assign_tile(tile)
			var tween = get_tree().create_tween()
			tween.tween_property(alien, "global_position", tile.global_position, 0.2).set_trans(Tween.TRANS_BOUNCE)
			tile.occupy(alien)
			alien.assign_tile(tile)
			#print("alien spawned")
			Global.current_mana_value -= 100
			pink_tank.set_progress_bar_value(Global.current_mana_value)
			save_data()
			return
			
	show_alien_label_text("No empty tiles!")
	#print("no tiles available!")





func _on_refill_button_pressed() -> void:
	set_current_mana_value(1000)

func debug_alien_positions():
	for tile in tiles:
		var alien = tile.get_occupant()
		if alien != null:
			alien.global_position = tile.global_position
			
func _on_debug_button_pressed() -> void:
	debug_alien_positions()
	
func emit_particles(pos: Vector2):
	pink_particles_effect.global_position = pos
	
	# Create gradient texture from colors
	#var gradient = create_gradient(gradient_colors)
	#var gradient_texture = create_gradient_texture(gradient)

	# Set properties directly on CPUParticles2D node
	#pink_particles_effect.color_ramp = gradient_texture
	pink_particles_effect.gravity = Vector2(0, 100)
	pink_particles_effect.initial_velocity_min = 100
	pink_particles_effect.initial_velocity_max = 100
	#pink_particles_effect.angle = 0
	#pink_particles_effect.angle_random = 1.0
	#pink_particles_effect.scale = Vector2(1, 1)
	#pink_particles_effect.scale_random = 0.5
	#pink_particles_effect.direction = Vector2(0, -1)
	#pink_particles_effect.spread = 180.0

	# Restart the effect
	#pink_particles_effect.emitting = false
	pink_particles_effect.emitting = true

	
#func create_gradient(colors: Array[Color]) -> Gradient:
	#var grad := Gradient.new()
	#var offsets := []
	#var steps := colors.size()
	#
	#for i in range(steps):
		#offsets.append(float(i) / float(steps - 1))
	#
	#grad.colors = colors
	#grad.offsets = offsets
	#return grad
#
#
#func create_gradient_texture(gradient: Gradient) -> GradientTexture1D:
	#var texture := GradientTexture1D.new()
	#texture.gradient = gradient
	#return texture


func _on_save_button_pressed() -> void:
	save_data()
	
func save_data():
	Global.constent_to_save["max_level"] = Global.max_level
	Global.constent_to_save["current_mana_value"] = Global.current_mana_value
	Global.constent_to_save["current_mana_evolution_level"] = alien_grinder.get_current_evolution_mana()
	Global.constent_to_save["last_exit_unix_time"] = Time.get_unix_time_from_system()
	#print("saving grinder stats:" + str(alien_grinder.get_current_evolution_mana()))
	save_aliens()
	Global._save()


func _on_reset_button_pressed() -> void:
	Global._reset()
	Global.constent_to_save["max_level"] = 3
	Global.constent_to_save["current_mana_value"] = 1000
	Global.constent_to_save["current_mana_evolution_level"] = 0
	Global._save()
	get_tree().reload_current_scene()
	
	
func save_aliens() -> void:
	# Ensure array exists and is the right size
	var size_needed := Global.max_level + 1
	if Global.constent_to_save["tile_aliens_frequency"].size() != size_needed:
		Global.constent_to_save["tile_aliens_frequency"].resize(size_needed)

	# Reset all counts to 0 before recounting
	for i in range(size_needed):
		Global.constent_to_save["tile_aliens_frequency"][i] = 0

	print("\n[DEBUG] --- Saving Aliens ---")

	# Count aliens
	for tile in tiles:
		var alien = tile.get_occupant()
		if alien != null and alien.is_in_group("PinkAlien"):
			var level = alien.get_current_evolution_level()
			
			Global.constent_to_save["tile_aliens_frequency"][level] += 1
			
			#print("[DEBUG] Found PinkAlien at tile:", tile, " Level:", level)

	print("[DEBUG] Resulting frequency array:", Global.constent_to_save["tile_aliens_frequency"])
	print("[DEBUG] -------------------------\n")
	
	
func _notification(what):
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("[SAVE] App paused — saving.")
		save_data()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		print("[APP] App resumed — reloading silent state.")
