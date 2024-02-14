import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class HighlightTextFormatter extends TextInputFormatter {
  final List<String> keywords;
  final Color highlightColor;
  final BuildContext context;

  HighlightTextFormatter(
      {required this.keywords,
      required this.highlightColor,
      required this.context});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;

    List<TextSpan> textSpans = [];

    int start = 0;
    int end = 0;

    while (end < newText.length) {
      for (String keyword in keywords) {
        if (newText.startsWith(keyword, end)) {
          // Add the text before the keyword
          textSpans.add(
            TextSpan(
              text: newText.substring(start, end),
              style: DefaultTextStyle.of(context).style,
            ),
          );

          // Add the keyword with the common color
          textSpans.add(
            TextSpan(
              text: newText.substring(end, end + keyword.length),
              style: TextStyle(color: highlightColor),
            ),
          );

          // Update start and end indices
          start = end + keyword.length;
          end = start;
          break;
        }
      }
      end++;
    }

    // Add the remaining text
    textSpans.add(
      TextSpan(
        text: newText.substring(start),
        style: DefaultTextStyle.of(context).style,
      ),
    );

    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextField(
            inputFormatters: [
              HighlightTextFormatter(
                keywords: ['Flutter', 'Dart', 'Keyword3'],
                highlightColor: Colors.blue,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
