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
  auto ctx = wnd.renderingContext;
  ctx.loadAll();  //Loads all known function pointers.
  
  ProgramManager pm = ProgramManager( ctx );
  pm.buildAll();
  scope( exit ) { pm.releaseAll(); }
  
  pm.use!( StockProgram.gradient );
    
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
       
  printErrors( ctx );
  
  wnd.onResize = 
    ( size_t width, size_t height ) { 
      ctx.glViewport( 0, 0, width, height );       
    };
  wnd.onRender = 
    () { 
      with( ctx ) {
        glClearColor( black.red, black.green, black.blue, 0 ); 
        glClear( GL_COLOR_BUFFER_BIT  );  
        
        glEnableVertexAttribArray( vertexPos );
        glBindBuffer( GL_ARRAY_BUFFER, vertexBO );      
        glVertexAttribPointer(
          vertexPos,        // attribute
          4,                // number of elements per vertex
          GL_FLOAT,         // the type of each element
          GL_FALSE,         // take our values as-is
          0,                // no extra data between each position
          null              // Offset of the first element.
        );
       
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
        
        /* Push each element in buffer_vertices to the vertex shader */
        glDrawArrays( GL_TRIANGLES, 0, 3 );     
        glDisableVertexAttribArray( vertexPos );
        glDisableVertexAttribArray( colorPos );
      }
    };  
  
  wnd.show();
  wnd.listen();
  ctx.glDeleteBuffers( 1, &vertexBO );
  ctx.glDeleteBuffers( 1, &colorBO );
}

