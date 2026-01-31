shader_type spatial;

uniform sampler2D skin_tex;
uniform sampler2D lotion_tex;

uniform sampler2D coverage_mask;

uniform float lotion_height = 0.02;
uniform float lotion_roughness = 0.1;

void vertex()
{
	VERTEX.z += 0.001;
}

void fragment() {
	
    float coverage = texture(coverage_mask, UV).r;
	float height = texture(coverage_mask, UV).r;

    vec3 skin = texture(skin_tex, UV).rgb;
    vec3 lotion = texture(lotion_tex, UV).rgb;

    if (coverage > 0.0) {
    	ALBEDO = lotion;
	} else {
	    ALBEDO = skin;
	}

    // Makes lotion catch light
    NORMAL_MAP_DEPTH = height * lotion_height;
    ROUGHNESS = mix(0.6, lotion_roughness, coverage);
    SPECULAR = mix(0.3, 0.7, coverage);
}