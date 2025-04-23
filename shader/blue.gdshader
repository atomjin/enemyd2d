shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Default: Blue
uniform float opacity : hint_range(0.0, 1.0) = 1.0; // Default: Fully visible

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // Get the sprite's texture color
    tex_color.rgb = mix(tex_color.rgb, color.rgb, color.a); // Blend with the blue color
    tex_color.a *= opacity; // Apply opacity
    COLOR = tex_color;
}