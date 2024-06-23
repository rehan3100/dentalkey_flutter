import 'dart:convert';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/mainscreen/join_team.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AIDTeamMembersPage extends StatefulWidget {
  final String accessToken;

  AIDTeamMembersPage({required this.accessToken});

  @override
  _AIDTeamMembersPageState createState() => _AIDTeamMembersPageState();
}

class _AIDTeamMembersPageState extends State<AIDTeamMembersPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> teamMembers = [];
  List<dynamic> countryCabinets = [];
  List<dynamic> institutionalCabinets = [];
  List<dynamic> selectedCountryMembers = [];
  List<dynamic> selectedInstitutionalMembers = [];
  List<dynamic> countries = [];
  List<dynamic> filteredCountryCabinets = [];
  String? selectedCountryId;
  Map<String, dynamic>? myProfile;
  bool isLoading = true;
  String errorMessage = '';
  bool isCountryCabinetSelected = false;
  bool isInstitutionalCabinetSelected = false;
  late TabController _tabController;
  String? selectedCountryCabinetName;
  String? selectedCountryCabinetLogo;
  String? selectedInstitutionalCabinetName;
  TextEditingController searchController = TextEditingController();

  // Define the ranking and department order dictionaries
  final Map<String, int> rankingOrderDict = {
    'President': 1,
    'Vice President': 2,
    'General Secretary': 3,
    'Secretary': 4,
    'Leader': 5,
    'Representative': 6,
    'Task Force Officer': 7,
  };

  final Map<String, int> departmentOrderDict = {
    'Recruitment Department': 9,
    'Education Department': 10,
    'Examination Department': 11,
    'International Exchange Department': 12,
    'Research Department': 13,
    'Coordination Department': 14,
    'Honorary Members Department': 15,
    'Dental Health Department': 16,
    'Treasury Department': 17,
    'Media Department': 18,
    'Editing Department': 19,
    'Designing Department': 20,
    'Communication Department': 21,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData(
        'Association of International Dentistry'); // Default to Core Cabinet
    fetchCountries(); // Fetch countries
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String membershipType) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      selectedCountryMembers = []; // Clear previous selection
    });

    try {
      final profileResponse = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/my_profile/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      final teamResponse = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/filter-members/?membership_type=$membershipType'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (profileResponse.statusCode == 200 && teamResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            myProfile =
                (json.decode(profileResponse.body) as List<dynamic>).first;
            teamMembers = json.decode(teamResponse.body) as List<dynamic>;
            teamMembers.sort((a, b) =>
                _compareMembers(a, b)); // Sort using custom comparator
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/country-cabinets/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            countries = json.decode(response.body) as List<dynamic>;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCountryCabinets() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      selectedCountryMembers = []; // Clear previous selection
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/country-cabinets/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            countryCabinets = json.decode(response.body) as List<dynamic>;
            filteredCountryCabinets = countryCabinets;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchInstitutionalCabinets() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/institutional-cabinets/' +
                (selectedCountryId != null
                    ? '?country_id=$selectedCountryId'
                    : '')),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            institutionalCabinets = json.decode(response.body) as List<dynamic>;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCountryCabinetMembers(String countryCabinetId,
      String countryCabinetName, String countryCabinetLogo) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      selectedCountryCabinetName = countryCabinetName;
      selectedCountryCabinetLogo = countryCabinetLogo;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/filter-country-cabinet-members/$countryCabinetId/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            selectedCountryMembers =
                json.decode(response.body) as List<dynamic>;

            // Print the order of data received from the backend
            print(
                "Order of data received from backend (Country Cabinet Members):");
            for (var member in selectedCountryMembers) {
              print(member['numerical_order']);
            }

            // Ensure sorting on frontend if needed
            selectedCountryMembers.sort((a, b) => _compareMembers(a, b));

            // Print the order of data after sorting
            print("Order of data after sorting (Country Cabinet Members):");
            for (var member in selectedCountryMembers) {
              print(member['numerical_order']);
            }

            isLoading = false;
            isCountryCabinetSelected = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchInstitutionalCabinetMembers(
      String institutionalCabinetId, String institutionalCabinetName) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      selectedInstitutionalCabinetName = institutionalCabinetName;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/filter-institutional-cabinet-members/$institutionalCabinetId/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            selectedInstitutionalMembers =
                json.decode(response.body) as List<dynamic>;

            // Print the order of data received from the backend
            print(
                "Order of data received from backend (Institutional Cabinet Members):");
            for (var member in selectedInstitutionalMembers) {
              print(member['numerical_order']);
            }

            // Ensure sorting on frontend if needed
            selectedInstitutionalMembers.sort((a, b) => _compareMembers(a, b));

            // Print the order of data after sorting
            print(
                "Order of data after sorting (Institutional Cabinet Members):");
            for (var member in selectedInstitutionalMembers) {
              print(member['numerical_order']);
            }

            isLoading = false;
            isInstitutionalCabinetSelected = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load data';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DentalPortalMain(accessToken: widget.accessToken),
        ),
      );
    }
    return false;
  }

  Future<void> refreshPage() async {
    if (!mounted) return;

    switch (_tabController.index) {
      case 0:
        await fetchData('Association of International Dentistry');
        break;
      case 1:
        await fetchCountryCabinets();
        break;
      case 2:
        await fetchInstitutionalCabinets();
        break;
    }
  }

  void resetCountryCabinetSelection() {
    setState(() {
      selectedCountryMembers = [];
      isCountryCabinetSelected = false;
      selectedCountryCabinetName = null;
      selectedCountryCabinetLogo = null;
    });
  }

  void resetInstitutionalCabinetSelection() {
    setState(() {
      selectedInstitutionalMembers = [];
      isInstitutionalCabinetSelected = false;
      fetchInstitutionalCabinets(); // Fetch all institutional cabinets
    });
  }

  void resetCountrySelection() {
    setState(() {
      selectedCountryId = null; // Reset country selection
      selectedInstitutionalMembers = [];
      isInstitutionalCabinetSelected = false;
      fetchInstitutionalCabinets(); // Fetch all institutional cabinets
    });
  }

  void filterCountryCabinets(String query) {
    setState(() {
      filteredCountryCabinets = countryCabinets.where((cabinet) {
        final nicknameLower = (cabinet['cabinet_nickname'] ?? '').toLowerCase();
        final countryLower = (cabinet['country_name'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();

        return nicknameLower.contains(searchLower) ||
            countryLower.contains(searchLower);
      }).toList();
    });
  }

  int _compareMembers(Map<String, dynamic> a, Map<String, dynamic> b) {
    final int rankOrderA = rankingOrderDict[a['ranking']] ?? 999;
    final int rankOrderB = rankingOrderDict[b['ranking']] ?? 999;

    if (rankOrderA != rankOrderB) {
      return rankOrderA.compareTo(rankOrderB);
    }

    final int deptOrderA = departmentOrderDict[a['department']] ?? 999;
    final int deptOrderB = departmentOrderDict[b['department']] ?? 999;

    return deptOrderA.compareTo(deptOrderB);
  }

  void _showMemberDetailsDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (member['profile_image'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(member['profile_image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 300,
                    ),
                  ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    member['name'],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (member['membership_type'] != null)
                  Text('Member of ${member['membership_type']}'),
                if (member['ranking'] != null) Text('${member['ranking']}'),
                if (member['department'] != null)
                  Text('${member['department']}'),
                if (member['year_of_BDS'] != null)
                  Text('Year of BDS: ${member['year_of_BDS']}'),
                if (member['achievements'] != null)
                  Text('Achievements: ${member['achievements']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Our Cabinets'),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinTeam()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Core'),
              Tab(text: 'Country'),
              Tab(text: 'Institutional'),
            ],
            onTap: (index) {
              setState(() {
                isCountryCabinetSelected = false;
                selectedCountryCabinetName = null;
                selectedCountryCabinetLogo = null;
                selectedCountryMembers = [];
                filteredCountryCabinets = [];

                isInstitutionalCabinetSelected = false;
                selectedInstitutionalCabinetName = null;
                selectedInstitutionalMembers = [];
                selectedCountryId =
                    null; // Reset country selection for institutional

                // Additionally reset team members and profile for Core tab
                teamMembers = [];
                myProfile = null;
              });

              switch (index) {
                case 0:
                  fetchData('Association of International Dentistry');
                  break;
                case 1:
                  fetchCountryCabinets();
                  break;
                case 2:
                  fetchInstitutionalCabinets();
                  break;
              }
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: refreshPage,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        buildTeamMembersListView(),
                        buildCountryCabinetListView(),
                        buildInstitutionalCabinetListView(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget buildTeamMembersListView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (myProfile != null) buildMyProfileCard(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              final isOdd = index % 2 == 1;

              return Card(
                color: isOdd ? Colors.grey[200] : Colors.grey[700],
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isOdd)
                        ClipOval(
                          child: member['profile_image'] != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: member['profile_image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person,
                                  size: 100, color: Colors.grey),
                        ),
                      if (!isOdd) SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'],
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: isOdd ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5.0),
                            if (member['position_type'] != null &&
                                member['ranking'] != null)
                              Text(
                                '${member['ranking']} (${member['position_type']})',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: isOdd ? Colors.black : Colors.white,
                                ),
                              ),
                            SizedBox(height: 5.0),
                            if (member['ranking'] != null &&
                                member['position_type'] == null)
                              Text(
                                '${member['ranking']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: isOdd ? Colors.black : Colors.white,
                                ),
                              ),
                            if (member['department'] != null)
                              Text(
                                '${member['department']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: isOdd ? Colors.black : Colors.white,
                                ),
                              ),
                            if (member['membership_type'] != null)
                              Text(
                                '${member['membership_type']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: isOdd ? Colors.black : Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isOdd) SizedBox(width: 16),
                      if (isOdd)
                        ClipOval(
                          child: member['profile_image'] != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: member['profile_image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person,
                                  size: 100, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCountryCabinetListView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (isCountryCabinetSelected)
            Column(
              children: [
                TextButton(
                  onPressed: resetCountryCabinetSelection,
                  child: Text('Reset'),
                ),
                ListTile(
                  leading: selectedCountryCabinetLogo != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(selectedCountryCabinetLogo!),
                        )
                      : CircleAvatar(child: Icon(Icons.flag)),
                  title: Text(selectedCountryCabinetName ?? ''),
                  subtitle: Text('Selected Country Cabinet'),
                ),
              ],
            ),
          if (!isCountryCabinetSelected) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search by country or organisation name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (query) => filterCountryCabinets(query),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredCountryCabinets.length,
              itemBuilder: (context, index) {
                final cabinet = filteredCountryCabinets[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: cabinet['cabinet_logo'] != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(cabinet['cabinet_logo']),
                          )
                        : CircleAvatar(child: Icon(Icons.flag)),
                    title: Text(cabinet['cabinet_name'] ?? 'No nickname'),
                    subtitle: Text(cabinet['cabinet_nickname']),
                    onTap: () => fetchCountryCabinetMembers(
                        cabinet['country_cabinet_id'],
                        cabinet['cabinet_nickname'],
                        cabinet['cabinet_logo']),
                  ),
                );
              },
            ),
          ],
          if (isCountryCabinetSelected && selectedCountryMembers.isNotEmpty)
            buildSelectedCountryMembersListView(),
        ],
      ),
    );
  }

  Widget buildInstitutionalCabinetListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text("Select Country"),
                        value: selectedCountryId,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryId = newValue;
                            fetchInstitutionalCabinets(); // Fetch filtered institutional cabinets
                          });
                        },
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['country_cabinet_id'],
                            child: Text(country['country_name']),
                          );
                        }).toList(),
                        isExpanded: true,
                        dropdownColor: Colors.lightBlue[50],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: resetCountrySelection,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        setState(() {});
                      },
                      onExit: (event) {
                        setState(() {});
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isInstitutionalCabinetSelected)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(selectedInstitutionalCabinetName ?? ''),
                        subtitle: Text('Selected Institutional Cabinet'),
                      ),
                    ),
                    GestureDetector(
                      onTap: resetInstitutionalCabinetSelection,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (event) {
                          setState(() {});
                        },
                        onExit: (event) {
                          setState(() {});
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (!isInstitutionalCabinetSelected)
          Expanded(
            child: ListView.builder(
              itemCount: institutionalCabinets.length,
              itemBuilder: (context, index) {
                final cabinet = institutionalCabinets[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.school)),
                    title: Text(cabinet['institution_full_name']),
                    subtitle: Text(cabinet['nickname'] ?? 'No nickname'),
                    onTap: () => fetchInstitutionalCabinetMembers(
                        cabinet['institutional_cabinet_id'],
                        cabinet['institution_full_name']),
                  ),
                );
              },
            ),
          ),
        if (isInstitutionalCabinetSelected &&
            selectedInstitutionalMembers.isNotEmpty)
          buildSelectedInstitutionalMembersListView(),
      ],
    );
  }

  Widget buildSelectedCountryMembersListView() {
    print("Order of data being displayed (Country Cabinet Members):");
    for (var member in selectedCountryMembers) {
      print(
          'Name: ${member['name']}, Ranking: ${member['ranking']}, Position: ${member['position_type']}, Department: ${member['department']}');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: selectedCountryMembers.length,
      itemBuilder: (context, index) {
        final member = selectedCountryMembers[index];
        final isOdd = index % 2 == 1;

        return Card(
          color: isOdd ? Colors.grey[200] : Colors.grey[700],
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: isOdd
                ? null
                : (member['profile_image'] != null
                    ? CircleAvatar(
                        radius: 30, // CircleAvatar size
                        backgroundImage: NetworkImage(member['profile_image']),
                      )
                    : CircleAvatar(
                        radius: 30, // CircleAvatar size
                        child: Icon(Icons.person),
                      )),
            trailing: isOdd
                ? (member['profile_image'] != null
                    ? CircleAvatar(
                        radius: 30, // CircleAvatar size
                        backgroundImage: NetworkImage(member['profile_image']),
                      )
                    : CircleAvatar(
                        radius: 30, // CircleAvatar size
                        child: Icon(Icons.person),
                      ))
                : null,
            title: Text(
              member['name'],
              style: TextStyle(
                color: isOdd ? Colors.black : Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member['ranking'] != null)
                  Text(
                    '${member['ranking']}'
                    '${member['department'] != null ? ' (${member['department']})' : ''}',
                    style: TextStyle(
                      color: isOdd ? Colors.black : Colors.white,
                      fontSize: 16.0, // Adjusted font size
                    ),
                  ),
                if (member['cabinet_name'] != null)
                  Text(
                    '${member['cabinet_name']}',
                    style: TextStyle(
                      color: isOdd ? Colors.black : Colors.white,
                      fontSize: 14.0, // Adjusted font size
                    ),
                  ),
              ],
            ),
            onTap: () {
              _showMemberDetailsDialog(member);
            },
          ),
        );
      },
    );
  }

  Widget buildSelectedInstitutionalMembersListView() {
    print("Order of data being displayed (Institutional Cabinet Members):");
    for (var member in selectedInstitutionalMembers) {
      print(
          'Name: ${member['name']}, Ranking: ${member['ranking']}, Position: ${member['position_type']}, Department: ${member['department']}');
    }

    List<Widget> groupedMembers = [];

    // Group members by ranking
    Map<String, List<Map<String, dynamic>>> groupedByRanking = {
      'Representatives': [],
      'Task Force Officers': [],
    };

    for (var member in selectedInstitutionalMembers) {
      if (member['ranking'] == 'Representative' ||
          member['ranking'] == 'Leader') {
        groupedByRanking['Representatives']?.add(member);
      } else if (member['ranking'] == 'Task Force Officer') {
        groupedByRanking['Task Force Officers']?.add(member);
      }
    }

    // Create widgets for each group
    groupedByRanking.forEach((ranking, members) {
      groupedMembers.add(
        Padding(
          padding: const EdgeInsets.only(
              right: 16.0, left: 16.0, top: 15.0, bottom: 0),
          child: Text(
            ranking,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      groupedMembers.addAll(
        members.map((member) {
          final isOdd = members.indexOf(member) % 2 == 1;

          return Card(
            color: isOdd ? Colors.grey[200] : Colors.grey[700],
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: isOdd
                  ? null
                  : (member['profile_image'] != null
                      ? CircleAvatar(
                          radius: 30, // CircleAvatar size
                          backgroundImage:
                              NetworkImage(member['profile_image']),
                        )
                      : CircleAvatar(
                          radius: 30, // CircleAvatar size
                          child: Icon(Icons.person),
                        )),
              trailing: isOdd
                  ? (member['profile_image'] != null
                      ? CircleAvatar(
                          radius: 30, // CircleAvatar size
                          backgroundImage:
                              NetworkImage(member['profile_image']),
                        )
                      : CircleAvatar(
                          radius: 30, // CircleAvatar size
                          child: Icon(Icons.person),
                        ))
                  : null,
              title: Text(
                member['name'],
                style: TextStyle(color: isOdd ? Colors.black : Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (member['membership_type'] != null)
                    Text(
                      'Member of ${member['membership_type']}',
                      style:
                          TextStyle(color: isOdd ? Colors.black : Colors.white),
                    ),
                  if (member['ranking'] != null)
                    Text(
                      '${member['ranking']}',
                      style:
                          TextStyle(color: isOdd ? Colors.black : Colors.white),
                    ),
                  if (member['department'] != null)
                    Text(
                      '${member['department']}',
                      style:
                          TextStyle(color: isOdd ? Colors.black : Colors.white),
                    ),
                  if (member['year_of_BDS'] != null)
                    Text(
                      '${member['year_of_BDS']}',
                      style:
                          TextStyle(color: isOdd ? Colors.black : Colors.white),
                    ),
                ],
              ),
              onTap: () {
                _showMemberDetailsDialog(member);
              },
            ),
          );
        }).toList(),
      );
    });

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: groupedMembers,
    );
  }

  Widget buildMyProfileCard() {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color.fromARGB(255, 0, 61, 104),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: NetworkImage(myProfile!['picture'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    myProfile!['full_name'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    myProfile!['gmail_id'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (myProfile!['positions'] ?? '').split('\n').map<Widget>(
                (position) {
                  return Row(
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          position,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 222, 222, 222),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Color.fromARGB(255, 137, 224, 250),
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    myProfile!['message'] ?? '',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 206, 206, 206),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Color.fromARGB(255, 137, 224, 250),
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (myProfile!['facebook_id'] != null &&
                      myProfile!['facebook_id']!.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.facebook, color: Colors.blue),
                      onPressed: () {
                        _launchUrl(myProfile!['facebook_id']);
                      },
                    ),
                  if (myProfile!['whatsapp_id'] != null &&
                      myProfile!['whatsapp_id']!.isNotEmpty)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.green),
                      onPressed: () {
                        _launchUrl(myProfile!['whatsapp_id']);
                      },
                    ),
                  if (myProfile!['instagram_id'] != null &&
                      myProfile!['instagram_id']!.isNotEmpty)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.instagram,
                          color: Colors.purple),
                      onPressed: () {
                        _launchUrl(myProfile!['instagram_id']);
                      },
                    ),
                  if (myProfile!['youtube_id'] != null &&
                      myProfile!['youtube_id']!.isNotEmpty)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.youtube, color: Colors.red),
                      onPressed: () {
                        _launchUrl(myProfile!['youtube_id']);
                      },
                    ),
                  if (myProfile!['twitter_id'] != null &&
                      myProfile!['twitter_id']!.isNotEmpty)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.twitter,
                          color: Colors.lightBlue),
                      onPressed: () {
                        _launchUrl(myProfile!['twitter_id']);
                      },
                    ),
                  if (myProfile!['whatsapp_other_id'] != null &&
                      myProfile!['whatsapp_other_id']!.isNotEmpty)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.green),
                      onPressed: () {
                        _launchUrl(myProfile!['whatsapp_other_id']);
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
}
