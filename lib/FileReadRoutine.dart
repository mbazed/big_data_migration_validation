import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';

String readFile(FilePickerResult? result) {
  if (result == null || result.files.isEmpty) {
    return 'No file selected';
  }

  // Read file content
  List<int> bytes = result.files.single.bytes!;
  String fileExtension = result.files.single.extension!.toLowerCase();

  if (fileExtension == 'csv') {
    return readCsv(bytes);
  } else if (fileExtension == 'xlsx') {
    // return readXlsxToCsv(bytes) as String;
    convertXlsxToCsv(result);
    return 'Conversion complete. CSV file saved at: output.csv';
  } else {
    return 'Unsupported file type';
  }
}

String readXlsxToCsv(List<int> bytes) {
  // Read XLSX file
  var excel = Excel.decodeBytes(bytes);

  // Get the first sheet from the workbook
  var sheet = excel.tables.keys.first;

  // Extract data from the sheet
  List<List<dynamic>> data = [];
  for (var row in excel.tables[sheet]!.rows) {
    data.add(row);
  }

  // Convert data to CSV format
  String csvData = const ListToCsvConverter().convert(data);

  return csvData;
}

String readCsv(List<int> bytes) {
  // Remove BOM if present
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    bytes = bytes.sublist(3);
  }

  String data = String.fromCharCodes(bytes);
  return data;
}

Future<void> convertXlsxToCsv(FilePickerResult? result) async {
  // Check if a file was selected
  if (result != null) {
    // Read XLSX file
    List<int> bytes = result.files.single.bytes!;
    var excel = Excel.decodeBytes(bytes);

    // Get the first sheet from the workbook
    var sheet = excel.tables.keys.first;

    // Extract data from the sheet
    List<List<dynamic>> data = [];
    for (var row in excel.tables[sheet]!.rows) {
      data.add(row);
    }

    // Convert data to CSV format
    String csvData = const ListToCsvConverter().convert(data);

    // Save CSV data to a file
    File csvFile = File('output.csv');
    await csvFile.writeAsString(csvData);

    print('Conversion complete. CSV file saved at: ${csvFile.path}');
  } else {
    print('No file selected');
  }
}
