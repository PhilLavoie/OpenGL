#version 330

in vec4 vertex;  //Vertex position attribute.
in vec4 color;   //Vertex color attribute.

out vec4 varyingColor; //Color value passed to fragment shader.

void main( void ) {
  varyingColor = color; //Copy color value.
  gl_Position = vertex; //Pass along vertex position.
}