extends Node2D

var battle_sprite_scene := preload("res://scenes/Battle/battle_sprite.tscn")
var current_battle_sprite: Sprite2D

func _ready() -> void:
	$BG.texture = load(Data.biome_bg[Data.current_biome])
	battle_sprite_setup($StartPositions/Player, $BattleSprites/Player, true, Data.player_monsters)
	battle_sprite_setup($StartPositions/Enemy, $BattleSprites/Enemy, false, Data.enemy_monsters)

func battle_sprite_setup(start_positions: Node2D, parent: Node2D, is_player: bool, data: Array[MonsterResource]) -> void:
	for start_pos_index : int in start_positions.get_child_count():
		if start_pos_index < data.size():
			var pos : Vector2 = start_positions.get_child(start_pos_index).position
			var monster_res : MonsterResource = data[start_pos_index]
			create_battle_sprite(pos, parent, is_player, monster_res)
		
func create_battle_sprite(pos: Vector2, parent: Node2D, is_player: bool, res: MonsterResource) -> void:
	var battle_sprite := battle_sprite_scene.instantiate()
	battle_sprite.setup(pos, is_player, res)
	parent.add_child(battle_sprite)
	battle_sprite.connect("is_ready", monster_ready)
	
func monster_ready(battle_sprite: Sprite2D) -> void:
	current_battle_sprite = battle_sprite
	if battle_sprite.playable:
		# show the battle menu
		print(">>> Friendly %s takes a turn" % [Data.monster_data[battle_sprite.monster_res.id]['name']])
		$BattleMenu.reveal(battle_sprite)
	else:
		# choose an option for the NPC
		print("<<< Enemy %s takes a turn" % [Data.monster_data[battle_sprite.monster_res.id]['name']])
		battle_continue()


func _on_battle_menu_defend() -> void:
	print("  - They chose to defend")
	$BattleMenu.finish()
	battle_continue()

func battle_continue() -> void:
	await get_tree().create_timer(0.5).timeout
	current_battle_sprite = null
	for battle_sprite in get_tree().get_nodes_in_group("BattleSprites"):
		battle_sprite.paused = false
	
