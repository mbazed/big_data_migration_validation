import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MyCustomDropdown<T> extends StatefulWidget {
  late final String selectedMode;
  final Function(String) onModeChanged;

  MyCustomDropdown({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

final List<String> _list = [
  'File Mode',
  'MySQL',
  'Oracle DB',
  'MongoDB'

  // Add other items as needed
];

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

class _CustomDropdownState extends State<MyCustomDropdown> {
// Use local variable to track selected mode

  @override
  void initState() {
    super.initState();
// Initialize selected mode
  }

  List<String> getModifiedList() {
    return widget.selectedMode == 'File Mode' ? _list.sublist(1) : _list;
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      canCloseOutsideBounds: true,
      decoration: CustomDropdownDecoration(
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontFamily: "Inter",
          fontWeight: FontWeight.w600,
        ),
        expandedBorderRadius: BorderRadius.circular(8.0),
        expandedBorder: Border.all(
          color: Color(0xFF3A4F39),
          width: 2,
        ),
        closedBorderRadius: BorderRadius.circular(8.0),
        closedBorder: Border.all(
          color: Color(0xFF3A4F39),
          width: 2,
        ),
      ),
      listItemBuilder: (BuildContext context, dynamic item, bool isSelected,
          Function() onItemSelect) {
        Widget iconOrImage = getIconOrImage(item);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      headerBuilder: (BuildContext context, String? selectedItem) {
        Widget iconOrImage = getIconOrImage(selectedItem);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                color: Colors.black.withOpacity(0.5),
                fontSize: 14,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600, // Set the desired font size
              ),
            )
          ],
        );
      },
      hintText: widget.selectedMode,
      hintBuilder: (BuildContext context, String hint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600, // Set the desired font size
              ),
            ),
            Text(
              'Source',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 14,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600, // Set the desired font size
              ),
            )
          ],
        );
      },
      items: getModifiedList(),
      onChanged: (String? newValue) {
        setState(() {
          widget.onModeChanged(newValue!);
        });
      },
    );
  }
}

class FileMode extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController resultController;
  final Function(FilePickerResult?) onFilePickerResult;
  late final String firstButtonText;
  final String title;
  final double width100;

  FileMode(
      {required this.controller,
      required this.resultController,
      required this.firstButtonText,
      required this.title,
      required this.width100,
      required this.onFilePickerResult});

  @override
  _FileModeState createState() => _FileModeState();
}

class _FileModeState extends State<FileMode> {
  late String source;
  late FilePickerResult? resultPicker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 10),
              child: Container(
                width: widget.width100,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  'Supported file types: .csv, .xlsx',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
              width: widget.width100,
              child: TextField(
                controller: widget.controller,
                style: TextStyle(),
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () async {
                        resultPicker = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['csv', 'xlsx', 'xls'],
                        );
                        widget.onFilePickerResult(resultPicker);
                      },
                      child: Icon(
                        Icons.drive_folder_upload_rounded,
                        size: widget.width100 * 0.06,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: '--',
                  hintStyle: TextStyle(),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class BuildTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String>? onChanged;
  final double width100;

  const BuildTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.onChanged,
    required this.width100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class BuildPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String>? onChanged;
  final double width100;

  const BuildPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.onChanged,
    required this.width100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: true,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.visibility_off),
          ),
        ),
      ),
    );
  }
}

class RowContainer extends StatelessWidget {
  final List<Widget> children;
  final double width100;

  const RowContainer({
    Key? key,
    required this.children,
    required this.width100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: child,
                ))
            .toList(),
      ),
    );
  }
}

class ModeFields extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController userController;
  final TextEditingController passController;
  final TextEditingController dbNameController;
  final TextEditingController tableController;
  final double width100;
  final String labelTextPrefix;

  const ModeFields({
    Key? key,
    required this.hostController,
    required this.userController,
    required this.passController,
    required this.dbNameController,
    required this.tableController,
    required this.width100,
    required this.labelTextPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RowContainer(
      width100: width100,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuildTextField(
                controller: hostController,
                labelText: '$labelTextPrefix Host',
                width100: width100),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuildTextField(
                controller: userController,
                labelText: '$labelTextPrefix Username',
                width100: width100 * 0.475),
            BuildPasswordField(
                controller: passController,
                labelText: '$labelTextPrefix Password',
                width100: width100 * 0.475),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuildTextField(
                controller: dbNameController,
                labelText: '$labelTextPrefix Database Name',
                width100: width100 * 0.475),
            BuildTextField(
                controller: tableController,
                labelText: '$labelTextPrefix Table Name',
                width100: width100 * 0.475)
          ],
        ),
      ],
    );
  }
}

Widget buildTextWidget(String text, bool isActive, double size) {
  return Text(
    text,
    style: TextStyle(
      color: isActive ? Colors.black : Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: size * 0.0079,
    ),
  );
}
