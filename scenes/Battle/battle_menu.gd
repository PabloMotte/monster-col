extends Control

var battle_attack_button_scene = preload("res://scenes/Battle/battle_attack_button.tscn")

## distance between menu items
@export_range(0, 360, 0.1, "degrees") var menu_separator_angle : float = 24.0
## distance from monster to right-side menu
@export var menu_radius : float = 50.0
const MENU_POSITION_OFFSET : Vector2 = Vector2(0, -8)
var monster_res: MonsterResource
var state: Data.MenuState: set = state_handler
const button_link = {
	0: Data.MenuState.ATTACK,
	1: Data.MenuState.DEFEND,
	2: Data.MenuState.SWAP,
	3: Data.MenuState.CATCH,
}
signal defend()

func _ready() -> void:
	for node in get_children():
		node.hide()
	
func reveal(battle_sprite: Sprite2D) -> void:
	monster_res = battle_sprite.monster_res
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

func button_handler(current_state: Data.MenuState, info) -> void:
	match current_state:
		Data.MenuState.MAIN:
			match info:
				Data.MenuState.DEFEND:
					defend.emit()
				_:
					state = info

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
	await get_tree().process_frame
	$MainSelection.get_child(0).grab_focus()

func attack_button_setup() -> void:
	for button in $AttackButtonContainer.get_children():
		button.queue_free()
	for attack_enum in monster_res.get_attacks():
		var btn = battle_attack_button_scene.instantiate()
		btn.setup(attack_enum)
		$AttackButtonContainer.add_child(btn)

func finish() -> void:
	for node in get_children():
		node.hide()
