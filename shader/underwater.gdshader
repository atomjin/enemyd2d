shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D fast_noise : repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 speed = vec2(0.03, 0.07);
uniform float wave_strength = 2;
uniform float intensity : hint_range(-1.5, 1.0) = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV + speed * TIME;
    vec2 noise = texture(fast_noise, uv).rg;
    
    // Base color as deep blue (#001129 / rgb(0, 0.06, 0.15))
    vec4 base_color = vec4(0.0, 0.06, 0.15, 1.0);
    
    // White noise effect
    vec4 noise_color = vec4(vec3(noise.x * 0.5 + 0.5), 1.0); // Shift noise to white range

    // Apply screen texture with noise distortion
    vec4 screen_tex = texture(screen_content, SCREEN_UV + noise * (wave_strength / 100.0));

    // Combine base color and noise with intensity factor
    COLOR = mix(base_color, noise_color, intensity) * screen_tex;
    COLOR.a *= opacity;
}
