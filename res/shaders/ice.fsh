#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

void main(void)
{
	vec4 c = texture2D(u_texture, v_texCoord);
    gl_FragColor = v_fragmentColor * vec4(c.r, c.g*1.5, c.b*2.5, c.a);
}