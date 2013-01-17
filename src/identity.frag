#version 330

in vec4 varyingColor; //Input color from the vertex shader.

//out vec4 color; //Output fragment color.

void main( void ) {
  //color = varyingColor;  //Simply outputs the same color.
  gl_FragColor = varyingColor;
}