import 'package:flutter/material.dart';
import 'api_service.dart';

class ReferralsSection extends StatefulWidget {
  final String dependentUuid;

  ReferralsSection({required this.dependentUuid});

  @override
  _ReferralsSectionState createState() => _ReferralsSectionState();
}

class _ReferralsSectionState extends State<ReferralsSection> {
  List<dynamic>? referralsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    try {
      final data = await ApiService.fetchDependentDetails(widget.dependentUuid);
      setState(() {
        referralsData = data['referrals'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching referrals data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : referralsData != null && referralsData!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: referralsData!.map((referral) {
                    return ListTile(
                      leading:
                          Icon(Icons.local_hospital, color: Colors.blueAccent),
                      title:
                          Text(referral['specialist'] ?? "Unknown Specialist"),
                      subtitle:
                          Text("Referred on: ${referral['date'] ?? "N/A"}"),
                    );
                  }).toList(),
                ),
              )
            : Center(child: Text("No Referrals Available"));
  }
}
