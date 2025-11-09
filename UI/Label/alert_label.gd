extends Label

class_name AlertLabel

var current_text: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func alert_text(new_text: String):
	if new_text != current_text:
		current_text = new_text
		text = new_text
		var duration: float = new_text.length() / 6
		hide_text(duration)


func hide_text(duration: float):
	var tween0 = get_tree().create_tween()
	tween0.tween_property(self, "modulate:a", 1, duration / 3).set_ease(Tween.EASE_IN)
#	
	await tween0.finished
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, duration / 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	text = ""
	current_text = ""
