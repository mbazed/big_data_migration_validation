import 'package:data_validation/FileReadRoutine.dart';
import 'package:data_validation/main.dart';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart'
    show kIsWeb; // Import kIsWeb from flutter/foundation

class DesktopDataValidatorPage extends StatefulWidget {
  const DesktopDataValidatorPage({Key? key}) : super(key: key);

  @override
  State<DesktopDataValidatorPage> createState() {
    return _DesktopDataValidatorPageState();
  }
}

class _DesktopDataValidatorPageState extends State<DesktopDataValidatorPage> {
  String selectedMode = 'File Mode';
  String source = '';
  String target = '';
  String message = '';
  String sourceData = '';
  String targetData = '';
  String secondButtonText = 'Map Data';
  String firstButtonText = 'Upload';
  bool multiKey = false;
  String requestID = "";

  FilePickerResult? targetResult;
  FilePickerResult? sourceResult;

  final pkUrl = Uri.parse('http://localhost:4564/findKeys');
  final dbmodeurl = Uri.parse('http://localhost:4564/getfromdb');
  final mapUrl = Uri.parse('http://localhost:4564/mapData');
  final validateUrl = Uri.parse('http://localhost:4564/validateData');
  final uploadUrl = Uri.parse('http://localhost:4564/upload');

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

  TextEditingController _keyController1 = TextEditingController();
  TextEditingController _keyController2 = TextEditingController();
  List<String> srcCandidateKeys = [];
  List<String> trgCandidateKeys = [];

  String fileName = 'No file selected';
  // Use your _list here
  final List<String> _list = [
    'File Mode',
    'MySQL',
    'Oracle DB',
    'MongoDB'

    // Add other items as needed
  ];

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

  // Callback function that will be executed when any text changes
  void _handleTextChange() {
    // Do something when text changes

    setState(() {
      firstButtonText = 'Upload';
    });
  }

  @override
  Widget build(BuildContext context) {
    double width100 = MediaQuery.of(context).size.width * 0.35;
    return Row(
      children: [
        // Left side (Input)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width100,
                  height: MediaQuery.of(context).size.height * 0.105,
                  child: CustomDropdown<String>(
                    canCloseOutsideBounds: true,
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                    expandedBorderRadius: BorderRadius.circular(8.0),
                    expandedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.7),
                      width: 1,
                    ),
                    closedBorderRadius: BorderRadius.circular(8.0),
                    closedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.7),
                      width: 1,
                    ),
                    listItemBuilder: (BuildContext context, String item) {
                      IconData icon;
                      if (item == 'File Mode') {
                        icon = Icons
                            .file_copy_outlined; // Replace with the desired icon
                      } else if (item == 'Database Mode') {
                        icon = Icons.storage; // Replace with the desired icon
                      } else {
                        icon = Icons.error; // Default icon for unknown items
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, size: 14),
                              SizedBox(width: 8),
                              Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    headerBuilder:
                        (BuildContext context, String? selectedItem) {
                      IconData icon;
                      if (selectedItem == 'File Mode') {
                        icon = Icons
                            .file_copy_outlined; // Replace with the desired icon
                      } else if (selectedItem == 'Database Mode') {
                        icon = Icons.storage; // Replace with the desired icon
                      } else {
                        icon = Icons.error; // Default icon for unknown items
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, size: 14),
                              SizedBox(width: 8),
                              Text(
                                selectedItem ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    hintText: "Select Mode",
                    hintBuilder: (BuildContext context, String hint) {
                      return Row(
                        children: [
                          // Icon(Icons.mode, size: 18), // Add your icon
                          // SizedBox(width: 8),
                          Text(
                            hint,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Montserrat",
                              fontWeight:
                                  FontWeight.w600, // Set the desired font size
                            ),
                          ),
                        ],
                      );
                    },
                    items: _list,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMode = newValue!;
                      });
                    },
                    // ... (Your existing code for dropdown)
                  ),
                ),
                SizedBox(height: 16.0),
                selectedMode == 'File Mode'
                    ? Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // ... (Your existing code for source)
                                Column(
                                  children: [
                                    Container(
                                      alignment: AlignmentDirectional.topStart,
                                      width: width100,
                                      padding: EdgeInsets.only(bottom: 2),
                                      child: RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                            text: 'Source ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Container(
                                        width: width100,
                                        alignment:
                                            AlignmentDirectional.topStart,
                                        child: Text(
                                            'Supported file types: .csv, .xlsx',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.7),
                                        ),
                                      ),
                                      width: width100,
                                      child: TextField(
                                        controller: _sourceController,
                                        onChanged: (_) {},
                                        onSubmitted: (_) {},
                                        style: TextStyle(),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                          hintText: '--',
                                          hintStyle: TextStyle(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 40),
                                  child: InkWell(
                                    onTap: () async {
                                      sourceResult =
                                          await FilePicker.platform.pickFiles(
                                        allowMultiple: false,
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'csv',
                                          'xlsx',
                                          'xls'
                                        ],
                                      );

                                      // Check if a file was selected
                                      if (sourceResult != null) {
                                        setState(() {
                                          firstButtonText = 'Upload';
                                          // sourceData = readFile(sourceResult);

                                          source =
                                              sourceResult!.files.single.name;
                                          _sourceController.text = source;

                                          _resultController.text =
                                              '\nSource selected: $source\n';
                                        });
                                      } else {
                                        setState(() {
                                          source = 'No file selected';
                                          _sourceController.text = source;
                                          _resultController.text =
                                              '${_resultController.text}No file selected\n';
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.7),
                                        ),
                                      ),
                                      child: Icon(
                                          Icons.drive_folder_upload_rounded,
                                          size: 35),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                // ... (Your existing code for target)
                                Column(
                                  children: [
                                    Container(
                                      alignment: AlignmentDirectional.topStart,
                                      width: width100,
                                      padding: EdgeInsets.only(bottom: 3),
                                      child: RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                            text: 'Target ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Container(
                                        width: width100,
                                        alignment:
                                            AlignmentDirectional.topStart,
                                        child: Text(
                                            'Supported file types: .csv, .xlsx',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.7),
                                        ),
                                      ),
                                      width: width100,
                                      child: TextField(
                                        controller: _targetController,
                                        onChanged: (_) {},
                                        onSubmitted: (_) {},
                                        style: TextStyle(),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                          hintText: '--',
                                          hintStyle: TextStyle(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 42),
                                  child: InkWell(
                                    onTap: () async {
                                      // Open file picker
                                      targetResult =
                                          await FilePicker.platform.pickFiles(
                                        allowMultiple: false,
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'csv',
                                          'xlsx',
                                          'xls'
                                        ],
                                      );
                                      // Check if a file was selected
                                      if (targetResult != null) {
                                        setState(() {
                                          // Update the 'source' variable with the selected file path

                                          // targetData = readFile(result);
                                          firstButtonText = 'Upload';

                                          target =
                                              targetResult!.files.single.name;
                                          _targetController.text = target;
                                          if (_resultController.text != '') {
                                            _resultController.text =
                                                '${_resultController.text}Target selected: $target\n';
                                          } else {
                                            _resultController.text =
                                                '\n${_resultController.text}Target selected: $target\n';
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          target = 'No file selected';
                                          _targetController.text = target;
                                          _resultController.text =
                                              '${_resultController.text}No file selected\n';
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.7),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.drive_folder_upload_rounded,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username TextField
                            Container(
                              width: width100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _sourceUserController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Source Username',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _targetUserController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Target Username',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Password TextField
                            Container(
                              width: width100,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: width100 * 0.475,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: TextField(
                                          controller: _sourcePassController,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            suffixIcon:
                                                Icon(Icons.visibility_off),
                                            labelText: 'Source Password',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: width100 * 0.475,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: TextField(
                                          controller: _targetPassController,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            suffixIcon:
                                                Icon(Icons.visibility_off),
                                            labelText: 'Target Password',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]),
                            ),
                            // Connection String TextField
                            Container(
                              width: width100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _sourceDBNameController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Source Database Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _targetDBNameController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Target Database Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: width100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _sourceHostController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Source Host',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _targetHostController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Target Host',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: width100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _sourceTableController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Source Table Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width100 * 0.475,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: TextField(
                                        controller: _targetTableController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Target Table Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
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
                    onPressed: firstButtonText == 'Upload'
                        ? () async {
                            if (selectedMode == 'File Mode') {
                              try {
                                var request;

                                if (sourceResult != null &&
                                    targetResult != null) {
                                  request =
                                      http.MultipartRequest('POST', uploadUrl);

                                  // Add source file to request
                                  if (kIsWeb) {
                                    // Use bytes property for web
                                    request.files
                                        .add(http.MultipartFile.fromBytes(
                                      'sourceFile',
                                      sourceResult!.files.single.bytes!,
                                      filename: sourceResult!.files.single.name,
                                    ));
                                  } else {
                                    // Use fromPath for other platforms
                                    request.files
                                        .add(await http.MultipartFile.fromPath(
                                      'sourceFile',
                                      sourceResult!.files.single.path!,
                                    ));
                                  }

                                  // Add target file to request
                                  if (kIsWeb) {
                                    // Use bytes property for web
                                    request.files
                                        .add(http.MultipartFile.fromBytes(
                                      'targetFile',
                                      targetResult!.files.single.bytes!,
                                      filename: targetResult!.files.single.name,
                                    ));
                                  } else {
                                    // Use fromPath for other platforms
                                    request.files
                                        .add(await http.MultipartFile.fromPath(
                                      'targetFile',
                                      targetResult!.files.single.path!,
                                    ));
                                  }

                                  var response = await request.send();
                                  print(
                                      'Response Status Code: ${response.statusCode}');

                                  if (response.statusCode == 200) {
                                    print('[+] Files Uploaded successfully!');
                                    var responseBody =
                                        await response.stream.bytesToString();
                                    final Map<String, dynamic> data =
                                        jsonDecode(responseBody);
                                    requestID = data['request_id'].toString();
                                    var message = data['message'].toString();

                                    print('Request ID: $requestID');
                                    print('Message: $message');

                                    setState(() {
                                      _resultController.text =
                                          '${_resultController.text}${message}\n';
                                      firstButtonText = 'Find Primary Keys';
                                    });
                                  }
                                } else {
                                  _resultController.text =
                                      '${_resultController.text}Source or target result is Null\n';
                                  print('[!] Source or target result is null');
                                  // Handle the case when either sourceResult or targetResult is null
                                }
                              } catch (e) {
                                _resultController.text =
                                    '${_resultController.text}Error during File Upload: $e\n';
                                print('[!] Error during File Upload: $e');
                                // Handle other errors
                              }
                            } else {
                              var source_database_type = 'mysql';
                              var target_database_type = 'mysql';
                              try {
                                if (_sourceUserController.text != "" &&
                                    _sourcePassController.text != "" &&
                                    _sourceHostController.text != "" &&
                                    _sourceDBNameController.text != "" &&
                                    _sourceTableController.text != "" &&
                                    _targetUserController.text != "" &&
                                    _targetPassController.text != "" &&
                                    _targetHostController.text != "" &&
                                    _targetDBNameController.text != "" &&
                                    _targetTableController.text != "") {
                                  final response = await http.post(
                                    dbmodeurl,
                                    body: {
                                      'source_database_type':
                                          source_database_type,
                                      'source_hostname':
                                          _sourceHostController.text,
                                      'source_username':
                                          _sourceUserController.text,
                                      'source_database':
                                          _sourceDBNameController.text,
                                      'source_password':
                                          _sourcePassController.text,
                                      'source_table':
                                          _sourceTableController.text,
                                      'target_database_type':
                                          target_database_type,
                                      'target_hostname':
                                          _targetHostController.text,
                                      'target_username':
                                          _targetUserController.text,
                                      'target_database':
                                          _targetDBNameController.text,
                                      'target_password':
                                          _targetPassController.text,
                                      'target_table':
                                          _targetTableController.text,
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    print(
                                        '[+] Data retrived from Databases successfully!');

                                    final Map<String, dynamic> data =
                                        jsonDecode(response.body);
                                    requestID = data['request_id'].toString();
                                    var message = data['message'].toString();

                                    print('Request ID: $requestID');
                                    print('Message: $message');

                                    setState(() {
                                      _resultController.text =
                                          '${_resultController.text}${message}\n';
                                      firstButtonText = 'Find Primary Keys';
                                    });
                                  } else {
                                    setState(() {
                                      firstButtonText == 'Upload';
                                      _resultController.text =
                                          '${_resultController.text} Databases Connection Error!\n';
                                    });
                                  }
                                } else {
                                  setState(() {
                                    firstButtonText == 'Upload';
                                    _resultController.text =
                                        '${_resultController.text} Please fill all the fields!\n';
                                  });
                                }
                              } catch (e) {
                                print('[!] Error during Database upload: $e');
                              }
                            }
                          }
                        : () async {
                            try {
                              final response = await http.post(
                                pkUrl,
                                body: {
                                  'request_id': requestID,
                                },
                              );

                              if (response.statusCode == 200) {
                                print('[+] Primary Key Fetch successful! ');
                                secondButtonText = 'Map Data';

                                final Map<String, dynamic> data =
                                    jsonDecode(response.body);

                                // Access the 'primarykey' value
                                setState(() {
                                  _keyController1.text = "";
                                  _keyController2.text = "";
                                  srcCandidateKeys = data['sourcePrimaryKey']
                                      .toString()
                                      .split(',');
                                  trgCandidateKeys = data['targetPrimaryKey']
                                      .toString()
                                      .split(',');
                                  var srcCandidateKeysStr =
                                      data['sourcePrimaryKey'].toString();
                                  var trgCandidateKeysStr =
                                      data['targetPrimaryKey'].toString();
                                  if (srcCandidateKeys.length > 1 ||
                                      trgCandidateKeys.length > 1) {
                                    multiKey = true;
                                  } else {
                                    multiKey = false;
                                  }

                                  srcpk = srcCandidateKeys[0];
                                  trgpk = trgCandidateKeys[0];
                                  _resultController.text =
                                      '${_resultController.text}Primary Key of source: ${srcCandidateKeysStr}\nPrimary Key of Target: ${trgCandidateKeysStr}\n';
                                });
                              } else {
                                print(
                                    '[-] Primary Key Fetch failed: ${response.statusCode}');
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
                          },
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(firstButtonText)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side (Results)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: multiKey == true
                        ? [
                            //Aswin: key sugessions
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              width: width100 * 0.5,
                              child: Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  return srcCandidateKeys
                                      .where(
                                        (String suggestion) =>
                                            suggestion.toLowerCase().contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ),
                                      )
                                      .where(
                                        (String suggestion) =>
                                            suggestion.toLowerCase().contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ),
                                      )
                                      .toList();
                                },
                                onSelected: (String selectedValue) {
                                  _keyController1.text = selectedValue;
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController textEditingController,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  _keyController1 = textEditingController;
                                  return TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onTapOutside: (_) {
                                      srcpk = _keyController1.text;
                                      print("src-pk: $srcpk");
                                      onFieldSubmitted();
                                    },
                                    onSubmitted: (_) {},
                                    style: TextStyle(),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding: EdgeInsets.only(left: 10),
                                      hintText: 'Select Source Primary Key',
                                      hintStyle: TextStyle(),
                                    ),
                                  );
                                },
                                optionsViewBuilder: (BuildContext context,
                                    AutocompleteOnSelected<String> onSelected,
                                    Iterable<String> options) {
                                  return Material(
                                    elevation: 4.0,
                                    child: ListView(
                                      children: options
                                          .map(
                                            (String option) => ListTile(
                                              title: Text(option),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
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
                              width: width100 * 0.5,
                              child: Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  return trgCandidateKeys
                                      .where(
                                        (String suggestion) =>
                                            suggestion.toLowerCase().contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ),
                                      )
                                      .where(
                                        (String suggestion) =>
                                            suggestion.toLowerCase().contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ),
                                      )
                                      .toList();
                                },
                                onSelected: (String selectedValue) {
                                  _keyController2.text = selectedValue;
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController textEditingController,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  _keyController2 = textEditingController;
                                  return TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onTapOutside: (_) {
                                      trgpk = _keyController2.text;
                                      print("trg-pk: $trgpk");
                                      onFieldSubmitted();
                                    },
                                    onSubmitted: (_) {
                                      onFieldSubmitted();
                                    },
                                    style: TextStyle(),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding: EdgeInsets.only(left: 10),
                                      hintText: 'Select Target Primary Key',
                                      hintStyle: TextStyle(),
                                    ),
                                  );
                                },
                                optionsViewBuilder: (BuildContext context,
                                    AutocompleteOnSelected<String> onSelected,
                                    Iterable<String> options) {
                                  return Material(
                                    elevation: 4.0,
                                    child: ListView(
                                      children: options
                                          .map(
                                            (String option) => ListTile(
                                              title: Text(option),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            //Aswin: end 1st key sugessions
                          ]
                        : [],
                  ),
                ),
                Container(
                  alignment: AlignmentDirectional.topStart,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(bottom: 11, top: 15),
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: 'Results ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.215,
                    child: TextField(
                      controller: _resultController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onChanged: (_) {},
                      onSubmitted: (_) {},
                      style: TextStyle(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: EdgeInsets.only(left: 10),
                        hintText: '--',
                        hintStyle: TextStyle(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.075,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF3A4F39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: secondButtonText == "Map Data"
                        ? () async {
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

                                final Map<String, dynamic> data =
                                    jsonDecode(responseMap.body);

                                var mapingDoc = data['MapingDoc'].toString();
                                var mapingStatus = data['message'].toString();

                                // Move the setState outside and update the state synchronously
                                _resultController.text =
                                    '\nMapping status: $mapingStatus\nResult:\n$mapingDoc\n';
                                if (mapingStatus[1] == '+')
                                  secondButtonText = 'Validate Data';
                                else if (mapingStatus[1] == '-')
                                  secondButtonText = 'Map Data';

                                // Update the widget state
                                setState(() {});
                              } else {
                                print(
                                    '[-] Mapping failed: ${responseMap.statusCode}');
                              }
                            } catch (e) {
                              print('[!] Error during mapping: $e');
                            }
                          }
                        : () async {
                            try {
                              final responseValidation = await http.post(
                                validateUrl,
                                body: {
                                  'request_id': requestID,
                                },
                              );

                              if (responseValidation.statusCode == 200) {
                                final Map<String, dynamic> data =
                                    jsonDecode(responseValidation.body);
                                var validationDoc =
                                    data['validationDoc'].toString();
                                var validationStatus =
                                    data['message'].toString();
                                print('[+] Validation successful!  \n' +
                                    validationStatus);

                                // Move the setState outside and update the state synchronously
                                _resultController.text =
                                    '\n Validation Status: $validationStatus\nValidation Doc:\n$validationDoc\n';
                                secondButtonText = 'Download Report';

                                // Update the widget state
                                setState(() {});
                              } else {
                                print(
                                    '[-] Validation failed: ${responseValidation.statusCode}');
                              }
                            } catch (e) {
                              print('[!] Error during validation: $e');
                            }
                          },
                    child: Text(secondButtonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
