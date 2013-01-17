module shadedtriangle;

import nucleus.gui.glwindow;
import nucleus.gl.glcolors;
import nucleus.gl.glerrors;

import std.stdio;
import File = std.file;
import std.utf;
import std.string;
import std.algorithm;


void main( string[] args ) {
  auto wnd = new GLWindow( "Shaded Triangle" );
  auto ctx = wnd.glContext();
  ctx.loadAll();  //Loads all known function pointers.
  auto program = ctx.loadShaders( "identity.vert", "identity.frag", Attribute( 0, "vertex".toStringz ), Attribute( 1, "color".toStringz ) );
  ctx.glUseProgram( program );
  printErrors( ctx );
  
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
  GLint vertexPos, colorPos;  
  vertexPos = ctx.glGetAttribLocation( program, "vertex".toStringz );
  assert( vertexPos != -1, "unable to retrieve vertex var location" );
  colorPos = ctx.glGetAttribLocation( program, "color".toStringz );
  assert( colorPos != -1, "unable to retrieve color var location" );
  
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
      
      ctx.glUseProgram( program );
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
      
      printErrors( ctx );
      writeln( "Done writing triangle" );
    };  
  
  wnd.show();
  wnd.listen();
  ctx.glDeleteProgram( program );
  ctx.glDeleteBuffers( 1, &vertexBO );
  ctx.glDeleteBuffers( 1, &colorBO );
}

struct Attribute {
  size_t index;
  immutable( char ) * name;  
}

void loadShaderSource( GLContext ctx, const char *szShaderSrc, GLuint shader )	{
  GLchar *fsStringPtr[1];

  fsStringPtr[0] = cast( GLchar * )szShaderSrc;
  ctx.glShaderSource( shader, 1, cast(const GLchar **)fsStringPtr, null );
}

//TODO: implement the use of glGetShaderLogInfo...
GLuint loadShaders( GLContext ctx, string vertex, string fragment, Attribute[] attrs ... ) {
  with( ctx ) {
    auto vertexShader = glCreateShader( GL_VERTEX_SHADER );
    auto fragmentShader = glCreateShader( GL_FRAGMENT_SHADER );
    
    auto vertexSrc = File.readText( vertex ).toStringz;
    auto fragmentSrc = File.readText( fragment ).toStringz;
    
    ctx.loadShaderSource( vertexSrc, vertexShader );
    ctx.loadShaderSource( fragmentSrc, fragmentShader );
     
    // Compile them
    glCompileShader( vertexShader );
    glCompileShader( fragmentShader );
      
    GLint testVal;  
    // Check for errors
    glGetShaderiv( vertexShader, GL_COMPILE_STATUS, &testVal);
    if( testVal == GL_FALSE ) {
        glDeleteShader( vertexShader );
        glDeleteShader( fragmentShader );
        writeln( "Compilation status of the vertex shader is negative" );
        return 0;
    }
      
    glGetShaderiv( fragmentShader, GL_COMPILE_STATUS, &testVal);
    if( testVal == GL_FALSE ) {
        glDeleteShader( vertexShader );
        glDeleteShader( fragmentShader );
        writeln( "Compilation status of the fragment shader is negative" );
        return 0;
    }
      
    // Link them - assuming it works...
    auto program = glCreateProgram();
    glAttachShader( program, vertexShader );
    glAttachShader( program, fragmentShader );

    foreach( attr; attrs ) {
      glBindAttribLocation( program, attr.index, attr.name );
    }

    glLinkProgram( program );
    
    // These are no longer needed
    glDeleteShader( vertexShader );
    glDeleteShader( fragmentShader );  
      
    // Make sure link worked too
    glGetProgramiv( program, GL_LINK_STATUS, &testVal);
    if(testVal == GL_FALSE) {
      glDeleteProgram( program );
      writeln( "Linking of program did not work" );
      return 0;
    }
    return program; 
  }  
}

