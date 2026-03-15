shader_type canvas_item;

uniform int pixel_size: hint_range(0.0, 32.0);

void fragment() {
	vec2 texture_size_px = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 grid_dimension = texture_size_px / float(pixel_size);
	vec2 pixel_uv = floor((UV * grid_dimension) + 0.5)/ grid_dimension;
	COLOR = texture(TEXTURE, pixel_uv);
}
