/*mtasc -version 8 -header 1:1:1 -main -swf test.swf test.as*/
class Test {
  static function main() {
    var receivingLC = new LocalConnection();
    receivingLC.testMethod = function(){
      trace("Tested");
    }
    receivingLC.connect("test_channel");
  }
}