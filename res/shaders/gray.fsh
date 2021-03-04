#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

void main(void)
{
	vec4 c = texture2D(u_texture, v_texCoord);
    float grey = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    gl_FragColor = v_fragmentColor * vec4(grey, grey, grey, c.a);
}