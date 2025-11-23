shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

mat2 rot(float a) {
	return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
}
void fragment() {
	// Called for every pixel the material is visible on.
	vec2 coord = 0.5 + UV * rot(TIME);
	float shape = 1.0 - 4.0*dot(UV-0.5, UV-0.5);
	float tfac = (0.5+0.3*sin(TIME*sqrt(2.0)));
	COLOR = vec4(coord,0.5,shape*tfac);
}
