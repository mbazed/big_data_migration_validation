import 'package:flutter/material.dart';

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
          child: ConnectionLinesWidget(
            leftItems: ['looooooong Name', 'Item B', 'Item C', 'Item D'],
            rightItems: ['Item 1', 'Item 2', 'Long Item'],
            connections: [
              ['Item B', 'Item 1'],
              ['Item C', 'Item 2'],
              ['Item D', 'Item 1'],
            ],
            widgetWidth: 500.0,
            widgetHeight: 300.0,
          ),
        ),
      ),
    );
  }
}

class ConnectionLinesWidget extends StatelessWidget {
  final List<String> leftItems;
  final List<String> rightItems;
  final List<List<String>> connections;
  final double widgetWidth;
  final double widgetHeight;

  ConnectionLinesWidget({
    required this.leftItems,
    required this.rightItems,
    required this.connections,
    required this.widgetWidth,
    required this.widgetHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConnectionLinesPainter(
        leftItems,
        rightItems,
        leftItems.length,
        rightItems.length,
        connections,
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: widgetWidth,
        height: widgetHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: leftItems
                  .map((item) => Container(
                        width: MediaQuery.of(context).size.width *
                            .10, // Adjust the width as needed

                        margin: const EdgeInsets.only(right: 50.0),
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            print('Pressed $item');
                          },
                          child: Text(item),
                        ),
                      ))
                  .toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rightItems
                  .map((item) => SizedBox(
                        width: MediaQuery.of(context).size.width *
                            .14, // Adjust the width as needed
                        child: Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: item,
                                labelStyle: TextStyle(
                                    fontSize:
                                        14.0), // Set the label (hint) text size
                              ),
                              style: TextStyle(
                                  fontSize: 14.0), // Set the input text size
                            )),
                      ))
                  .toList(),
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: rightItems
            //       .map((item) => Container(
            //             width: 150.0,
            //             color: Colors.yellow,
            //             margin: const EdgeInsets.only(left: 50.0),
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(item),
            //           ))
            //       .toList(),
            // ),
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

        // Assume rightY is initialized to a default value outside the loop
        double rightY = (j + 1) * rightSpacing;

        for (var connection in connections) {
          if (connection[0] == leftitem && connection[1] == rightitem) {
            // Update rightY if a connection is found

            drawConnectionPath(canvas, leftX, leftY, rightX, rightY, linePaint);
          }
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
