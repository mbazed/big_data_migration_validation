import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'diagram.dart';

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
  String secondButtonText = 'Map Data';
  String firstButtonText = 'Upload';
  bool multiKey = false;
  String requestID = "";

  FilePickerResult? targetResult;
  FilePickerResult? sourceResult;

  List<String> sourceColumnList = [
    'Roll No',
    'Name',
    'Contact',
    'Class',
    'Dumpid'
  ];
  List<String> targetColumnList = [
    'College Id',
    'Student Name',
    'Contact',
    'Dumpid'
  ];
  List<List<String>> connections = [];

  final pkUrl = Uri.parse('http://localhost:4564/findKeys');
  final dbmodeurl = Uri.parse('http://localhost:4564/getfromdb');
  final mapUrl = Uri.parse('http://localhost:4564/mapData');
  final validateUrl = Uri.parse('http://localhost:4564/validateData');
  final uploadUrl = Uri.parse('http://localhost:4564/upload');
  final uploadDataUrl = Uri.parse('http://localhost:4564/getdata');
  final downloadUrl = Uri.parse('http://localhost:4564/download');
  bool showDiagram = false;
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
  List<List<String>> rules = [];

  String inputRuleString = '';

  String fileName = 'No file selected';
  // Use your _list here
  final List<String> _list = [
    'File Mode',
    'MySQL',
    'Oracle DB',
    'MongoDB'

    // Add other items as needed
  ];

  List<String> getModifiedList() {
    return sourceselectedMode == 'File Mode' ? _list.sublist(1) : _list;
  }

  List<String> target_getModifiedList() {
    return targetselectedMode == 'File Mode' ? _list.sublist(1) : _list;
  }

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

  void handleMapData() async {
    if (multiKey) {
      srcpk = _keyController1.text;
      trgpk = _keyController2.text;
    }
    setState(() {
      connections = [];
      rules = [];
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
        _resultController.text =
            '\nMapping status: $mapingStatus\nResult:\n$mapingDoc\n';
        setState(() {
          if (mapingStatus[1] == '+') {
            secondButtonText = 'Validate Data';
          } else if (mapingStatus[1] == '-') secondButtonText = 'Map Data';
        });
      } else {
        print('[-] Mapping failed: ${responseMap.statusCode}');
      }
    } catch (e) {
      print('[!] Error during mapping: $e');
    }
  }

  void handleValidateData() async {
    try {
      final responseValidation = await http.post(
        validateUrl,
        body: {
          'request_id': requestID,
        },
      );

      if (responseValidation.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseValidation.body);
        var validationDoc = data['validationDoc'].toString();
        var validationStatus = data['message'].toString();
        print('[+] Validation successful!  \n' + validationStatus);

        _resultController.text =
            '\n Validation Status: $validationStatus\nValidation Doc:\n$validationDoc\n';
        secondButtonText = 'Download Report';

        setState(() {});
      } else {
        print('[-] Validation failed: ${responseValidation.statusCode}');
      }
    } catch (e) {
      print('[!] Error during validation: $e');
    }
  }

  Future<void> handleUpload() async {
    setState(() {
      connections = [];
      rules = [];
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
          _resultController.text =
              '${_resultController.text}Source result is Null\n';
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
        if (_sourceUserController.text != "" &&
            _sourcePassController.text != "" &&
            _sourceHostController.text != "" &&
            _sourceDBNameController.text != "" &&
            _sourceTableController.text != "") {
          requestBody['source_hostname'] = _sourceHostController.text;
          requestBody['source_username'] = _sourceUserController.text;
          requestBody['source_database'] = _sourceDBNameController.text;
          requestBody['source_password'] = _sourcePassController.text;
          requestBody['source_table'] = _sourceTableController.text;
        } else {
          _resultController.text =
              '${_resultController.text}Please fill all the fields!\n';
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
          _resultController.text =
              '${_resultController.text}Target result is Null\n';
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
        if (_targetUserController.text != "" &&
            _targetPassController.text != "" &&
            _targetHostController.text != "" &&
            _targetDBNameController.text != "" &&
            _targetTableController.text != "") {
          requestBody['target_hostname'] = _targetHostController.text;
          requestBody['target_username'] = _targetUserController.text;
          requestBody['target_database'] = _targetDBNameController.text;
          requestBody['target_password'] = _targetPassController.text;
          requestBody['target_table'] = _targetTableController.text;
        } else {
          _resultController.text =
              '${_resultController.text}Please fill all the fields!\n';
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
          _resultController.text = '${_resultController.text}${message}\n';
          firstButtonText = 'Find Primary Keys';
        });
      }
    } catch (e) {
      _resultController.text =
          '${_resultController.text}Error during File Upload: $e\n';
      print('[!] Error during File Upload: $e');
      // Handle other errors
    }
  }

  Future<void> handleUpload2() async {
    try {
      if (sourceselectedMode == 'File Mode') {
        var request;

        if (sourceResult != null && targetResult != null) {
          request = http.MultipartRequest('POST', uploadUrl);

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
              _resultController.text = '${_resultController.text}${message}\n';
              firstButtonText = 'Find Primary Keys';
            });
          }
        } else {
          _resultController.text =
              '${_resultController.text}Source or target result is Null\n';
          print('[!] Source or target result is null');
          // Handle the case when either sourceResult or targetResult is null
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
                'source_database_type': source_database_type,
                'source_hostname': _sourceHostController.text,
                'source_username': _sourceUserController.text,
                'source_database': _sourceDBNameController.text,
                'source_password': _sourcePassController.text,
                'source_table': _sourceTableController.text,
                'target_database_type': target_database_type,
                'target_hostname': _targetHostController.text,
                'target_username': _targetUserController.text,
                'target_database': _targetDBNameController.text,
                'target_password': _targetPassController.text,
                'target_table': _targetTableController.text,
              },
            );

            if (response.statusCode == 200) {
              print('[+] Data retrived from Databases successfully!');

              final Map<String, dynamic> data = jsonDecode(response.body);
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
    } catch (e) {
      _resultController.text =
          '${_resultController.text}Error during File Upload: $e\n';
      print('[!] Error during File Upload: $e');
      // Handle other errors
    }
  }

  Future<void> handleFindPrimaryKeys() async {
    setState(() {
      connections = [];
      rules = [];
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
        secondButtonText = 'Map Data';

        final Map<String, dynamic> data = jsonDecode(response.body);

        // Access the 'primarykey' value
        setState(() {
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
            multiKey = false;
          }

          srcpk = srcCandidateKeys[0];
          trgpk = trgCandidateKeys[0];
          _resultController.text =
              '${_resultController.text}Primary Key of source: ${srcCandidateKeysStr}\nPrimary Key of Target: ${trgCandidateKeysStr}\n';
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

  Widget getIconOrImage(String? selectedItem) {
    if (selectedItem == 'File Mode') {
      return Icon(Icons.file_copy_outlined, size: 14);
    } else if (selectedItem == 'MySQL') {
      return ImageIcon(AssetImage('assets/images/mysql.png'), size: 16);
    } else if (selectedItem == 'Oracle DB') {
      return ImageIcon(AssetImage('assets/images/oracle.png'), size: 16);
    } else if (selectedItem == 'MongoDB') {
      return ImageIcon(AssetImage('assets/images/mongodb.png'), size: 16);
    } else {
      return Icon(Icons.error, size: 14); // Default icon for unknown items
    }
  }

  Widget iconOrImageWidget(Widget iconOrImage) {
    return iconOrImage;
  }

  @override
  Widget build(BuildContext context) {
    double width100 = MediaQuery.of(context).size.width * 0.35;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side (Input)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                                child: CustomDropdown<String>(
                                  canCloseOutsideBounds: true,
                                  decoration: CustomDropdownDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w600,
                                    ),
                                    expandedBorderRadius:
                                        BorderRadius.circular(8.0),
                                    expandedBorder: Border.all(
                                      color: Color(0xFF3A4F39),
                                      width: 2,
                                    ),
                                    closedBorderRadius:
                                        BorderRadius.circular(8.0),
                                    closedBorder: Border.all(
                                      color: Color(0xFF3A4F39),
                                      width: 2,
                                    ),
                                  ),
                                  listItemBuilder: (BuildContext context,
                                      dynamic item,
                                      bool isSelected,
                                      Function() onItemSelect) {
                                    Widget iconOrImage = getIconOrImage(item);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            iconOrImage,
                                            SizedBox(width: 8),
                                            Text(
                                              item.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Additional UI or logic based on isSelected
                                      ],
                                    );
                                  },
                                  headerBuilder: (BuildContext context,
                                      String? selectedItem) {
                                    Widget iconOrImage =
                                        getIconOrImage(selectedItem);

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            iconOrImage,
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
                                        Text(
                                          'Source',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  hintText: sourceselectedMode,
                                  hintBuilder:
                                      (BuildContext context, String hint) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          hint,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        ),
                                        Text(
                                          'Source',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  items: getModifiedList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      sourceselectedMode = newValue!;
                                    });
                                  },
                                  // ... (Your existing code for dropdown)
                                ),
                              ),
                              sourceselectedMode == 'File Mode'
                                  ? Row(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Container(
                                                width: width100,
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                    'Supported file types: .csv, .xlsx',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontFamily: "Inter",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    )),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              width: width100,
                                              child: TextField(
                                                controller: _sourceController,
                                                onChanged: (_) {},
                                                onSubmitted: (_) {},
                                                style: TextStyle(),
                                                decoration: InputDecoration(
                                                  suffixIcon: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        sourceResult =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles(
                                                          allowMultiple: false,
                                                          type: FileType.custom,
                                                          allowedExtensions: [
                                                            'csv',
                                                            'xlsx',
                                                            'xls'
                                                          ],
                                                        );
                                                        // Check if a file was selected
                                                        if (sourceResult !=
                                                            null) {
                                                          setState(() {
                                                            firstButtonText =
                                                                'Upload';
                                                            // sourceData = readFile(sourceResult);

                                                            source =
                                                                sourceResult!
                                                                    .files
                                                                    .single
                                                                    .name;
                                                            _sourceController
                                                                .text = source;

                                                            _resultController
                                                                    .text =
                                                                'Source selected: $source\n';
                                                          });
                                                        } else {
                                                          setState(() {
                                                            source =
                                                                'No file selected';
                                                            _sourceController
                                                                .text = source;
                                                            _resultController
                                                                    .text =
                                                                '${_resultController.text}No file selected\n';
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                          Icons
                                                              .drive_folder_upload_rounded,
                                                          size:
                                                              width100 * 0.06),
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.only(left: 10),
                                                  hintText: '--',
                                                  hintStyle: TextStyle(),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  : Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: width100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: width100,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            _sourceHostController,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Source Host',
                                                          border:
                                                              OutlineInputBorder(),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: width100 * 0.475,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0),
                                                        child: TextField(
                                                          controller:
                                                              _sourceUserController,
                                                          onChanged: (value) {
                                                            setState(() {});
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Source Username',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: width100 * 0.475,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0),
                                                        child: TextField(
                                                          controller:
                                                              _sourcePassController,
                                                          onChanged: (value) {
                                                            setState(() {});
                                                          },
                                                          obscureText: true,
                                                          decoration:
                                                              InputDecoration(
                                                            suffixIcon: Icon(Icons
                                                                .visibility_off),
                                                            labelText:
                                                                'Source Password',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                            // Connection String TextField
                                            Container(
                                              width: width100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: width100 * 0.475,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            _sourceDBNameController,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Source Database Name',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: width100 * 0.475,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            _sourceTableController,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Source Table Name',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                child: CustomDropdown<String>(
                                  canCloseOutsideBounds: true,
                                  decoration: CustomDropdownDecoration(
                                      errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      expandedBorderRadius:
                                          BorderRadius.circular(8.0),
                                      expandedBorder: Border.all(
                                        color: Color(0xFF3A4F39),
                                        width: 2,
                                      ),
                                      closedBorderRadius:
                                          BorderRadius.circular(8.0),
                                      closedBorder: Border.all(
                                        color: Color(0xFF3A4F39),
                                        width: 2,
                                      )),
                                  listItemBuilder: (BuildContext context,
                                      dynamic item,
                                      bool isSelected,
                                      Function() onItemSelect) {
                                    Widget iconOrImage = getIconOrImage(item);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            iconOrImage,
                                            SizedBox(width: 8),
                                            Text(
                                              item.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Additional UI or logic based on isSelected
                                      ],
                                    );
                                  },
                                  headerBuilder: (BuildContext context,
                                      String? selectedItem) {
                                    Widget iconOrImage =
                                        getIconOrImage(selectedItem);

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            iconOrImage,
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
                                        Text(
                                          'Target',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  hintText: targetselectedMode,
                                  hintBuilder:
                                      (BuildContext context, String hint) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          hint,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        ),
                                        Text(
                                          'Target',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 14,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight
                                                .w600, // Set the desired font size
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  items: target_getModifiedList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      targetselectedMode = newValue!;
                                    });
                                  },
                                  // ... (Your existing code for dropdown)
                                ),
                              ),
                            ),
                            targetselectedMode == 'File Mode'
                                ? Row(
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
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
                                                color: Colors.grey
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            width: width100,
                                            child: TextField(
                                              controller: _targetController,
                                              onChanged: (_) {},
                                              onSubmitted: (_) {},
                                              style: TextStyle(),
                                              decoration: InputDecoration(
                                                suffixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      // Open file picker
                                                      targetResult =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        allowMultiple: false,
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                          'csv',
                                                          'xlsx',
                                                          'xls'
                                                        ],
                                                      );
                                                      // Check if a file was selected
                                                      if (targetResult !=
                                                          null) {
                                                        setState(() {
                                                          // Update the 'source' variable with the selected file path

                                                          // targetData = readFile(result);
                                                          firstButtonText =
                                                              'Upload';

                                                          target = targetResult!
                                                              .files
                                                              .single
                                                              .name;
                                                          _targetController
                                                              .text = target;
                                                          if (_resultController
                                                                  .text !=
                                                              '') {
                                                            _resultController
                                                                    .text =
                                                                '${_resultController.text}Target selected: $target\n';
                                                          } else {
                                                            _resultController
                                                                    .text =
                                                                '${_resultController.text}Target selected: $target\n';
                                                          }
                                                        });
                                                      } else {
                                                        setState(() {
                                                          target =
                                                              'No file selected';
                                                          _targetController
                                                              .text = target;
                                                          _resultController
                                                                  .text =
                                                              '${_resultController.text}No file selected\n';
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .drive_folder_upload_rounded,
                                                      size: width100 * 0.06,
                                                    ),
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
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
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Username TextField
                                          Container(
                                            width: width100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: width100,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: TextField(
                                                      controller:
                                                          _targetHostController,
                                                      onChanged: (value) {
                                                        setState(() {});
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Target Hostname',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Password TextField
                                          Container(
                                            width: width100,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: width100 * 0.475,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            _targetUserController,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Target Username',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: width100 * 0.475,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            _targetPassController,
                                                        onChanged: (value) {
                                                          setState(() {});
                                                        },
                                                        obscureText: true,
                                                        decoration:
                                                            InputDecoration(
                                                          suffixIcon: Icon(Icons
                                                              .visibility_off),
                                                          labelText:
                                                              'Target Password',
                                                          border:
                                                              OutlineInputBorder(),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: width100 * 0.475,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: TextField(
                                                      controller:
                                                          _targetDBNameController,
                                                      onChanged: (value) {
                                                        setState(() {});
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Target Database Name',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: width100 * 0.475,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: TextField(
                                                      controller:
                                                          _targetTableController,
                                                      onChanged: (value) {
                                                        setState(() {});
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Target Table Name',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
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
                    onPressed: firstButtonText == 'Upload'
                        ? () async {
                            await handleUpload();
                          }
                        : () async {
                            await handleFindPrimaryKeys();
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
                                width: MediaQuery.of(context).size.width * 0.15,
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
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    hintText: 'Select Source Primary Key',
                                  ),
                                  suggestionsDecoration: SuggestionDecoration(
                                      color: Colors.lightGreen.shade300,
                                      borderRadius: BorderRadius.circular(2.0),
                                      border: Border.all(
                                          color: Color(0xFF3A4F39), width: 2)),
                                  suggestions: srcCandidateKeys
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
                              );
                            }),

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
                Container(
                  alignment: AlignmentDirectional.topStart,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(
                    bottom: 25,
                  ),
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
                        contentPadding: EdgeInsets.all(15),
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
                    onPressed: () async {
                      switch (secondButtonText) {
                        case 'Map Data':
                          handleMapData();
                          break;
                        case 'Validate Data':
                          handleValidateData();
                          break;
                        case 'Download Report':
                          downloadReport(_resultController.text);
                          break;
                      }
                    },
                    child: Text(secondButtonText),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Source Columns",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Target Column Rule",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Color.fromARGB(255, 235, 244, 255),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height *
                      0.1 *
                      max(sourceColumnList.length, targetColumnList.length),
                  margin: EdgeInsets.only(top: 20),
                  child: showDiagram == true
                      ? ConnectionLinesWidget(
                          leftItems: sourceColumnList,
                          rightItems: targetColumnList,
                          inputRuleString: inputRuleString,
                          widgetWidth: MediaQuery.of(context).size.width * 0.5,
                          widgetHeight:
                              MediaQuery.of(context).size.height * 0.4,
                        )
                      : Text("Hi"),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
