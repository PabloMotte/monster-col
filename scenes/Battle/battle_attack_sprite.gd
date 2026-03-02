extends Sprite2D

func play(attack: Data.Attack, pos: Vector2) -> void:
	position = pos
	texture = load(Data.attack_data[attack]['texture'])
	var tween = create_tween()
	tween.tween_property(self, "visible", true, 0)
	tween.tween_property(self, "frame", hframes-1, 0.8).from(0)
	tween.tween_property(self, "visible", false, 0)
	
