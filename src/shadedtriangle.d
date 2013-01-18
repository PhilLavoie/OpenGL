module shadedtriangle;

import nucleus.gui.glwindow;
import nucleus.gl.glcolors;
import nucleus.gl.glerrors;
import nucleus.gl.shaders;

import std.stdio;
import File = std.file;
import std.utf;
import std.string;
import std.algorithm;


void main( string[] args ) {
  auto wnd = new GLWindow( "Shaded Triangle" );
  auto ctx = wnd.glContext();
  ctx.loadAll();  //Loads all known function pointers.
  
  Program program = 
    Program(
      VertexShader( File.readText( "identity.vert" ).toStringz ),
      FragmentShader( File.readText( "identity.frag" ).toStringz ),
      Attribute( AttributeIndex.coordinates, "vertex".toStringz ), 
      Attribute( AttributeIndex.color, "color".toStringz )
    );
  program.build( ctx );
  ctx.use( program );
    
  float[] triangleVertices = 
    [ 
      -.75f, -.75f, 0.0f, 1.0f,
      0.75f, -.75f, 0.0f, 1.0f,
		  0.0f, 0.75f, 0.0f, 1.0f
    ];
  float[] triangleColors =
    [
      blue.red,  blue.green,  blue.blue, blue.alpha,
      green.red, green.green, green.blue, green.alpha,
      yellow.red,   yellow.green,   yellow.blue, yellow.alpha
    ];
  //Load attribute locations.
  GLint vertexPos = AttributeIndex.coordinates, colorPos = AttributeIndex.color;  
  
  /*
  vertexPos = ctx.glGetAttribLocation( program.handle, "vertex".toStringz );
  writeln( "Vertex position: ", vertexPos );
  assert( vertexPos != -1, "unable to retrieve vertex var location" );
  colorPos = ctx.glGetAttribLocation( program.handle, "color".toStringz );
  writeln( "Color position: ", colorPos );
  assert( colorPos != -1, "unable to retrieve color var location" );
  */
  
  //Loading data inside buffer objects.
  GLuint vertexBO, colorBO; //Vertex and color buffer objects.
  ctx.glGenBuffers( 1, &vertexBO );
  ctx.glBindBuffer( GL_ARRAY_BUFFER, vertexBO );
  ctx.glBufferData( GL_ARRAY_BUFFER, triangleVertices.length * float.sizeof, triangleVertices.ptr, GL_STATIC_DRAW );
  ctx.glBindBuffer( GL_ARRAY_BUFFER, 0 );
  ctx.glGenBuffers( 1, &colorBO );
  ctx.glBindBuffer( GL_ARRAY_BUFFER, colorBO );
  ctx.glBufferData( GL_ARRAY_BUFFER, triangleColors.length * float.sizeof, triangleColors.ptr, GL_STATIC_DRAW );
  ctx.glBindBuffer( GL_ARRAY_BUFFER, 0 );
  
  ctx.glPolygonMode( GL_FRONT, GL_FILL );
  ctx.glPolygonMode( GL_BACK, GL_FILL );
      
  printErrors( ctx );
  
  wnd.onResize = 
    ( size_t width, size_t height ) { 
      ctx.glViewport( 0, 0, width, height );       
    };
  wnd.onRender = 
    () { 
      ctx.glClearColor( black.red, black.green, black.blue, 0 ); 
      ctx.glClear( GL_COLOR_BUFFER_BIT  );  
      
      ctx.glEnableVertexAttribArray( vertexPos );
      ctx.glBindBuffer( GL_ARRAY_BUFFER, vertexBO );      
      ctx.glVertexAttribPointer(
        vertexPos,        // attribute
        4,                // number of elements per vertex
        GL_FLOAT,         // the type of each element
        GL_FALSE,         // take our values as-is
        0,                // no extra data between each position
        null              // Offset of the first element.
      );
     
      with( ctx ) {
        glEnableVertexAttribArray( colorPos );
        glBindBuffer( GL_ARRAY_BUFFER, colorBO );
        glVertexAttribPointer(
          colorPos,          // attribute
          4,                 // number of elements per vertex
          GL_FLOAT,          // the type of each element
          GL_FALSE,          // take our values as-is
          0,                 // no extra data between each position
          null               // offset of first element
        );
      }
      
      /* Push each element in buffer_vertices to the vertex shader */
      ctx.glDrawArrays( GL_TRIANGLES, 0, 3 );     
      ctx.glDisableVertexAttribArray( vertexPos );
      ctx.glDisableVertexAttribArray( colorPos );
    };  
  
  wnd.show();
  wnd.listen();
  ctx.destroy( program );
  ctx.glDeleteBuffers( 1, &vertexBO );
  ctx.glDeleteBuffers( 1, &colorBO );
}

