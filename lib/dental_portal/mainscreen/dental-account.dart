import 'dart:io';
import 'package:dental_key/delete_account.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dental_key/dental_portal/authentication/dental_device_change.dart';
import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:dental_key/dental_portal/mainscreen/dental_notifications.dart';
import 'package:dental_key/dental_portal/mainscreen/change_password.dart';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/mainscreen/edit_dental_profile.dart';
import 'package:dental_key/dental_portal/mainscreen/myorders.dart';
import 'package:dental_key/dental_portal/services/career_pathways/CP_myPackages.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/FE_myExams.dart';
import 'package:dental_key/dental_portal/services/ips_books/my_ips_books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/05_UG_myExams.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token management
import 'package:path/path.dart' as p;

class DentalAccount extends StatefulWidget {
  final String accessToken;

  DentalAccount({
    required this.accessToken,
  });

  @override
  _DentalAccountState createState() => _DentalAccountState(
        accessToken: accessToken,
      );
}

class _DentalAccountState extends State<DentalAccount> {
  File? imageFile;
  final picker = ImagePicker();
  final String accessToken;
  String? profilePictureUrl;
  String? fullName;
  String? email;
  String _profilePercentage = '';
  bool _isLoading = true; // Add this line

  _DentalAccountState({required this.accessToken});

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    var uri = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/users/details/");
    var response = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (mounted) {
        setState(() {
          profilePictureUrl = data['profile_picture'];
          fullName = data['full_name'];
          email = data['email'];
          _profilePercentage = data['profile_percentage'].toString();

          _isLoading = false; // Add this line
        });
      }
    } else {
      print("Failed to fetch user profile: ${response.statusCode}");
      setState(() {
        _isLoading = false; // Add this line
      });
    }
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Card(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5.2,
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      child: Column(
                        children: const [
                          Icon(Icons.image, size: 60.0),
                          SizedBox(height: 12.0),
                          Text("Gallery",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black))
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: SizedBox(
                        child: Column(
                          children: const [
                            Icon(Icons.camera_alt, size: 60.0),
                            SizedBox(height: 12.0),
                            Text("Camera",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black))
                          ],
                        ),
                      ),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Image Cropper",
          toolbarColor: Color.fromARGB(255, 0, 116, 174),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: "Image Cropper",
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (croppedFile != null) {
      imageCache.clear();
      if (mounted) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
      }
      await _uploadProfilePicture(imageFile!);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/users/logout/'),
          body: json.encode({'refresh_token': refreshToken}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${prefs.getString('accessToken')}'
          },
        );

        if (response.statusCode == 205) {
          // Successfully logged out, remove tokens from local storage
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');

          // Navigate to the login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginDental()),
          );
        } else {
          // Handle unsuccessful logout attempt
          final Map<String, dynamic> responseData = json.decode(response.body);
          String errorMessage =
              responseData['error'] ?? 'Logout failed. Please try again.';

          // Display error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout Failed'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Handle error during logout process
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // No refresh token found, just clear access token and navigate to login
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginDental()),
      );
    }
  }

  Future<void> _uploadProfilePicture(File file) async {
    var uri = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/users/update-profile-picture/");
    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    print("Uploading profile picture: ${file.path}");

    var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();
    var multipartFile = http.MultipartFile('profile_picture', stream, length,
        filename: p.basename(file.path));
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Profile picture uploaded successfully");
      if (mounted) {
        fetchUserProfile(); // Refresh the profile picture URL after upload
      }
    } else {
      print("Failed to upload profile picture: ${response.statusCode}");
    }
  }

  void _showPictureCriteriaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Profile Picture Requirements"),
          content: Text(
            "Rest assured, your picture will be kept confidential and will not be disclosed. It is part of our verification process using AI detection tools to ensure the security of our application and your data. Please adhere to the following guidelines for your profile picture:\n\n"
            "1. The picture should be front-facing.\n"
            "2. Avoid using passport-style photos.\n"
            "3. After selecting a picture from the gallery or taking a new one with the camera, use the cropping tool to ensure a 1:1 aspect ratio.\n"
            "4. Make sure the picture is taken from an appropriate distance.",
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation!"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("No, Go back"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes, Proceed"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _handleLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Redirect to DentalPortalMain when back button is pressed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => DentalPortalMain(accessToken: accessToken)),
    );
    return false;
  }

  Future<void> refreshpage() async {
    await fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    double profilePercentage = double.tryParse(_profilePercentage) ?? 0.0;
    double percent = profilePercentage / 100.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Account'),
          automaticallyImplyLeading: true, // Hides the back arrow
          centerTitle: false, // Centers the title
          backgroundColor:
              Color(0xFF385A92), // Set the background color of the AppBar
          titleTextStyle: TextStyle(
            color: Colors.white, // Set the text color of the AppBar title
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: refreshpage,
          child: _isLoading // Add this condition
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 150.0,
                              width: 150.0,
                              child: Stack(
                                children: [
                                  imageFile == null && profilePictureUrl == null
                                      ? Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(75.0),
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 0, 0, 0),
                                                width: 5.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2.0,
                                                blurRadius: 5.0,
                                              ),
                                            ],
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/avatar_default.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : imageFile != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(75.0),
                                              child: Image.file(
                                                imageFile!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(75.0),
                                              child: Image.network(
                                                profilePictureUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF385A92),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: IconButton(
                                          onPressed: () async {
                                            showImagePicker(context);
                                          },
                                          icon: Icon(Icons.add_a_photo,
                                              color: Colors.white),
                                          iconSize: 25,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showPictureCriteriaDialog(context);
                                      },
                                      child: Image.asset(
                                        'assets/fonts/help_icon.png', // Ensure the path is correct
                                        width:
                                            30.0, // Set the width of the image
                                        height:
                                            40.0, // Set the height of the image
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (fullName != null && email != null) ...[
                          Text(
                            fullName!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            email!,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 30),
                          LinearPercentIndicator(
                            animation: true,
                            lineHeight: 20.0,
                            animationDuration: 1000,
                            percent: percent,
                            center: Text(
                              '${profilePercentage.toStringAsFixed(0)}%',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor:
                                const Color.fromARGB(255, 11, 200, 108),
                            backgroundColor: Colors.red,
                          ),
                          Center(
                              child: Text(
                            'Profile Completed in Percent',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          )),
                          SizedBox(height: 30),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                                  accessToken: accessToken)));
                                },
                                icon: Icon(Icons.edit, size: 24.0),
                                label: Text('Edit Profile',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChangePasswordScreen(
                                                  accessToken: accessToken)));
                                },
                                icon: Icon(Icons.lock, size: 24.0),
                                label: Text('Change Password',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DentalNotificationPage(
                                                accessToken: accessToken)),
                                  );
                                },
                                icon: Icon(Icons.announcement, size: 24.0),
                                label: Text('Announcements',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyOrdersPage(
                                            accessToken: accessToken)),
                                  );
                                },
                                icon: Icon(Icons.shopping_cart, size: 24.0),
                                label: Text('My Orders',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15),
                          child: Card(
                            color: Color(0xFF385A92),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // Center the Row content
                                      children: [
                                        Text(
                                          'My Store',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .white, // Set text color to white
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                8.0), // Add some spacing between text and icon
                                        Icon(Icons.inventory,
                                            size: 24.0, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildOptionCard(
                                        context,
                                        icon: Icons.book,
                                        label: 'My IPS Books',
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => MyIPS(
                                                      accessToken:
                                                          accessToken)));
                                        },
                                      ),
                                      _buildOptionCard(
                                        context,
                                        icon: Icons.flight,
                                        label: 'My Career Pathway Packages',
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyPackages(
                                                          accessToken:
                                                              accessToken)));
                                        },
                                      ),
                                      _buildOptionCard(
                                        context,
                                        icon: Icons.school,
                                        label: 'My Undergraduate Tests',
                                        onTap: () {
                                          if (email != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UGMyExams(
                                                  accessToken: accessToken,
                                                  email: email!,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Handle the case where email is null, maybe show an error message or a fallback
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Email is required to proceed')),
                                            );
                                          }
                                        },
                                      ),
                                      _buildOptionCard(
                                        context,
                                        icon: Icons.grade,
                                        label: 'My Postgraduate Exams',
                                        onTap: () {
                                          if (email != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MyForeignExams(
                                                  accessToken: accessToken,
                                                  email: email!,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Handle the case where email is null, maybe show an error message or a fallback
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Email is required to proceed')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showConfirmationDialog(context);
                                },
                                icon: Icon(Icons.phone_android, size: 24.0),
                                label: Text('Request Change in Device',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AccountDeletionPage()));
                                },
                                icon: Icon(Icons.delete_forever, size: 24.0),
                                label: Text('Request Account Deletion',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showLogoutConfirmationDialog(context);
                                },
                                icon: Icon(Icons.logout, size: 24.0),
                                label: Text('Log Out',
                                    style: TextStyle(fontSize: 18.0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
              ),
              SizedBox(height: 3.0),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation!"),
          content: Text(
              "Are you sure you want to request a change in device? You will be logged out of the session and have to login again."),
          actions: [
            TextButton(
              child: Text("No, Go back"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes, Proceed"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DentalDeviceChange()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}