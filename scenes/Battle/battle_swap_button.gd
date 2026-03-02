extends Button

var res: MonsterResource
var index: int

signal press(state: Data.MenuState, info)

func setup(monster_res: MonsterResource, new_index: int) -> void:
	res = monster_res
	index = new_index
	$HBoxContainer/Label.text = Data.monster_data[res.id]['name']
	$HBoxContainer/TextureRect.texture = load(Data.monster_data[res.id]['icon texture'])


func _on_pressed() -> void:
	press.emit(Data.MenuState.SWAP, [index, res])
