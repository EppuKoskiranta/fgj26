shader_type canvas_item;

uniform vec3 color = vec3(0.0, 0.0, 0.0);
uniform float transparency : hint_range(0.0, 1.0) = 0.8;
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_linear_mipmap_anisotropic;

void fragment() {
	vec4 blurred_image = textureLod(screen_texture, SCREEN_UV, 1.8);
	COLOR.a = 1.0;
	COLOR.rgb = transparency*blurred_image.rgb + (1.0-transparency)*color; 
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
