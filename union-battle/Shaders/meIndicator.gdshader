shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float shape = (dot(UV-0.5, UV-0.5) < 0.2) ? 1.0 : 0.0;
	float tfac = (0.5+0.3*sin(TIME*2.0));
	COLOR = vec4(UV,0.5,shape);
}
