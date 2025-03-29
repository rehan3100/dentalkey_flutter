import 'package:dental_key/marketplace/practices_network/intro_register.dart';
import 'package:flutter/material.dart';
// Add other imports when creating screens for Suppliers & Organisations

class MarketplaceSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Dental Organizations Card
            _buildCategoryCard(
              context,
              title: "Dental Organizations",
              icon: Icons.groups_rounded,
              description:
                  "Register your dental association, research institute, or NGO.",
              onTap: () {
                // Navigate to respective registration screen (to be created)
                // Navigator.push(context, MaterialPageRoute(builder: (context) => DentalOrganisationRegisterScreen()));
              },
            ),

            // 🔹 Dental Practice Companies Card
            _buildCategoryCard(
              context,
              title: "Dental Practice Company",
              icon: Icons.local_hospital_rounded,
              description:
                  "Register your dental clinic, hospital, or chain of practices.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DentalPracticeIntroScreen()),
                );
              },
            ),

            // 🔹 Dental Materials Suppliers Card
            _buildCategoryCard(
              context,
              title: "Dental Materials Supplier",
              icon: Icons.storefront_rounded,
              description:
                  "Register as a supplier of dental materials, tools, and equipment.",
              onTap: () {
                // Navigate to respective registration screen (to be created)
                // Navigator.push(context, MaterialPageRoute(builder: (context) => DentalSupplierRegisterScreen()));
              },
            ),

            // Additional Ideas (Commented for Now)
            /*
            _buildCategoryCard(
              context,
              title: "Dental Equipment Manufacturer",
              icon: Icons.precision_manufacturing,
              description: "Register as a manufacturer of dental tools and machines.",
              onTap: () {
                // Navigate to respective screen
              },
            ),

            _buildCategoryCard(
              context,
              title: "Dental Labs",
              icon: Icons.science,
              description: "Register as a dental lab for prosthetics and aligners.",
              onTap: () {
                // Navigate to respective screen
              },
            ),
            */
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Function to Build Category Cards
  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required IconData icon,
      required String description,
      required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
