shader_type canvas_item;

uniform sampler2D mask;
//uniform float scale = 1;
//varying vec2 player_position;

void vertex(){
	//player_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR.a = texture(mask, muv).r;
}