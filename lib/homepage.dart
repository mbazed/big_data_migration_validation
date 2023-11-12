import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class DataValidatorPage extends StatefulWidget {
  const DataValidatorPage({Key? key}) : super(key: key);

  @override
  State<DataValidatorPage> createState() {
    return _DataValidatorPageState();
  }
}

class _DataValidatorPageState extends State<DataValidatorPage> {
  String selectedMode = 'File Mode';
  String source = '';
  String target = '';

  // Use your _list here
  final List<String> _list = [
    'File Mode',
    'Database Mode',
    // Add other items as needed
  ];

  @override
  Widget build(BuildContext context) {
    double width100 = MediaQuery.of(context).size.width * 0.35;
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 15),
              child: Image.asset(
                'assets/images/Vector.png',
                width: 46,
                height: 46,
              ),
            ),
            Text(
              'Data Validator',
              style: TextStyle(
                color: Color(0xFF3A4F39),
                fontSize: 32,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 4, top: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.15,
              child: ElevatedButton(
                onPressed: () {
                  // Implement 'About' functionality
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color(0xFF3A4F39),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  'ABOUT',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3A4F39),
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          alignment: AlignmentDirectional.topStart,
                          width: width100,
                          padding: EdgeInsets.only(bottom: 10),
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          width: width100,
                          child: TextField(
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
                      padding: const EdgeInsets.only(left: 10, top: 29),
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
                    )
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          alignment: AlignmentDirectional.topStart,
                          width: width100,
                          padding: EdgeInsets.only(bottom: 10),
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          width: width100,
                          child: TextField(
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
                      padding: const EdgeInsets.only(left: 10, top: 29),
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
                    )
                  ],
                ),
                SizedBox(height: 32.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4075,
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
                      // Implement 'Validate' functionality
                    },
                    child: Text('Validate'),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.topStart,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(bottom: 11, top: 81),
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
                    height: MediaQuery.of(context).size.height * 0.23,
                    child: TextField(
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
                    onPressed: () {
                      // Implement 'Validate' functionality
                    },
                    child: Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
