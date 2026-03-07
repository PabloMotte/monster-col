extends Node

var in_battle: bool = false:
	set(new_value):
		in_battle = new_value
		var tween = create_tween()
		tween.set_parallel(true)
		if in_battle:
			$BattleMusic.play()
			# fade out BG music
			tween.tween_property($LevelMusic, 'volume_db', -100, 0.6)
			tween.tween_property($BattleMusic, 'volume_db', -15, 0.6)
		else:
			# fade out BG music
			tween.tween_property($LevelMusic, 'volume_db', -15, 0.6)
			tween.tween_property($BattleMusic, 'volume_db', -100, 0.6)
			$BattleMusic.stop()

func _ready() -> void:
	in_battle = false
