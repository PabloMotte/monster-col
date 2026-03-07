extends Character

@export var dialog: Array[String]
@export var fin_dialog: Array[String]
@export var quest_res: QuestResource
var completed_quest: bool = false

func get_dialog() -> Array[String]:
	var current_dialog = dialog if not quest_res.check_complete(get_tree()) else fin_dialog
	return current_dialog

func get_dialog_text() -> String:
	var text: String = get_dialog()[dialog_index]
	if text.contains(' xxx'):
		# replace with unique monster count
		var num_monsters := quest_res.get_unique_player_monsters().size()
		text = text.replace(' xxx', ' ' + str(num_monsters) + ' unique monster' + ('' if num_monsters == 1 else 's'))
	return text
	
func show_dialog() -> void:
	$DialogBox.show()
	$DialogBox.set_text(get_dialog_text())
	
func advance_dialog():
	if dialog_index < get_dialog().size() - 1:
		dialog_index += 1
		show_dialog()
	else:
		$DialogBox.hide()
		get_player().can_move = true
		Data.current_char = null
		dialog_index = 0
