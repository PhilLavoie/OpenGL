module glbasics;

import nucleus.gui.glwindow;

import std.stdio;
import core.runtime;

import nucleus.gl.glcolors;

void main( string[] args ) {
  auto wnd = new GLWindow( "OpenGL Basics" );
  auto ctx = wnd.glContext();
  ctx.loadAll();

  GLint noExt = -1;
  ctx.glGetIntegerv( GL_NUM_EXTENSIONS, &noExt );    
  writeln( "Number of extensions: ", noExt );  
  
  GLint major, minor;
  ctx.glGetIntegerv( GL_MAJOR_VERSION, &major );
  ctx.glGetIntegerv( GL_MINOR_VERSION, &minor );
  writeln( "Version ", major, ".", minor );
  
  auto colors = GLColors();
  wnd.onResize = ( size_t width, size_t height ) { ctx.glViewport( 0, 0, width, height ); };
  wnd.onRender = 
    () { 
      auto c = colors.front;
      colors.popFront();
      ctx.glClearColor( c.red, c.green, c.blue, c.alpha ); 
      ctx.glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
      printErrors( ctx );
    };  
  
  wnd.show();
  wnd.listen();
}

struct GLColors {
  size_t _index = 0;
  @property bool empty() { return false; }
  @property GLColor front() { return composites[ _index ]; }
  void popFront() { if( _index == composites.length - 1 ) { _index = 0; } else { ++_index; } }
}

void printErrors( ref GLContext ctx ) {
  foreach( err; GLErrors( ctx ) ) {
    writeln( err.glError );
  }
}

string glError( GLenum errCode ) {  
  switch( errCode ) {
  case GL_NO_ERROR:
    return "no error";
  case GL_INVALID_VALUE:
    return "invalid value";
  case GL_INVALID_ENUM:
    return "invalid enum";
  case GL_INVALID_OPERATION:
    return "invalid operation";
  case GL_STACK_OVERFLOW:
    return "stack overflow";
  case GL_STACK_UNDERFLOW:
    return "stack underflow";
  case GL_OUT_OF_MEMORY:
    return "out of memory";
  default:
    return "unknown error";  
  }
}

struct GLErrors {
  private GLenum _current;
  private GLContext _ctx;
public:
  this( GLContext ctx ) { _ctx = ctx; }

  @property bool empty() { 
    _current = _ctx.glGetError();
    return ( _current == GL_NO_ERROR ); 
  }
  @property GLenum front() { 
    return _current; 
  }
  void popFront() { ; }
}
