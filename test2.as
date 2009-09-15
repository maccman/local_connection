/*mtasc -version 8 -header 1:1:1 -main -swf test2.swf test2.as*/
class Test2 {
  static function main() {
    var receivingLC = new LocalConnection();
    while(true) {
      receivingLC.send("test_channel", "test_method");
    }
  }
}
