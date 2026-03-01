extends TextureButton

var state: Data.MenuState
var info: Data.MenuState
signal press(state: Data.MenuState, info: Data.MenuState)


func _on_pressed() -> void:
	press.emit(state, info)
