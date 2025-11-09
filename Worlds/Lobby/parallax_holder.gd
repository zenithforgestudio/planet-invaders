extends Node2D

@onready var bg_stars_1: Sprite2D = $BGStars1
@onready var bg_stars_2: Sprite2D = $BGStars2
@onready var bg_nebulae_1: Sprite2D = $BGNebulae1
@onready var bg_nebulae_2: Sprite2D = $BGNebulae2
@onready var bg_dust_1: Sprite2D = $BGDust1
@onready var bg_dust_2: Sprite2D = $BGDust2
@onready var bg_planets_1: Sprite2D = $BGPlanets1
@onready var bg_planets_2: Sprite2D = $BGPlanets2

@export var stars_scroll_speed: int = 5
@export var nebulae_scroll_speed: int = 10
@export var dust_scroll_speed: int = 15
@export var planets_scroll_speed: int = 20

func _process(delta: float) -> void:
	# Scroll each background pair
	scroll_layer(bg_stars_1, bg_stars_2, stars_scroll_speed, delta)
	scroll_layer(bg_nebulae_1, bg_nebulae_2, nebulae_scroll_speed, delta)
	scroll_layer(bg_dust_1, bg_dust_2, dust_scroll_speed, delta)
	scroll_layer(bg_planets_1, bg_planets_2, planets_scroll_speed, delta)

# Helper function to scroll and wrap two sprites vertically
func scroll_layer(sprite_a: Sprite2D, sprite_b: Sprite2D, speed: float, delta: float) -> void:
	# Scroll both sprites downward
	sprite_a.position.y += speed * delta
	sprite_b.position.y += speed * delta

	# Get texture height (assumes both sprites are same size)
	var height = 900

	# If a sprite goes below the screen, move it above its pair
	if sprite_a.global_position.y >= 1.5 * height:
		sprite_a.global_position.y = sprite_b.global_position.y - height
	elif sprite_b.global_position.y >= 1.5 * height:
		sprite_b.global_position.y = sprite_a.global_position.y - height
