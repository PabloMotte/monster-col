extends Control

var battle_attack_button_scene = preload("res://scenes/Battle/battle_attack_button.tscn")
var battle_swap_button_scene = preload("res://scenes/Battle/battle_swap_button.tscn")

## distance between menu items
@export_range(0, 360, 0.1, "degrees") var menu_separator_angle : float = 24.0
## distance from monster to right-side menu
@export var menu_radius : float = 50.0
const MENU_POSITION_OFFSET : Vector2 = Vector2(0, -8)
var monster_res: MonsterResource
var monster_list: Array[MonsterResource]
var state: Data.MenuState: set = state_handler
const button_link = {
	0: Data.MenuState.ATTACK,
	1: Data.MenuState.DEFEND,
	2: Data.MenuState.SWAP,
	3: Data.MenuState.CATCH,
}
signal defend()
signal select(state: Data.MenuState, info)
signal swap(index: int, res: MonsterResource)

func _ready() -> void:
	for node in get_children():
		node.hide()

func _input(_event: InputEvent) -> void:
	if not $Support/StopTimer.time_left:
		if Input.is_action_just_pressed("ui_cancel"):
			if state in [Data.MenuState.ATTACK, Data.MenuState.SWAP, Data.MenuState.CATCH]:
				state = Data.MenuState.MAIN

func reveal(battle_sprite: Sprite2D, reserve_monsters: Array[MonsterResource]) -> void:
	monster_res = battle_sprite.monster_res
	monster_list = reserve_monsters
	state = Data.MenuState.MAIN
	position = battle_sprite.position
	show()
	
func state_handler(new_state: Data.MenuState) -> void:
	state = new_state
	for node : Control in get_children():
		node.hide()
	match state:
		Data.MenuState.MAIN:
			$MainSelection.show()
			main_button_setup()
		Data.MenuState.ATTACK:
			$AttackButtonContainer.show()
			attack_button_setup()
		Data.MenuState.CATCH:
			select.emit(Data.MenuState.CATCH, null)
		Data.MenuState.SWAP:
			$SwapContainer.show()
			swap_button_setup()

func button_handler(current_state: Data.MenuState, info) -> void:
	match current_state:
		Data.MenuState.MAIN:
			match info:
				Data.MenuState.DEFEND:
					defend.emit()
				_:
					state = info
		Data.MenuState.ATTACK:
			state = Data.MenuState.SELECT
			select.emit(Data.MenuState.ATTACK, info)
		Data.MenuState.SWAP:
			swap.emit(info[0], info[1])
			finish()

func main_button_setup() -> void:
	for node in $MainSelection.get_children():
		node.hide()
	# we do not want to display "catch" when battling Trainer monsters, so don't display last menu item
	var subtract_menu_item: int = 1 if Data.trainer_fight else 0
	var angle_size_modifier : float = (($MainSelection.get_child_count() - subtract_menu_item) - 1)/2.0
	for i : int in ($MainSelection.get_child_count() - subtract_menu_item):
		var button : TextureButton = $MainSelection.get_child(i)
		var angle : float = deg_to_rad((menu_separator_angle * i) - (menu_separator_angle * angle_size_modifier))
		button.position = Vector2(menu_radius, 0).rotated(angle) + MENU_POSITION_OFFSET
		button.show()
		button.state = Data.MenuState.MAIN
		button.info = button_link[i]
		if not button.is_connected("press", button_handler):
			button.connect("press", button_handler)
	if $MainSelection.get_child_count() > 0:
		await get_tree().process_frame
		$MainSelection.get_child(0).grab_focus()

func attack_button_setup() -> void:
	for button in $AttackButtonContainer.get_children():
		button.queue_free()
	for attack_enum in monster_res.get_attacks():
		var btn = battle_attack_button_scene.instantiate()
		btn.setup(attack_enum, monster_res.current_ep)
		btn.connect("press", button_handler)
		$AttackButtonContainer.add_child(btn)
		btn.show()
	if $AttackButtonContainer.get_child_count() > 0:
		await get_tree().process_frame
		$AttackButtonContainer.get_child(0).grab_focus()

func swap_button_setup() -> void:
	for btn in $SwapContainer/ScrollContainer/VBoxContainer.get_children():
		btn.queue_free()
	for i in monster_list.size():
		var btn = battle_swap_button_scene.instantiate() as Button
		var res = monster_list[i]
		btn.setup(res, i)
		btn.connect("press", button_handler)
		$SwapContainer/ScrollContainer/VBoxContainer.add_child(btn)
	if $SwapContainer/ScrollContainer/VBoxContainer.get_child_count() > 0:
		await get_tree().process_frame
		$SwapContainer/ScrollContainer/VBoxContainer.get_child(0).grab_focus()

func finish() -> void:
	for node in get_children():
		node.hide()

func cancel(new_state: Data.MenuState):
	if new_state in [Data.MenuState.ATTACK]:
		state = new_state
	if new_state in [Data.MenuState.CATCH]:
		state = Data.MenuState.MAIN
	$Support/StopTimer.start()
	
