shader_type canvas_item;

// Use a screen texture to render what's under it
uniform sampler2D screen_texture: hint_screen_texture;
// Use a noise texture to apply a distortion effect
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

// Speed of the water waves
uniform vec2 speed = vec2(0.5, -0.2);
// Strength of the wave effect
uniform float wave_strength = 0.1;
// Strength of the distortion
uniform float distortion = 0.01;

// Called for every vertex the material is visible on.
void vertex() {
	// Move the water slightly up and down
	VERTEX.y += sin(TIME);
}

// Called for every pixel the material is visible on.
void fragment() {
	// Get a noise value in the [-1, 1] range
	vec2 noise = 2.0 * texture(noise_texture, UV + speed * TIME).rg - vec2(1.0);
	// Sample the texture
	COLOR = texture(TEXTURE, UV + noise * wave_strength);
	// Multiply the color with the screen texture
	COLOR *= texture(screen_texture, SCREEN_UV + noise * distortion);
}
