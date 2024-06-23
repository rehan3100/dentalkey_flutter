import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:flutter/material.dart';

class Modaldkl extends StatefulWidget {
  final String accessToken;

  Modaldkl({required this.accessToken});

  @override
  _ModaldklState createState() => _ModaldklState();
}

class _ModaldklState extends State<Modaldkl> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      width: double.infinity, // 80% of the screen width
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF004D7C).withOpacity(1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome to our Free Medical and Dental Books Library!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Explore our vast collection of medical and dental resources, all available to you for free. Whether you\'re a student, professional, or simply curious, our library offers a wide range of textbooks, reference materials, and guides covering various medical and dental disciplines. From anatomy and pharmacology to dental surgery and orthodontics, our collection is meticulously curated to support your learning and professional development.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 10),
            Text(
              'Can\'t find a specific book or article? No problem! You can request any book or article, and our team will do our best to add it to the library. Additionally, users can contribute to our library by uploading materials, expanding our resources and helping the community access even more valuable content.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 10),
            Text(
              'Enjoy unlimited access to high-quality educational resources without any cost. Start exploring our library today and take your medical and dental knowledge to the next level!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 24.0),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DKLlibrary(accessToken: widget.accessToken),
                    ),
                  );
                  // Add your login function here
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Color(0xFF004D7C); // Change to your desired color
                    return Color.fromARGB(
                        255, 255, 255, 255); // Use the default color
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          18.0), // Add your desired border radius here
                      side: BorderSide(
                          color: const Color.fromARGB(255, 255, 255,
                              255)), // Add your desired border color here
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors
                            .white; // Change to your desired text color when pressed
                      return Color(0xFF004D7C); // Use the default text color
                    },
                  ),
                ),
                child: Text(
                  'Read Books & Articles',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
