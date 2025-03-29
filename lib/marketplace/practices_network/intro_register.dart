import 'package:dental_key/marketplace/practices_network/owners_authentication/login.dart';
import 'package:dental_key/marketplace/practices_network/owners_authentication/register.dart';
import 'package:flutter/material.dart';

class DentalPracticeIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dental Practice Registration"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 🔹 Page Introduction
          _buildHeader(),

          // 🔹 Animated Sign Up & Login Cards
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildAnimatedCard(
                    title: "Sign Up",
                    description:
                        "Register your dental practice and manage appointments, staff, and patient records.",
                    icon: Icons.app_registration_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayMyPracticeScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildAnimatedCard(
                    title: "Login",
                    description:
                        "Already registered? Log in to manage your dental practice dashboard.",
                    icon: Icons.login_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OwnerLoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Header with Introduction
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Colors.blue.shade50, // Light background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to the Dental Practices Network!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Register your dental clinic, hospital, or group of practices to get access to modern tools for patient management, staff coordination, and business growth.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // 🔹 Reusable Animated Card for Sign Up & Login
  Widget _buildAnimatedCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
