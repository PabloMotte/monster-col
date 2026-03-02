extends Button

var info: Data.Attack
signal press(state: Data.MenuState, info: Data.Attack)

func setup(attack_enum: Data.Attack, current_ep: float) -> void:
	text = Data.attack_data[attack_enum]['name']
	info = attack_enum
	if current_ep < Data.attack_data[attack_enum]['cost']:
		disabled = true

func _on_pressed() -> void:
	press.emit(Data.MenuState.ATTACK, info)
