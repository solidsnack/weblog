import "dart:html";
import "dart:async";
import "package:web_ui/watcher.dart" as watchers;
import "package:web_ui/web_ui.dart";
import "package:intl/intl.dart";
import "package:js/js.dart" as js;


/**
 * Learn about the Web UI package by visiting
 * http://www.dartlang.org/articles/dart-web-components/.
 */
void main() {
  // Enable this to use Shadow DOM in the browser.
  //useShadowDom = true;
  theTime();
  getLogs();
  Duration d = new Duration(milliseconds: 500);
  Timer.run(() {
    js.scoped(() { js.context.logsTableStyling(); });
  });
}

abstract class Cube {
  String get tStart;
  String get tEnd;
  String get hostSuffix;
  String get appPrefix;
  List<List<String>> stream();
}

class SyslogCube implements Cube {
  final String tStart;
  final String tEnd;
  final String hostSuffix;
  final String appPrefix;
  final String logs;
  SyslogCube( this.tStart,     this.tEnd,
              this.hostSuffix, this.appPrefix, this.logs );
  List<List<String>> stream() {
    List<String> lines = logs.split("\n");
    lines.sort();
    return lines.map((s) => SyslogCube.split(s))
                .where((l) => l.length > 0)
                .toList();
  }
  static List<String> split(String s) {
    List<String> words = s.split(' ');
    List<String> fields = words.take(4).toList();
    if (words.length > 4) {
      List<String> fields = [ words[0].substring(0, 26),
                              words[1], words[3], words[2] ];
      String message = words.skip(4).join(' ');
      fields.add(message);
      return fields;
    } else {
      return [];
    }
  }
}

class Endpoint {
  final String url;
  Endpoint(this.url);
  Future<Cube> search([String tStart, String tEnd,
                       String hostSuffix, String appPrefix]) {
  }
}


List<String> columns = ['timestamp', 'host', 'pri', 'tag', 'message'];
List<List<String>> logs = [];
Cube cube;
String getLogs() {
  HttpRequest req = new HttpRequest();
  req.open('GET', 'syslog', async: false);
  req.send();
  String raw = req.responseText;
  cube = new SyslogCube('0001-01-01', '9999-01-01', '', '', raw);
  logs = cube.stream();
}


theTime() {
  updated = timestamp();
  tick();
  new Timer.periodic(new Duration(milliseconds:100), (_) => tick());
}
String now;
String updated;

String timestamp() {
  DateTime t = new DateTime.now();
  return secondsFormat.format(t.toUtc());
}

tick() {
  String next = timestamp();
  if (now != next) {
    now = next;
    watchers.dispatch();
  }
}
final secondsFormat = new Intl().date("yyyy-MM-ddTHH:mm:ss");
