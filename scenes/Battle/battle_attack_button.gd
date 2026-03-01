extends Button

func setup(attack_enum: Data.Attack) -> void:
	text = Data.attack_data[attack_enum]['name']
