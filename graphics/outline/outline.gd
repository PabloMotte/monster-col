extends Node2D

func _ready() -> void:
	$Sprite2D.texture = add_padding_to_texture($Sprite2D.texture, 5)


func add_padding_to_texture(original_texture: Texture2D, padding: int) -> ImageTexture:
	var original_image = original_texture.get_image()
	if original_image.is_compressed():
		original_image.decompress()
	
	if original_image.get_format() != Image.FORMAT_RGBA8:
		original_image.convert(Image.FORMAT_RGBA8)
		
	var new_width = original_image.get_width() + padding * 2
	var new_height = original_image.get_height() + padding * 2
	var padded_image = Image.create(new_width, new_height, false, Image.FORMAT_RGBA8)
	padded_image.fill(Color(0,0,0,0))
	padded_image.blit_rect(
		original_image,
		Rect2(0,0,original_image.get_width(), original_image.get_height()),
		Vector2(padding, padding)
		)
	return ImageTexture.create_from_image(padded_image)


func _on_h_slider_value_changed(value: float) -> void:
	$Sprite2D.material.set_shader_parameter('line_thickness', value / 100)
