shader_type spatial;
render_mode unshaded, depth_draw_always;

uniform vec3 bubble_color = vec3(0.7, 0.9, 1.0); // Base color of the bubble
uniform float fresnel_power = 5.0; // Controls edge brightness
uniform float refraction_strength = 0.05; // Refraction strength

// Declare screen texture
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec3 view_dir = normalize(VIEW);
    
    // Fresnel effect (brighter edges)
    float fresnel = pow(1.0 - dot(NORMAL, view_dir), fresnel_power);

    // Get screen UVs with an offset for fake refraction
    vec2 screen_uv = SCREEN_UV + NORMAL.xy * refraction_strength;
    
    // Fetch screen color (background behind bubble)
    vec3 refracted_color = texture(screen_texture, screen_uv).rgb;

    // Mix bubble color with refraction based on fresnel
    vec3 final_color = mix(bubble_color, refracted_color, fresnel);

    // Adjust transparency (-, more = more opaque,-)
    float alpha = clamp(fresnel, 0.03, 1.0);

    ALBEDO = final_color;
    ALPHA = alpha;
} 