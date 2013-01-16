module shadedtriangle;

import nucleus.gui.glwindow;
import nucleus.gl.glcolors;

import std.stdio;
import File = std.file;
import std.utf;
import std.string;

void main( string[] args ) {
  auto wnd = new GLWindow( "Shaded Triangle" );
  auto ctx = wnd.glContext();
  ctx.loadAll();  //Loads all known function pointers.
  ctx.loadShaders( "identity.vert", "identity.frag", Attribute( 0, "vertex".toStringz ), Attribute( 1, "color".toStringz ) );
  
  wnd.onResize = ( size_t width, size_t height ) { ctx.glViewport( 0, 0, width, height ); };
  wnd.onRender = 
    () { 
      //Paints the background black.
      ctx.glClearColor( black.red, black.green, black.blue, black.alpha ); 
      ctx.glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
      //TODO: add swap buffers to the context.
    };  
  
  wnd.show();
  wnd.listen();
}

struct Attribute {
  size_t index;
  immutable( char ) * name;  
}

void loadShaderSource( GLContext ctx, const char *szShaderSrc, GLuint shader)
	{
    GLchar *fsStringPtr[1];

    fsStringPtr[0] = cast( GLchar * )szShaderSrc;
    ctx.glShaderSource( shader, 1, cast(const GLchar **)fsStringPtr, null );
	}

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
