import 'dart:async';

import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'diagram.dart';
import 'package:data_validation/widgets/widgetStyle.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:searchfield/searchfield.dart'; // Import kIsWeb from flutter/foundation

class DesktopDataValidatorPage extends StatefulWidget {
  const DesktopDataValidatorPage({Key? key}) : super(key: key);

  @override
  State<DesktopDataValidatorPage> createState() {
    return _DesktopDataValidatorPageState();
  }
}

class _DesktopDataValidatorPageState extends State<DesktopDataValidatorPage> {
  String sourceselectedMode = 'File Mode';
  String targetselectedMode = 'File Mode';
  String source = '';
  String target = '';
  String message = '';
  String sourceData = '';
  String targetData = '';

  String firstButtonText = 'Upload';
  // String firstButtonText = 'Validate Data';

  bool multiKey = false;
  String requestID = "";
  bool isLoading = false;
  bool showerrbtn = true;

  int samplePercentage = 10;

  FilePickerResult? targetResult;
  FilePickerResult? sourceResult;

  List<String> sourceColumnList = [];
  List<String> targetColumnList = [];
  List<List<String>> connections = [];

  final pkUrl = Uri.parse('http://localhost:4564/findKeys');
  final dbmodeurl = Uri.parse('http://localhost:4564/getfromdb');
  final mapUrl = Uri.parse('http://localhost:4564/mapData');
  final validateUrl = Uri.parse('http://localhost:4564/validateData');
  final uploadUrl = Uri.parse('http://localhost:4564/upload');
  final uploadDataUrl = Uri.parse('http://localhost:4564/getdata');
  final downloadUrl = Uri.parse('http://localhost:4564/download');
  bool showDiagram = false;
  bool showErrors = false;
  var srcpk = "";
  var trgpk = "";
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _sourceUserController = TextEditingController();
  final TextEditingController _sourcePassController = TextEditingController();
  final TextEditingController _sourceHostController = TextEditingController();
  final TextEditingController _sourceDBNameController = TextEditingController();
  final TextEditingController _sourceTableController = TextEditingController();
  final TextEditingController _targetUserController = TextEditingController();
  final TextEditingController _targetPassController = TextEditingController();
  final TextEditingController _targetHostController = TextEditingController();
  final TextEditingController _targetDBNameController = TextEditingController();
  final TextEditingController _targetTableController = TextEditingController();
  final TextEditingController _samplePercentageController =
      TextEditingController();
  TextEditingController _keyController1 = TextEditingController();
  TextEditingController _keyController2 = TextEditingController();
  List<String> srcCandidateKeys = [];
  List<String> trgCandidateKeys = [];

  List<String> responseLines = [];
  int lineNumber = 0;
  String inputRuleString = '';
  String inputRuleString2 = '';

  String fileName = 'No file selected';
  List<bool> isExpandedList = [];

  var missingRows = [];
  var outputString = "";
  var nullErrorString = "";
  var mismatchedDataTypes = [];
  var missingRowsCount = 0;
  var mismatchedCount = 0;
  var nullErrorCount = 0;
  var corruptedCount = 0;
  var rowsChecked = 0;

  bool uploadCompleted = false;
  bool findPrimaryKeysCompleted = false;
  bool mapDataCompleted = false;
  bool validateDataCompleted = false;
  bool downloadReportCompleted = false;

  @override
  void initState() {
    super.initState();

    // Adding listeners to controllers
    _sourceUserController.addListener(_handleTextChange);
    _sourcePassController.addListener(_handleTextChange);
    _sourceHostController.addListener(_handleTextChange);
    _sourceDBNameController.addListener(_handleTextChange);
    _sourceTableController.addListener(_handleTextChange);
    _targetUserController.addListener(_handleTextChange);
    _targetPassController.addListener(_handleTextChange);
    _targetHostController.addListener(_handleTextChange);
    _targetDBNameController.addListener(_handleTextChange);
    _targetTableController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {
      firstButtonText = 'Upload';
    });
  }

  void handleTap() async {
    setState(() {
      firstButtonText = 'Upload';
      mapDataCompleted = false;
      _mapDataProgress = 0.0;
      validateDataCompleted = false;
      showDiagram = false;
      showErrors = false;
      multiKey = false;
      _resultController.text = '';
      _keyController1.text = '';
      _keyController2.text = '';
      _sourceController.text = '';
      _targetController.text = '';
      srcpk = "";
      trgpk = "";
      sourceColumnList = [];
      targetColumnList = [];
      connections = [];
      responseLines = [];
      lineNumber = 0;
      inputRuleString = '';
      missingRows = [];
      outputString = "";
      nullErrorString = "";
      downloadReportCompleted = false;
      isExpandedList = [];
    });

    if (findPrimaryKeysCompleted) {
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        _findPrimaryKeysProgress = 0.0;
      });
    }

    if (uploadCompleted) {
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        findPrimaryKeysCompleted = false;
        _uploadProgress = 0.0;
      });
    }

    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      uploadCompleted = false;
    });
  }

  void clearState() {
    setState(() {
      sourceselectedMode = 'File Mode';
      targetselectedMode = 'File Mode';
      source = '';
      target = '';
      message = '';
      sourceData = '';
      targetData = '';
      firstButtonText = 'Upload';
      multiKey = false;
      requestID = "";
      showerrbtn = true;
      targetResult = null;
      sourceResult = null;
      sourceColumnList = [];
      targetColumnList = [];
      connections = [];
      _sourceController.clear();
      _targetController.clear();
      _resultController.clear();
      _sourceUserController.clear();
      _sourcePassController.clear();
      _sourceHostController.clear();
      _sourceDBNameController.clear();
      _sourceTableController.clear();
      _targetUserController.clear();
      _targetPassController.clear();
      _targetHostController.clear();
      _targetDBNameController.clear();
      _targetTableController.clear();
      _keyController1.clear();
      _keyController2.clear();
      // src2dKeys = [];
      // trg2dKeys = [];
      srcCandidateKeys = [];
      trgCandidateKeys = [];
      responseLines = [];
      lineNumber = 0;
      inputRuleString = '';
      fileName = 'No file selected';
    });
  }

// Define the inline function to update the inputRuleString
  void updateInputRuleString(String item, String value) {
    Map<String, String> rules = createRuleDictionary(inputRuleString);
    rules[item.trim()] = value;

    // Update the inputRuleString by joining the rules back
    setState(() {
      inputRuleString = rules.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');
    });
  }

  Future<void> handleFileSelection(FilePickerResult? result,
      TextEditingController controller, String title) async {
    if (result != null) {
      setState(() {
        title == 'Source' ? sourceResult = result : targetResult = result;
        firstButtonText = 'Upload';
        fileName = result.files.single.name;
        controller.text = fileName;
        _resultController.text =
            '$title selected: $fileName\n'; // Append to the existing text
      });
    } else {
      setState(() {
        fileName = 'No file selected';
        controller.text = fileName;
        _resultController.text =
            '$title: $fileName\n'; // Append to the existing text
      });
    }
  }

  Future<void> handleMapData() async {
    if (multiKey) {
      srcpk = _keyController1.text;
      trgpk = _keyController2.text;
    }
    setState(() {
      inputRuleString = "";
    });

    try {
      final responseMap = await http.post(
        mapUrl,
        body: {
          'sourcePk': srcpk,
          'targetPk': trgpk,
          'request_id': requestID,
        },
      );

      if (responseMap.statusCode == 200) {
        print('[+] Mapping Response Received ');
        showDiagram = true;

        final Map<String, dynamic> data = jsonDecode(responseMap.body);

        var mapingDoc = data['MapingDoc'].toString();
        var mapingStatus = data['message'].toString();

        // connections = List<List<String>>.from(
        //   data['connections']
        //       .map((dynamic innerList) => List<String>.from(innerList)),
        // );

        inputRuleString = data['MapingDoc'].toString();
        _resultController.text = '$mapingStatus';
        setState(() {
          if (mapingStatus[1] == '+') {
            firstButtonText = 'Validate Data';
            mapDataCompleted = true;
            _updateProgress();
          } else if (mapingStatus[1] == '-') firstButtonText = 'Map Data';
        });
      } else {
        print('[-] Mapping failed: ${responseMap.statusCode}');
      }
    } catch (e) {
      print('[!] Error during mapping: $e');
    }
  }

  Future<void> handleValidateData() async {
    try {
      final responseValidation = await http.post(
        validateUrl,
        body: {
          'request_id': requestID,
          'mappingDoc': inputRuleString,
          'samplePercentage': samplePercentage.toString(),
        },
      );

      if (responseValidation.statusCode == 200) {
        var responseData = responseValidation.body;
        var data = jsonDecode(responseData); // Parse JSON string
        var validationDoc = data['validationDoc'];
        var validationStatus = data['message'].toString();
        print('[+] Validation successful!  \n' + validationStatus);
        _resultController.text = '[+] Validation successful';

        var parsedValidationDoc = jsonDecode(validationDoc);

        missingRows = parsedValidationDoc['missingRows'] ?? [];
        outputString = parsedValidationDoc['corruptedData'] ?? "";
        nullErrorString = parsedValidationDoc['nullErrorString']
            .toString()
            .replaceAll(",", "");
        mismatchedDataTypes = parsedValidationDoc['mismatchedDataTypes'] ?? [];
        missingRowsCount = parsedValidationDoc['missingRowsCount'];
        mismatchedCount = parsedValidationDoc['mismatchedCount'];
        nullErrorCount = parsedValidationDoc['nullErrorCount'];
        corruptedCount = parsedValidationDoc['corruptedCount'];
        rowsChecked = parsedValidationDoc['rowsChecked'];

        responseLines = validationDoc.toString().split('\n');

        setState(() {
          showDiagram = false;
          showErrors = true;
          validateDataCompleted = true;
        });
      } else {
        print('[-] Validation failed: ${responseValidation.statusCode}');
        _resultController.text = '[-] Validation failed';
      }
    } catch (e) {
      print('[!] Error during validation: $e');
    }
  }

  Future<void> handleUpload() async {
    setState(() {
      inputRuleString = "";
      multiKey = false;
      showDiagram = false;
      showErrors = false;
      showerrbtn = false;
    });
    var request;
    request = http.MultipartRequest('POST', uploadDataUrl);
    showDiagram = false;
    var requestBody = {
      'source_type': sourceselectedMode,
      'target_type': targetselectedMode,
    };

    if (sourceselectedMode == 'File Mode') {
      //file mode source
      try {
        if (sourceResult != null) {
          // Add source file to request
          if (kIsWeb) {
            request.files.add(http.MultipartFile.fromBytes(
              'sourceFile',
              sourceResult!.files.single.bytes!,
              filename: sourceResult!.files.single.name,
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              'sourceFile',
              sourceResult!.files.single.path!,
            ));
          }
        } else {
          _resultController.text = '[-]Source File not selected\n';
          print('[!] Source result is null');
          // Handle the case when either sourceResult or targetResult is null
          return;
        }
      } catch (e) {
        print('[!] Error during Source File Upload: $e');
      }
    } else {
      //db mode source
      try {
        if (
            // _sourceUserController.text != "" &&
            //   _sourcePassController.text != "" &&
            _sourceHostController.text != "" &&
                _sourceDBNameController.text != "" &&
                _sourceTableController.text != "") {
          requestBody['source_hostname'] = _sourceHostController.text;
          // requestBody['source_username'] = _sourceUserController.text;
          requestBody['source_database'] = _sourceDBNameController.text;
          // requestBody['source_password'] = _sourcePassController.text;
          requestBody['source_table'] = _sourceTableController.text;
        } else {
          _resultController.text = '[-]Please fill all the fields!\n';
          return;
        }
      } catch (e) {
        print('[!] Error during Source Database upload: $e');
      }
    }

    if (targetselectedMode == 'File Mode') {
      //file mode target
      try {
        if (targetResult != null) {
          // Add target file to request
          if (kIsWeb) {
            request.files.add(http.MultipartFile.fromBytes(
              'targetFile',
              targetResult!.files.single.bytes!,
              filename: targetResult!.files.single.name,
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              'targetFile',
              targetResult!.files.single.path!,
            ));
          }
        } else {
          _resultController.text = '[-]Target File not selected';
          print('[!] Target result is null');
          // Handle the case when either sourceResult or targetResult is null
          return;
        }
      } catch (e) {
        print('[!] Error during Target File Upload: $e');
      }
    } else {
      //db mode target
      try {
        if (
            // _targetUserController.text != "" &&
            //   _targetPassController.text != "" &&
            _targetHostController.text != "" &&
                _targetDBNameController.text != "" &&
                _targetTableController.text != "") {
          requestBody['target_hostname'] = _targetHostController.text;
          // requestBody['target_username'] = _targetUserController.text;
          requestBody['target_database'] = _targetDBNameController.text;
          // requestBody['target_password'] = _targetPassController.text;
          requestBody['target_table'] = _targetTableController.text;
        } else {
          _resultController.text = '[-]Please fill all the fields!\n';
          return;
        }
      } catch (e) {
        print('[!] Error during target Database upload: $e');
      }
    }

    print(requestBody);
    request.fields.addAll(requestBody);

    try {
      var response = await request.send();
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[+] Files Uploaded successfully!');
        var responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        requestID = data['request_id'].toString();
        var message = data['message'].toString();

        print('Request ID: $requestID');
        print('Message: $message');

        setState(() {
          _resultController.text = '${message}\n';
          firstButtonText = 'Find Primary Keys';
          uploadCompleted = true;
          _updateProgress();
        });
      }
    } catch (e) {
      _resultController.text = 'Error during File Upload: $e\n';
      print('[!] Error during File Upload: $e');
      // Handle other errors
    }
  }

  Future<void> handleFindPrimaryKeys() async {
    setState(() {
      inputRuleString = "";
    });
    showDiagram = true;
    try {
      final response = await http.post(
        pkUrl,
        body: {
          'request_id': requestID,
        },
      );

      if (response.statusCode == 200) {
        print('[+] Primary Key Fetch successful! ');
        firstButtonText = 'Map Data';

        final Map<String, dynamic> data = jsonDecode(response.body);

        // Access the 'primarykey' value
        setState(() {
          findPrimaryKeysCompleted = true;
          _updateProgress();
          _keyController1.text = "";
          _keyController2.text = "";

          sourceColumnList = data['source-columns']
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .cast<String>();
          targetColumnList = data['target-columns']
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .cast<String>();
          srcCandidateKeys = data['sourcePrimaryKey'].toString().split(',');
          trgCandidateKeys = data['targetPrimaryKey'].toString().split(',');
          var srcCandidateKeysStr = data['sourcePrimaryKey'].toString();
          var trgCandidateKeysStr = data['targetPrimaryKey'].toString();
          if (srcCandidateKeys.length > 1 || trgCandidateKeys.length > 1) {
            multiKey = true;
            _keyController1.text = srcCandidateKeys[0];
            _keyController2.text = trgCandidateKeys[0];
          } else {
            _keyController1.text = srcCandidateKeys[0];
            _keyController2.text = trgCandidateKeys[0];
            multiKey = false;
          }

          srcpk = srcCandidateKeys[0];
          trgpk = trgCandidateKeys[0];
          _resultController.text =
              'Primary Key of source: ${srcCandidateKeysStr}\nPrimary Key of Target: ${trgCandidateKeysStr}\n';
        });
      } else {
        print('[-] Primary Key Fetch failed: ${response.statusCode}');
        setState(() {
          firstButtonText = 'Upload';
        });
      }
    } catch (e) {
      print('[!] Error during Primary Key Fetch: $e');
      setState(() {
        firstButtonText = 'Upload';
      });
    }
  }

  Future<void> downloadReport(String content) async {
    print("Pressed Download Report");
    try {
      html.window.localStorage['output$requestID.txt'] = content;
      print('File created successfully: ${'output$requestID.txt'}');
    } catch (e) {
      print('Error creating file: $e');
    }
  }

  void chooseHandler(String firstButtonText) {
    if (!isLoading) {
      setState(() {
        isLoading = true; // Set isLoading to true before starting the process
      });

      switch (firstButtonText) {
        case 'Upload':
          handleUpload().then((_) {
            setState(() {
              isLoading = false;
              // uploadCompleted = true;
            });
          });
          break;
        case 'Find Primary Keys':
          handleFindPrimaryKeys().then((_) {
            setState(() {
              isLoading = false;
              // findPrimaryKeysCompleted = true;
            });
          });
          break;
        case 'Map Data':
          handleMapData().then((_) {
            setState(() {
              isLoading = false;
              // mapDataCompleted = true;
            });
          });
          break;
        case 'Validate Data':
          handleValidateData().then((_) {
            setState(() {
              isLoading = false;
              // validateDataCompleted = true;
            });
          });
          break;
        case 'Download Report':
          downloadReport(_resultController.text);
          setState(() {
            downloadReportCompleted = true;
          });
          break;
        default:
      }
    }
  }

  void handleSourceModeChanged(String newMode) {
    setState(() {
      sourceselectedMode = newMode;
    });
  }

  void handleTargetModeChanged(String newMode) {
    setState(() {
      targetselectedMode = newMode;
    });
  }

  Widget buildErrorExpansionPanelList() {
    List<MapEntry<String, List<String>>> nonEmptyCategories = [];
    final Map<String, List<String>> categorizedErrors = {
      "Missing Rows Errors": missingRows.isNotEmpty
          ? missingRows.map((row) => row.toString()).toList()
          : [],
      "Null String Errors":
          nullErrorString.isNotEmpty ? [nullErrorString.toString()] : [],
      "Mismatched Data types": missingRows.isNotEmpty
          ? missingRows.map((row) => row.toString()).toList()
          : [],
      "Other Errors": outputString.isNotEmpty ? [outputString.toString()] : [],
    };

    // Filter out empty categories
    nonEmptyCategories = categorizedErrors.entries.toList();

    return ExpansionPanelList(
      expandIconColor: Colors.black87,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          isExpandedList[index] = !isExpandedList[index];
        });
      },
      children: nonEmptyCategories.map<ExpansionPanel>((entry) {
        final category = entry.key;
        final errors = entry.value.cast<String>();
        final int totalCountForCategory = _getTotalCountForCategory(category);
        final double percentage;
        totalCountForCategory > 0
            ? percentage = totalCountForCategory * 100.00 / rowsChecked
            : percentage = 0;

        if (isExpandedList.isEmpty) {
          isExpandedList = List<bool>.filled(nonEmptyCategories.length, false);
        }
        final bool isExpansionEnabled = totalCountForCategory > 0;

        return ExpansionPanel(
          backgroundColor: Colors.grey[350],
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
              ),
              tileColor: isExpansionEnabled
                  ? isExpandedList[nonEmptyCategories.indexOf(entry)]
                      ? Colors.red.shade600
                      : Colors.red.shade900
                  : Colors.green,
              textColor:
                  isExpansionEnabled ? Colors.red.shade100 : Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category),
                  if (category != 'Other Errors') Text('$percentage %')
                ],
              ),
            );
          },
          body: Column(
            children: errors.take(1000).map((error) {
              return SizedBox(
                width: double.infinity,
                child: ListTile(
                  textColor: Colors.red.shade900,
                  tileColor: Colors.grey.shade200,
                  title: SingleChildScrollView(
                    child: Text(
                        error.replaceAll(">> ", "\n").replaceAll("\\n", "\n")),
                  ),
                ),
              );
            }).toList(),
          ),
          isExpanded: isExpansionEnabled &&
              isExpandedList[nonEmptyCategories.indexOf(entry)],
        );
      }).toList(),
    );
  }

  int _getTotalCountForCategory(String category) {
    switch (category) {
      case "Missing Rows Errors":
        return missingRowsCount;
      case "Other Errors":
        return corruptedCount;
      case "Null String Errors":
        return nullErrorCount;
      case "Mismatched Data types":
        return mismatchedCount;
      default:
        return 0;
    }
  }

  double _uploadProgress = 0.0;
  double _findPrimaryKeysProgress = 0.0;
  double _mapDataProgress = 0.0;

  void _updateProgress() {
    setState(() {
      if (_uploadProgress == 0.0) {
        _uploadProgress = firstButtonText == "Find Primary Keys" ? 1.0 : 0.0;
      }
      if (_findPrimaryKeysProgress == 0.0) {
        _findPrimaryKeysProgress = firstButtonText == "Map Data" ? 1.0 : 0.0;
      }
      if (_mapDataProgress == 0.0) {
        _mapDataProgress = firstButtonText == "Validate Data" ? 1.0 : 0.0;
      } // Update other progress indicators as needed
    });
  }

  Widget buildProgressIndicator(double progress, double containerWidth) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.0815,
      // padding: EdgeInsets.only(left: containerWidth),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        tween: Tween<double>(
          begin: 0,
          end: progress,
        ),
        builder: (context, value, _) => Padding(
          padding: const EdgeInsets.all(5),
          child: LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.grey,
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A4F39)),
          ),
        ),
      ),
    );
  }

  Widget buildWorkflow() {
    double widthw = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildWorkflowStep(
                    text: "Upload",
                    isActive: firstButtonText == "Upload",
                    isCompleted: uploadCompleted,
                    progress: _uploadProgress,
                    onTap: handleTap,
                  ),
                  buildWorkflowStep(
                    text: "Find Primary Keys",
                    isActive: firstButtonText == "Find Primary Keys",
                    isCompleted: findPrimaryKeysCompleted,
                    progress: _findPrimaryKeysProgress,
                  ),
                  buildWorkflowStep(
                    text: "Map Data",
                    isActive: firstButtonText == "Map Data",
                    isCompleted: mapDataCompleted,
                    progress: _mapDataProgress,
                  ),
                  buildWorkflowStep(
                    text: "Validate Data",
                    isActive: firstButtonText == "Validate Data",
                    isCompleted: validateDataCompleted,
                  ),
                  // Add more steps as needed
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: buildTextWidget(
                        'Upload', firstButtonText == "Upload", widthw),
                  ),
                  buildTextWidget('Find Primary Keys',
                      firstButtonText == "Find Primary Keys", widthw),
                  buildTextWidget(
                      'Map Data', firstButtonText == "Map Data", widthw),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8),
                    child: buildTextWidget('Validate Data',
                        firstButtonText == "Validate Data", widthw),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildWorkflowStep(
      {required String text,
      required bool isActive,
      required bool isCompleted,
      double? progress,
      VoidCallback? onTap}) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? Color(0xFF3A4F39)
                            : isActive
                                ? Color(0xFF3A4F39)
                                : Colors.grey,
                        width: MediaQuery.of(context).size.width *
                            0.001, // Adjust the width of the border as needed
                      ),
                    ),
                    child: InkWell(
                      onTap: onTap,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: MediaQuery.of(context).size.width * 0.009,
                        child: Icon(
                          isCompleted
                              ? Icons.check // Checkmark for completed step
                              : isActive
                                  ? Icons.circle_rounded
                                  : null, // Lock icon for active and uncompleted steps
                          size: MediaQuery.of(context).size.width * 0.015,
                          color: isCompleted
                              ? Color(
                                  0xFF3A4F39) // White color for completed step
                              : isActive
                                  ? Color(
                                      0xFF3A4F39) // Green color for active step
                                  : Colors
                                      .grey, // Grey color for uncompleted step
                        ),
                      ),
                    ),
                  ),
                  if (progress != null)
                    buildProgressIndicator(
                        progress, MediaQuery.of(context).size.width * 0.014),
                ],
              ),
              SizedBox(height: 5.0),
              SizedBox(
                  height: 10.0), // Adjust the vertical spacing between steps
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    lineNumber = 0;
    Widget scrollableTopContainer = Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.all(Radius.circular(3)),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: buildErrorExpansionPanelList()),
      ),
    );

    double width100 = MediaQuery.of(context).size.width * 0.35;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side (Input)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildWorkflow(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: width100,
                                height:
                                    MediaQuery.of(context).size.height * 0.065,
                                child: MyCustomDropdown(
                                  selectedMode: sourceselectedMode,
                                  onModeChanged: handleSourceModeChanged,
                                  title: 'Source',
                                  width100: width100,
                                ),
                              ),
                              sourceselectedMode == 'File Mode'
                                  ? FileMode(
                                      controller: _sourceController,
                                      resultController: _resultController,
                                      firstButtonText: firstButtonText,
                                      title: 'Source',
                                      width100: width100,
                                      onFilePickerResult: (result) =>
                                          handleFileSelection(result,
                                              _sourceController, 'Source'),
                                      onPressed: () => handleTap(),
                                    )
                                  : ModeFields(
                                      hostController: _sourceHostController,
                                      userController: _sourceUserController,
                                      passController: _sourcePassController,
                                      dbNameController: _sourceDBNameController,
                                      tableController: _sourceTableController,
                                      width100: width100,
                                      labelTextPrefix: 'Source',
                                      mode: sourceselectedMode),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 40.0),
                      Container(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: width100,
                                height:
                                    MediaQuery.of(context).size.height * 0.065,
                                child: MyCustomDropdown(
                                    selectedMode: targetselectedMode,
                                    onModeChanged: handleTargetModeChanged,
                                    title: 'Target',
                                    width100: width100),
                              ),
                            ),
                            targetselectedMode == 'File Mode'
                                ? FileMode(
                                    controller: _targetController,
                                    resultController: _resultController,
                                    firstButtonText: firstButtonText,
                                    title: 'Target',
                                    width100: width100,
                                    onFilePickerResult: (result) =>
                                        handleFileSelection(result,
                                            _targetController, 'Target'),
                                    onPressed: () => handleTap(),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: ModeFields(
                                      hostController: _targetHostController,
                                      userController: _targetUserController,
                                      passController: _targetPassController,
                                      dbNameController: _targetDBNameController,
                                      tableController: _targetTableController,
                                      width100: width100,
                                      labelTextPrefix: 'Target',
                                      mode: targetselectedMode,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
                Container(
                  width: width100,
                  height: MediaQuery.of(context).size.height * 0.075,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF3A4F39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (!isLoading) {
                        if (firstButtonText == 'Validate Data') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Sampling Confirmation'),
                                content: Text(
                                  'Do you want to enter a sample percentage?',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: width100 * 0.02),
                                ),
                                actions: <Widget>[
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                            color: Color(0xFF3A4F39),
                                          ),
                                        ),
                                        width: width100 * 0.425,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Color(0xFF3A4F39),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Enter Sample Percentage',
                                                    style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                              RegExp(r'[0-9]')),
                                                    ],
                                                    controller:
                                                        _samplePercentageController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Sample Percentage',
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              samplePercentage =
                                                                  int.parse(
                                                                      _samplePercentageController
                                                                          .text);
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            chooseHandler(
                                                                firstButtonText); // Call chooseHandler after submitting
                                                          },
                                                          child: Text('Submit'),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              10.0), // Add vertical spacing between buttons
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                            color: Color(0xFF3A4F39),
                                          ),
                                        ),
                                        width: width100 * 0.425,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Color(0xFF3A4F39),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            chooseHandler(
                                                firstButtonText); // Call chooseHandler directly
                                          },
                                          child: Text('No'),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          );
                        } else
                          chooseHandler(firstButtonText);
                      }
                    },
                    child: Align(
                        alignment: Alignment.center,
                        child: isLoading
                            ? SizedBox(
                                width: width100 * 0.03,
                                height: width100 * 0.03,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(firstButtonText)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.15,
                    minHeight: MediaQuery.of(context).size.height * 0.05,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _resultController.text.contains("[+]")
                          ? Colors.green.withOpacity(0.5)
                          : _resultController.text.contains("[-]")
                              ? Colors.red.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          _resultController.text.isNotEmpty
                              ? _resultController.text
                              : '--',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // Right side (Results)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 60),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: multiKey == true
                        ? [
                            //Aswin: key sugessions
                            Row(
                              children: [
                                LayoutBuilder(builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: SearchField(
                                      key: const Key('searchfield'),
                                      controller: _keyController1,
                                      onSearchTextChanged: (query) {
                                        return srcCandidateKeys
                                            .where((option) => option
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
                                            .map(
                                              (option) =>
                                                  SearchFieldListItem<String>(
                                                option,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(option),
                                                ),
                                              ),
                                            )
                                            .toList();
                                      },
                                      onTap: () {
                                        srcpk = _keyController1.text;
                                        print("src-pk: $srcpk");
                                      },
                                      itemHeight: 50,
                                      suggestionStyle: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      searchInputDecoration: InputDecoration(
                                        hoverColor:
                                            Color.fromARGB(255, 187, 202, 186),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.only(left: 10),
                                        hintText: 'Select Source Primary Key',
                                      ),
                                      suggestionsDecoration:
                                          SuggestionDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                              border: Border.all(
                                                  color: Color(0xFF3A4F39),
                                                  width: 2)),
                                      suggestions: srcCandidateKeys
                                          .map(
                                            (option) =>
                                                SearchFieldListItem<String>(
                                              option,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(option),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                }),
                              ],
                            ),

                            //Aswin: end 1st key sugessions
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: SearchField(
                                controller: _keyController2,
                                key: const Key('searchfield'),
                                onSearchTextChanged: (query) {
                                  return trgCandidateKeys
                                      .where((option) => option
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                      .map(
                                        (option) => SearchFieldListItem<String>(
                                          option,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(option),
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                                onTap: () {
                                  trgpk = _keyController2.text;
                                  print("trg-pk: $trgpk");
                                },
                                itemHeight: 50,
                                suggestionStyle: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                searchInputDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 10),
                                  hintText: 'Select Target Primary Key',
                                ),
                                suggestionsDecoration: SuggestionDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                suggestions: trgCandidateKeys
                                    .map(
                                      (option) => SearchFieldListItem<String>(
                                        option,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(option),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            //Aswin: end 1st key sugessions
                          ]
                        : [],
                  ),
                ),
                SizedBox(height: 32.0),
                showDiagram == true
                    ? Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 235, 244, 255),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Source Columns",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Target Column Rule",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Color.fromARGB(255, 235, 244, 255),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height *
                                0.1 *
                                max(sourceColumnList.length,
                                    targetColumnList.length),
                            child: sourceColumnList != [] &&
                                    targetColumnList != []
                                ? ConnectionLinesWidget(
                                    leftItems: sourceColumnList,
                                    rightItems: targetColumnList,
                                    inputRuleString: inputRuleString,
                                    widgetWidth:
                                        MediaQuery.of(context).size.width * 0.5,
                                    widgetHeight:
                                        MediaQuery.of(context).size.height *
                                            0.1 *
                                            max(sourceColumnList.length,
                                                targetColumnList.length),
                                    onTextFieldValueChanged: (item, value) {
                                      // Update inputRuleString when a text field value changes
                                      updateInputRuleString(item, value);
                                    },
                                  )
                                : null,
                          ),
                        ],
                      )
                    : Text(""),
                showErrors == true
                    ? Column(
                        children: [
                          // errorButton,
                          scrollableTopContainer,
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      )
                    : Text(
                        'No data available',
                        style: TextStyle(
                            fontSize: width100 * 0.05,
                            color: Colors.grey,
                            fontFamily: 'Inter'),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
