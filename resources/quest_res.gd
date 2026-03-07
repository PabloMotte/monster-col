class_name  QuestResource extends Resource

@export var quest : Data.Quest

func check_complete(tree) -> bool:
	match quest:
		Data.Quest.BOSS_FIGHT:
			var bosses: Array
			for trainer in tree.get_nodes_in_group('Trainers'):
				if trainer.boss:
					bosses.append(trainer)
			return bosses.all(_check_defeat)
		Data.Quest.CATCH_ALL:
			return Data.Monster.size() == get_unique_player_monsters().size()
		Data.Quest.DEFEAT_ALL:
			return tree.get_nodes_in_group('Trainers').all(_check_defeat)
	return false
	
func _check_catch() -> bool:
	return false
	
func _check_defeat(trainer) -> bool:
	return trainer.defeated

func get_unique_player_monsters() -> Array[Data.Monster]:
	var unique : Array[Data.Monster]
	for monster: MonsterResource in Data.player_monsters:
		if not monster.id in unique:
			unique.append(monster.id)
	return unique
