shader_type canvas_item;

void fragment() {
    COLOR.rgb = vec3(0.0);  // Set color to black
    // Keep the original alpha from texture or modulate
    COLOR.a = texture(TEXTURE, UV).a * COLOR.a;
}
