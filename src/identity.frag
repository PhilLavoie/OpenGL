#version 330

in vec4 varyingColor; //Input color from the vertex shader.

out vec4 result; //Output fragment color.

void main( void ) {
  result = varyingColor;  //Simply outputs the same color.
}