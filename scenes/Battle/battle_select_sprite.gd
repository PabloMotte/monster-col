extends Sprite2D

var target: Node2D
var info: Variant
var state: Data.MenuState
var index: int
const textures = {
	Data.MenuState.ATTACK: preload("res://graphics/UI/options5.png"),
	Data.MenuState.CATCH: preload("res://graphics/UI/options8.png"),
}
signal cancel(state: Data.MenuState)
signal use(index: int, info: Variant, state: Data.MenuState)

func _ready() -> void:
	hide()

func activate(new_target: Node2D, new_info: Variant, new_state: Data.MenuState) -> void:
	target = new_target
	info = new_info
	state = new_state
	index = 0
	position = target.get_child(index).position
	texture = textures[state]
	show()
	
func _input(_event: InputEvent) -> void:
	if visible:
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
			var dir = Input.get_axis("ui_up", "ui_down")
			index = posmod(index + dir, target.get_child_count())
			position = target.get_child(index).position
		if Input.is_action_just_pressed("ui_cancel"):
			hide()
			cancel.emit(state)
		if Input.is_action_just_pressed("ui_accept"):
			use.emit(index, info, state)
			hide()
