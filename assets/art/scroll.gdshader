shader_type canvas_item;

uniform float xSpeed = .1;
uniform float ySpeed = -.1;

void vertex() {
	UV.x += TIME * xSpeed;
	UV.y += TIME * ySpeed;
}
