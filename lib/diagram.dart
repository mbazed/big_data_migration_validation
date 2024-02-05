import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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

  final String inputRuleString;
  final double widgetWidth;
  final double widgetHeight;

  ConnectionLinesWidget({
    required this.leftItems,
    required this.rightItems,
    required this.widgetWidth,
    required this.widgetHeight,
    required this.inputRuleString,
  });

  @override
  State<ConnectionLinesWidget> createState() => _ConnectionLinesWidgetState();
}

class _ConnectionLinesWidgetState extends State<ConnectionLinesWidget> {
  late List<TextEditingController> textControllers;
  int selectedTextFieldIndex = -1; // Initialize to an invalid index
  Map<String, String> rulesCopy = {};
  Map<String, List<String>> rulesDictionary = {};

  @override
  void initState() {
    super.initState();
    rulesDictionary = {};
    rulesCopy = {};
    rulesDictionary = createConnectionDictionary(widget.inputRuleString);
    rulesCopy = createRuleDictionary(widget.inputRuleString);
    List<List<String>> connections = [];

    rulesDictionary.forEach((key, values) {
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
            if (selectedTextFieldIndex != -1) {
              final updatedText = controllers[selectedTextFieldIndex].text +
                  '{' +
                  items[i].trim() +
                  '}';
              // Update the text in the controller without losing focus
              controllers[selectedTextFieldIndex].value =
                  controllers[selectedTextFieldIndex].value.copyWith(
                        text: updatedText,
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: updatedText.length),
                        ),
                      );
            }
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
    String inputString,
  ) {
    for (int i = 0; i < items.length; i++) {
      setState(() {
        controllers[i].text = '';
      });
    }
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
              onChanged: (value) => {},
              onEditingComplete: () => {selectedTextFieldIndex = -1},
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

    Map<String, String> rulesCopy = createRuleDictionary(inputString);

    for (int i = 0; i < items.length; i++) {
      String? ruleValue = rulesCopy[items[i].trim()];

      // Check if ruleValue is not null before assigning to controllers[i].text
      if (ruleValue != null) {
        final updatedText = ruleValue;
        // Update the text in the controller without losing focus
        controllers[i].value = controllers[i].value.copyWith(
              text: updatedText,
              selection: TextSelection.fromPosition(
                TextPosition(offset: updatedText.length),
              ),
            );
      } else {
        // Handle the case when the ruleValue is null (optional)
        // You might want to provide a default value or handle it differently.
        // print("Warning: Rule value is null for item ${items[i]}");
      }
    }
    return textFields;
  }

  @override
  Widget build(BuildContext context) {
    textControllers = List.generate(
      50,
      (index) => TextEditingController(),
    );
    setState(() {
      rulesDictionary = {};
      rulesCopy = {};
    });

    setState(() {
      rulesDictionary = createConnectionDictionary(widget.inputRuleString);
    });
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

    return CustomPaint(
      painter: ConnectionLinesPainter(
        widget.leftItems,
        widget.rightItems,
        widget.leftItems.length,
        widget.rightItems.length,
        connections,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
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
                widget.rightItems,
                textControllers,
                context,
                widget.inputRuleString,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionLinesPainter extends CustomPainter {
  final List<String> leftItems;
  final List<String> rightItems;
  final int leftItemCount;
  final int rightItemCount;
  final List<List<String>> connections;

  ConnectionLinesPainter(
    this.leftItems,
    this.rightItems,
    this.leftItemCount,
    this.rightItemCount,
    this.connections,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0;

    TextSpan textSpan = TextSpan(
      text: '>',
      style: TextStyle(
        color: Colors.green,
        fontSize: 24.0,
      ),
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    double leftSpacing = (size.height + 8) / (leftItemCount + 1);
    double rightSpacing = (size.height + 8) / (rightItemCount + 1);
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
        // if (j == 0) rightY -= 16;

        for (var connection in connections) {
          if (connection[0].trim() == rightitem.trim() &&
              connection[1].trim() == leftitem.trim()) {
            textPainter.paint(canvas, Offset(rightX - 4, rightY - 14));

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

    // canvas.drawLine(Offset(quarterX, startY), Offset(middleX, middleY), paint);
    // canvas.drawLine(
    //     Offset(middleX, middleY), Offset(middleX + oneQuarter, endY), paint);

    canvas.drawLine(Offset(middleX + (oneQuarter / 2) * 3, endY),
        Offset(endX, endY), paint);

    curvedLine(canvas, quarterX - (oneQuarter / 2), startY, middleX, middleY,
        middleX - (oneQuarter / 2), startY, paint);
    curvedLine(canvas, middleX, middleY, middleX + (oneQuarter / 2) * 3, endY,
        middleX + (oneQuarter / 2), endY, paint);
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

// non-ui functions
Map<String, List<String>> createConnectionDictionary(String inputString) {
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

Map<String, String> createRuleDictionary(String inputString) {
  Map<String, String> dictionary = {};

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
      dictionary[key] = value;
    }
  }
  return dictionary;
}
