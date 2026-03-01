class_name MonsterResource extends Resource

@export var id: Data.Monster
@export var level: int

func setup(new_id: Data.Monster, new_level: int) -> void:
	id = new_id
	level = new_level

func get_stat(stat: String) -> float:
	return Data.monster_data[id]['stats'][stat] * level

func get_attacks() -> Array:
	var attacks: Array
	for level_req in Data.monster_data[id]['attacks'].keys():
		if level >= level_req:
			attacks.append(Data.monster_data[id]['attacks'][level_req])
	return attacks
	
	
