import 'package:data_validation/FileReadRoutine.dart';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show kIsWeb; // Import kIsWeb from flutter/foundation

import 'package:http/http.dart' as http;

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
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  String fileName = 'No file selected';
  // Use your _list here
  final List<String> _list = [
    'File Mode',
    'Database Mode',
    // Add other items as needed
  ];

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
                            alignment: AlignmentDirectional.topStart,
                            child: Text('Supported file types: .csv, .xlsx',
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: '--',
                              hintStyle: TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 40),
                      child: InkWell(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: ['csv', 'xlsx'],
                          );

                          // Check if a file was selected
                          if (result != null) {
                            setState(() {
                              sourceData = readFile(result);

                              source = result.files.single.name;
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          child:
                              Icon(Icons.drive_folder_upload_rounded, size: 35),
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
                            alignment: AlignmentDirectional.topStart,
                            child: Text('Supported file types: .csv, .xlsx',
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: '--',
                              hintStyle: TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 42),
                      child: InkWell(
                        onTap: () async {
                          // Open file picker
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: ['csv', 'xlsx'],
                          );
                          // Check if a file was selected
                          if (result != null) {
                            setState(() {
                              // Update the 'source' variable with the selected file path

                              targetData = readFile(result);
                              target = result.files.single.name;
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
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
                    onPressed: () async {
                      // Implement 'Validate' functionality
                      // Assuming your Python server is running on http://localhost:4564
                      final url = Uri.parse('http://localhost:4564/findKeys');

                      try {
                        final response = await http.post(
                          url,
                          body: {'source': sourceData, 'target': targetData},
                        );

                        if (response.statusCode == 200) {
                          print('Validation successful! ');

                          final Map<String, dynamic> data =
                              jsonDecode(response.body);

                          // Access the 'primarykey' value
                          setState(() {
                            var srcpk = data['sourcePrimaryKey'].toString();
                            var trgpk = data['targetPrimaryKey'].toString();
                            _resultController.text =
                                '${_resultController.text}Primary Key of source: ${srcpk}\nPrimary Key of Target: ${trgpk}\n';
                          });
                        } else {
                          print('Validation failed: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error during validation: $e');
                      }
                    },
                    child: Align(
                        alignment: Alignment.center, child: Text('Validate')),
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
                Container(
                  alignment: AlignmentDirectional.topStart,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(bottom: 11, top: 104),
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
                    onPressed: () async {
                      // Implement 'Validate' functionality
                      // Assuming your Python server is running on http://localhost:4564
                      final url = Uri.parse('http://localhost:4564/mapData');

                      try {
                        final response = await http.post(
                          url,
                          body: {'source': sourceData, 'target': targetData},
                        );

                        if (response.statusCode == 200) {
                          print('Mapping successful! ');

                          final Map<String, dynamic> data =
                              jsonDecode(response.body);

                          // Access the 'primarykey' value
                          setState(() {
                            var mapingDoc = data['MapingDoc'].toString();
                            var mapingStatus = data['message'].toString();

                            _resultController.text =
                                'Maping status ${mapingStatus}\nResult:\n${mapingDoc}\n';
                          });
                        } else {
                          print('maping failed: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error during maping: $e');
                      }
                    },
                    child: Text('Download'),
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
