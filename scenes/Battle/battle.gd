extends Node2D

var battle_sprite_scene := preload("res://scenes/Battle/battle_sprite.tscn")
var current_battle_sprite: Sprite2D
var player_reserve_monsters: Array[MonsterResource] = []
var enemy_reserve_monsters: Array[MonsterResource] = []

func _ready() -> void:
	$BG.texture = load(Data.biome_bg[Data.current_biome])
	battle_sprite_setup($StartPositions/Player, $BattleSprites/Player, true, Data.player_monsters)
	battle_sprite_setup($StartPositions/Enemy, $BattleSprites/Enemy, false, Data.enemy_monsters)

func battle_sprite_setup(start_positions: Node2D, parent: Node2D, is_player: bool, data: Array[MonsterResource]) -> void:
	for start_pos_index : int in start_positions.get_child_count():
		if start_pos_index < data.size():
			var pos : Vector2 = start_positions.get_child(start_pos_index).position
			var monster_res : MonsterResource = data[start_pos_index]
			create_battle_sprite(pos, parent, is_player, monster_res, start_pos_index)
	if is_player:
		player_reserve_monsters = data.slice(3)
	else:
		enemy_reserve_monsters = data.slice(3)
		
func create_battle_sprite(pos: Vector2, parent: Node2D, is_player: bool, res: MonsterResource, index: int) -> void:
	var battle_sprite := battle_sprite_scene.instantiate()
	battle_sprite.setup(pos, is_player, res, index)
	parent.add_child(battle_sprite)
	battle_sprite.connect("is_ready", monster_ready)
	battle_sprite.connect("death", monster_death)
	
func monster_ready(battle_sprite: Sprite2D) -> void:
	current_battle_sprite = battle_sprite
	if battle_sprite.playable:
		# show the battle menu
		print(">>> Friendly %s takes a turn" % [Data.monster_data[battle_sprite.monster_res.id]['name']])
		$BattleMenu.reveal(battle_sprite, player_reserve_monsters)
	else:
		# choose an option for the NPC
		print("<<< Enemy %s takes a turn" % [Data.monster_data[battle_sprite.monster_res.id]['name']])
		var attack = battle_sprite.monster_res.get_random_attack()
		if attack is Data.Attack:
			print("  - They chose to attack with %s" % Data.attack_data[attack]['name'])
			perform_attack(-1, attack)
		battle_continue()

func monster_death(is_player: bool, index: int, monster_res: MonsterResource) -> void:
	var reserve_list = player_reserve_monsters if is_player else enemy_reserve_monsters
	var start_positions = $StartPositions/Player if is_player else $StartPositions/Enemy
	var pos = start_positions.get_child(index).position
	var parent = $BattleSprites/Player if is_player else $BattleSprites/Enemy
	if reserve_list.size():
		create_battle_sprite(pos, parent, is_player, reserve_list.pop_at(0), index)
	
	if player_reserve_monsters.size() == 0 and $BattleSprites/Player.get_child_count() == 1:
		finish_battle(false)
	if enemy_reserve_monsters.size() == 0 and $BattleSprites/Enemy.get_child_count() == 1:
		finish_battle(true)
	
	if not is_player:
		var xp_amount :float = monster_res.level / $BattleSprites/Player.get_child_count()
		for battle_sprite in $BattleSprites/Player.get_children():
			battle_sprite.add_xp(int(xp_amount))
	
func perform_attack(index: int, info: Data.Attack) -> void:
	var offensive : bool = Data.attack_data[info]['offensive']
	var target_group = $BattleSprites/Enemy if (offensive and index >= 0) or (!offensive and index < 0) \
											else $BattleSprites/Player
	var target: Sprite2D = target_group.get_child(index) if index >= 0 \
														else target_group.get_children().pick_random()
	if target:
		print("  - targetting %s" % target.monster_res.get_attribute('name'))
		$EffectSprites/BattleAttackSprite.play(info, target.position)
		current_battle_sprite.attack_animation()
		
		var damage: float = Data.attack_data[info]['amount'] * current_battle_sprite.monster_res.level
		var element: Data.Element = Data.attack_data[info]['element']
		var energy_cost: float = (Data.attack_data[info]['cost'] * -1)
		target.change_health(damage, element)
		current_battle_sprite.change_energy(energy_cost)
		print("  - doing %10.3f hp damage" % damage)
	else:
		print("  - but fails to target anyone")

func finish_battle(player_won: bool) -> void:
	if player_won:
		print("You won!")
	else:
		print("You lost! Game over.")
		get_tree().quit()
	var monster_array: Array[MonsterResource]
	for battle_sprite in $BattleSprites/Player.get_children():
		monster_array.append(battle_sprite.monster_res)
	Data.player_monsters = monster_array + player_reserve_monsters
	TransitionLayer.transition(Data.current_loc, Data.Location.BATTLE)

func battle_continue() -> void:
	await get_tree().create_timer(0.5).timeout
	current_battle_sprite = null
	for battle_sprite in get_tree().get_nodes_in_group("BattleSprites"):
		battle_sprite.paused = false

func _on_battle_menu_defend() -> void:
	print("  - They chose to defend")
	$BattleMenu.finish()
	battle_continue()

func _on_battle_menu_select(state: Data.MenuState, info: Variant) -> void:
	if state == Data.MenuState.ATTACK:
		var attack_data = Data.attack_data[info]
		print("  - They chose to attack with %s" % attack_data['name'])
		var target : Node2D = $BattleSprites/Enemy if attack_data['offensive'] else $BattleSprites/Player
		$EffectSprites/BattleSelectSprite.activate(target, info, Data.MenuState.ATTACK)
	if state == Data.MenuState.CATCH:
		var target = $BattleSprites/Enemy
		$EffectSprites/BattleSelectSprite.activate(target, info, Data.MenuState.CATCH)

func _on_battle_select_sprite_cancel(state: Data.MenuState) -> void:
	$BattleMenu.cancel(state)

func _on_battle_select_sprite_use(index: int, info: Variant, state: Data.MenuState) -> void:
	if state == Data.MenuState.ATTACK:
		perform_attack(index, info)
	if state == Data.MenuState.CATCH:
		var target: Sprite2D = $BattleSprites/Enemy.get_child(index)
		if target.monster_res.current_hp <= target.monster_res.get_stat('max hp') * 0.1:
			player_reserve_monsters.append(target.monster_res)
			target.queue_free()
	battle_continue()


func _on_battle_menu_swap(index: int, res: MonsterResource) -> void:
	player_reserve_monsters.remove_at(index)
	player_reserve_monsters.append(current_battle_sprite.monster_res)
	current_battle_sprite.change(res)
	battle_continue()
