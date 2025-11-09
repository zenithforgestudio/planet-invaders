extends TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	var area = get_parent() as Area2D
	var sprite := area.get_node_or_null("Sprite2D")
	
	if sprite:
		var preview_texture = TextureRect.new()
		preview_texture.texture = sprite.texture
		preview_texture.expand_mode = 1
		preview_texture.size = Vector2(30, 30)

		var preview = Control.new()
		preview.add_child(preview_texture)

		set_drag_preview(preview)

	return area



func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Area2D


func _drop_data(at_position: Vector2, data: Variant):
	if data is Area2D:
		# Optional: position it at drop location (in local/global coords depending on context)
		data.global_position = get_global_mouse_position()

		# Optionally reparent it to the new location
		get_parent().add_child(data)
