import 'package:flutter/material.dart';
import 'mobile_home.dart';
import 'desktop_home.dart';

class DataValidatorPage extends StatefulWidget {
  const DataValidatorPage({Key? key}) : super(key: key);

  @override
  State<DataValidatorPage> createState() {
    return _DataValidatorPageState();
  }
}

class _DataValidatorPageState extends State<DataValidatorPage> {
  @override
  Widget build(BuildContext context) {
    double widthx = MediaQuery.of(context).size.width;
    double heighty = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: heighty * 0.01,
                  top: heighty * 0.01,
                  right: heighty * 0.02),
              child: Image.asset(
                'assets/images/Vector.png',
                width: heighty * 0.06,
                height: heighty * 0.06,
              ),
            ),
            Text(
              'Data Validator',
              style: TextStyle(
                color: Color(0xFF3A4F39),
                fontSize: maxWidth > 600 ? heighty * 0.065 : widthx * 0.065,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(
              top: heighty * 0.0075,
              bottom: heighty * 0.005,
              right: heighty * 0.01,
            ),
            width: maxWidth >600? heighty * 0.2 : widthx * 0.2,
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
                  fontSize: maxWidth > 600 ? heighty * 0.02 : widthx * 0.03,
                  color: Color(0xFF3A4F39),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop layout
            return DesktopDataValidatorPage();
          } else {
            // Mobile layout
            return MobileDataValidatorPage();
          }
        },
      ),
    );
  }
}
