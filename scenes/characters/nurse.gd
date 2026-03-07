extends Character

@export var dialog: Array[String]

func show_dialog() -> void:
	$DialogBox.show()
	$DialogBox.set_text(dialog[dialog_index])
	
func advance_dialog():
	if dialog_index == 0:
		TransitionLayer.white_screen(self)
		# finish_dialog()
	else:
		$DialogBox.hide()
		get_player().can_move = true
		Data.current_char = null
		dialog_index = 0

func finish_dialog() -> void:
	dialog_index += 1
	show_dialog()
	
func heal_sound() -> void:
	$HealSound.play()
