part of library;

class DifferentFactoryException{
  final String msg;
  
  DifferentFactoryException([String this.msg]);
  
  String toString() => msg != null ? "DifferentFactoryException:$msg" : "DifferentFactoryException";
  
}