import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Connection Lines Example'),
        ),
        body: Center(
          child: Text(""),
        ),
      ),
    );
  }
}

class ConnectionLinesWidget extends StatefulWidget {
  final List<String> leftItems;
  final List<String> rightItems;

  final Map<String, List<String>> rulesDictionary;
  final double widgetWidth;
  final double widgetHeight;

  ConnectionLinesWidget({
    required this.leftItems,
    required this.rightItems,
    required this.widgetWidth,
    required this.widgetHeight,
    required this.rulesDictionary,
  });

  @override
  State<ConnectionLinesWidget> createState() => _ConnectionLinesWidgetState();
}

class _ConnectionLinesWidgetState extends State<ConnectionLinesWidget> {
  final GlobalKey _key = GlobalKey();
  late List<TextEditingController> textControllers;
  int selectedTextFieldIndex = -1; // Initialize to an invalid index
  final List<Offset> dynamicPositions = [];
  @override
  void initState() {
    super.initState();
    textControllers = List.generate(
      50,
      (index) => TextEditingController(),
    );
    List<List<String>> connections = [];

    widget.rulesDictionary.forEach((key, values) {
      List<String> connection = [key, ...values];
      connections.add(connection);
    });
  }

  List<Container> generateTextButtons(
    List<String> items,
    BuildContext context,
    List<TextEditingController> controllers,
  ) {
    List<Container> buttons = [];

    for (int i = 0; i < items.length; i++) {
      buttons.add(Container(
        width: MediaQuery.of(context).size.width * .10,
        margin: const EdgeInsets.only(right: 50.0),
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: () {
            setState(() {
              if (selectedTextFieldIndex != -1) {
                controllers[selectedTextFieldIndex].text +=
                    '{' + items[i].trim() + '}';
              }
            });
          },
          child: Text(items[i]),
        ),
      ));
    }
    return buttons;
  }

  List<SizedBox> generateTextFields(
    List<String> items,
    List<TextEditingController> controllers,
    BuildContext context,
  ) {
    List<SizedBox> textFields = [];

    for (int i = 0; i < items.length; i++) {
      textFields.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * .14,
          child: Container(
            margin: const EdgeInsets.only(left: 10.0),
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controllers[i],
              onTap: () {
                setState(() {
                  selectedTextFieldIndex = i;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: items[i],
                labelStyle: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      );
    }
    return textFields;
  }

  void getPositions(Size size, int rightItemCount) {
    setState(() {
      double rightX = size.width / 100 * 70;
      double rightSpacing = size.height / (rightItemCount + 1);
      for (int j = 0; j < rightItemCount; j++) {
        double rightY = (j + 1) * rightSpacing;
        dynamicPositions.add(Offset(rightX, rightY));
      }
    });

    print(dynamicPositions);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConnectionLinesPainter(
        getPositions,
        widget.leftItems,
        widget.rightItems,
        widget.leftItems.length,
        widget.rightItems.length,
        widget.rulesDictionary,
      ),
      child: Stack(
        children: [
          ListView.builder(
            itemCount: dynamicPositions.length,
            itemBuilder: (context, index) {
              Offset position = dynamicPositions[index];
              return Positioned(
                top: position.dy,
                left: position.dx,
                child: Text(
                  '>',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: widget.widgetWidth,
            height: widget.widgetHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: generateTextButtons(
                      widget.leftItems, context, textControllers),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: generateTextFields(
                      widget.rightItems, textControllers, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectionLinesPainter extends CustomPainter {
  final Function(Size, int) updateStateCallback;
  final List<String> leftItems;
  final List<String> rightItems;
  final int leftItemCount;
  final int rightItemCount;
  final Map<String, List<String>> rulesDictionary;

  ConnectionLinesPainter(
    this.updateStateCallback,
    this.leftItems,
    this.rightItems,
    this.leftItemCount,
    this.rightItemCount,
    this.rulesDictionary,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0;
    // updateStateCallback(size, rightItemCount);
    List<List<String>> connections = [];
    rulesDictionary.forEach((key, values) {
      if (values.length > 1) {
        // If there are multiple values for a key, create separate lists
        for (var value in values) {
          List<String> connection = [key, value];
          connections.add(connection);
        }
      } else {
        // If there's only one value for a key, create a single list
        List<String> connection = [key, ...values];
        connections.add(connection);
      }
    });

    print(connections);
    double leftSpacing = size.height / (leftItemCount + 1);
    double rightSpacing = size.height / (rightItemCount + 1);
    double leftX = size.width / 100 * 23;
    double rightX = size.width / 100 * 70;
    double rleftX = size.width / 5 * 3;
    double rrightX = size.width / 5 * 4;

    for (int i = 0; i < leftItemCount; i++) {
      double leftY = (i + 1) * leftSpacing;

      for (int j = 0; j < rightItemCount; j++) {
        var leftitem = leftItems[i];
        var rightitem = rightItems[j];

        double rightY = (j + 1) * rightSpacing;

        for (var connection in connections) {
          if (connection[0].trim() == rightitem.trim() &&
              connection[1].trim() == leftitem.trim()) {
            drawConnectionPath(canvas, leftX, leftY, rightX, rightY, linePaint);
          } else {}
        }
      }
    }
  }

  void drawConnectionPath(
    Canvas canvas,
    double startX,
    double startY,
    double endX,
    double endY,
    Paint paint,
  ) {
    double middleX = (startX + endX) / 2;
    double quarterX = (startX + middleX) / 2;
    double middleY = (startY + endY) / 2;
    double quarterY = (startY + middleY) / 2;

    double oneQuarter = (endX - startX) / 4;
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(startX, startY),
        Offset(quarterX - (oneQuarter / 2), startY), paint);
    curvedLine(canvas, quarterX - (oneQuarter / 2), startY, middleX, middleY,
        middleX - (oneQuarter / 2), startY, paint);
    curvedLine(canvas, middleX, middleY, middleX + (oneQuarter / 2) * 3, endY,
        middleX + (oneQuarter / 2), endY, paint);
    canvas.drawLine(Offset(middleX + (oneQuarter / 2) * 3, endY),
        Offset(endX, endY), paint);
  }

  void curvedLine(Canvas canvas, double startX, double startY, double endX,
      double endY, double controlPointX, double controlPointY, Paint paint) {
    Path path = Path();
    path.moveTo(startX, startY);

    path.quadraticBezierTo(controlPointX, controlPointY, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Map<String, List<String>> createDictionary(String inputString) {
  Map<String, List<String>> dictionary = {};

  List<String> lines = inputString.split('\n');

  for (String line in lines) {
    line = line.trim();

    if (line.isEmpty) {
      continue; // Skip empty lines
    }

    List<String> parts = line.split(':');
    if (parts.length == 2) {
      String key = parts[0].trim();
      String value = parts[1].trim();

      if (value.contains('{') && value.contains('}')) {
        List<String> columns = RegExp(r'{(.*?)}')
            .allMatches(value)
            .map((m) => m.group(1)!)
            .toList();

        dictionary[key] = columns;
      }
    }
  }

  return dictionary;
}
