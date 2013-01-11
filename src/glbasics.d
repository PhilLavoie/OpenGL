module glbasics;

import nucleus.gui.glwindow;

import std.stdio;
import core.runtime;

void main( string[] args ) {
  auto wnd = new GLWindow( "OpenGL Basics", false );
  auto ctx = wnd.glContext();
  ctx.loadAll();

  GLint noExt = -1;
  ctx.glGetIntegerv( GL_NUM_EXTENSIONS, &noExt );    
  writeln( "Number of extensions: ", noExt );  
  foreach( err; GLErrors( ctx ) ) {
    writeln( err.glError );
  }
  GLint major, minor;
  ctx.glGetIntegerv( GL_MAJOR_VERSION, &major );
  ctx.glGetIntegerv( GL_MINOR_VERSION, &minor );
  writeln( "Version ", major, ".", minor );
  
  wnd.show();
  wnd.listen();
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
