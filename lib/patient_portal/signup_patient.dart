import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PatientSignup extends StatefulWidget {
  @override
  _PatientSignupState createState() => _PatientSignupState();
}

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

class Country {
  final String name;
  final String alpha2Code;

  Country({required this.name, required this.alpha2Code});
}

List<Country> allCountries = [
  Country(name: 'Afghanistan', alpha2Code: 'AF'),
  Country(name: 'Albania', alpha2Code: 'AL'),
  Country(name: 'Algeria', alpha2Code: 'DZ'),
  Country(name: 'Andorra', alpha2Code: 'AD'),
  Country(name: 'Angola', alpha2Code: 'AO'),
  Country(name: 'Antigua and Barbuda', alpha2Code: 'AG'),
  Country(name: 'Argentina', alpha2Code: 'AR'),
  Country(name: 'Armenia', alpha2Code: 'AM'),
  Country(name: 'Australia', alpha2Code: 'AU'),
  Country(name: 'Austria', alpha2Code: 'AT'),
  Country(name: 'Azerbaijan', alpha2Code: 'AZ'),
  Country(name: 'Bahamas', alpha2Code: 'BS'),
  Country(name: 'Bahrain', alpha2Code: 'BH'),
  Country(name: 'Bangladesh', alpha2Code: 'BD'),
  Country(name: 'Barbados', alpha2Code: 'BB'),
  Country(name: 'Belarus', alpha2Code: 'BY'),
  Country(name: 'Belgium', alpha2Code: 'BE'),
  Country(name: 'Belize', alpha2Code: 'BZ'),
  Country(name: 'Benin', alpha2Code: 'BJ'),
  Country(name: 'Bhutan', alpha2Code: 'BT'),
  Country(name: 'Bolivia', alpha2Code: 'BO'),
  Country(name: 'Bosnia and Herzegovina', alpha2Code: 'BA'),
  Country(name: 'Botswana', alpha2Code: 'BW'),
  Country(name: 'Brazil', alpha2Code: 'BR'),
  Country(name: 'Brunei', alpha2Code: 'BN'),
  Country(name: 'Bulgaria', alpha2Code: 'BG'),
  Country(name: 'Burkina Faso', alpha2Code: 'BF'),
  Country(name: 'Burundi', alpha2Code: 'BI'),
  Country(name: 'Cabo Verde', alpha2Code: 'CV'),
  Country(name: 'Cambodia', alpha2Code: 'KH'),
  Country(name: 'Cameroon', alpha2Code: 'CM'),
  Country(name: 'Canada', alpha2Code: 'CA'),
  Country(name: 'Central African Republic', alpha2Code: 'CF'),
  Country(name: 'Chad', alpha2Code: 'TD'),
  Country(name: 'Chile', alpha2Code: 'CL'),
  Country(name: 'China', alpha2Code: 'CN'),
  Country(name: 'Colombia', alpha2Code: 'CO'),
  Country(name: 'Comoros', alpha2Code: 'KM'),
  Country(name: 'Congo (Congo-Brazzaville)', alpha2Code: 'CG'),
  Country(name: 'Congo', alpha2Code: 'CD'),
  Country(name: 'Costa Rica', alpha2Code: 'CR'),
  Country(name: 'Croatia', alpha2Code: 'HR'),
  Country(name: 'Cuba', alpha2Code: 'CU'),
  Country(name: 'Cyprus', alpha2Code: 'CY'),
  Country(name: 'Czech Republic', alpha2Code: 'CZ'),
  Country(name: 'Denmark', alpha2Code: 'DK'),
  Country(name: 'Djibouti', alpha2Code: 'DJ'),
  Country(name: 'Dominica', alpha2Code: 'DM'),
  Country(name: 'Dominican Republic', alpha2Code: 'DO'),
  Country(name: 'Ecuador', alpha2Code: 'EC'),
  Country(name: 'Egypt', alpha2Code: 'EG'),
  Country(name: 'El Salvador', alpha2Code: 'SV'),
  Country(name: 'Equatorial Guinea', alpha2Code: 'GQ'),
  Country(name: 'Eritrea', alpha2Code: 'ER'),
  Country(name: 'Estonia', alpha2Code: 'EE'),
  Country(name: 'Eswatini', alpha2Code: 'SZ'),
  Country(name: 'Ethiopia', alpha2Code: 'ET'),
  Country(name: 'Fiji', alpha2Code: 'FJ'),
  Country(name: 'Finland', alpha2Code: 'FI'),
  Country(name: 'France', alpha2Code: 'FR'),
  Country(name: 'Gabon', alpha2Code: 'GA'),
  Country(name: 'Gambia', alpha2Code: 'GM'),
  Country(name: 'Georgia', alpha2Code: 'GE'),
  Country(name: 'Germany', alpha2Code: 'DE'),
  Country(name: 'Ghana', alpha2Code: 'GH'),
  Country(name: 'Greece', alpha2Code: 'GR'),
  Country(name: 'Grenada', alpha2Code: 'GD'),
  Country(name: 'Guatemala', alpha2Code: 'GT'),
  Country(name: 'Guinea', alpha2Code: 'GN'),
  Country(name: 'Guinea-Bissau', alpha2Code: 'GW'),
  Country(name: 'Guyana', alpha2Code: 'GY'),
  Country(name: 'Haiti', alpha2Code: 'HT'),
  Country(name: 'Honduras', alpha2Code: 'HN'),
  Country(name: 'Hungary', alpha2Code: 'HU'),
  Country(name: 'Iceland', alpha2Code: 'IS'),
  Country(name: 'India', alpha2Code: 'IN'),
  Country(name: 'Indonesia', alpha2Code: 'ID'),
  Country(name: 'Iran', alpha2Code: 'IR'),
  Country(name: 'Iraq', alpha2Code: 'IQ'),
  Country(name: 'Ireland', alpha2Code: 'IE'),
  Country(name: 'Israel', alpha2Code: 'IL'),
  Country(name: 'Italy', alpha2Code: 'IT'),
  Country(name: 'Ivory Coast', alpha2Code: 'CI'),
  Country(name: 'Jamaica', alpha2Code: 'JM'),
  Country(name: 'Japan', alpha2Code: 'JP'),
  Country(name: 'Jordan', alpha2Code: 'JO'),
  Country(name: 'Kazakhstan', alpha2Code: 'KZ'),
  Country(name: 'Kenya', alpha2Code: 'KE'),
  Country(name: 'Kiribati', alpha2Code: 'KI'),
  Country(name: 'Kosovo', alpha2Code: 'XK'),
  Country(name: 'Kuwait', alpha2Code: 'KW'),
  Country(name: 'Kyrgyzstan', alpha2Code: 'KG'),
  Country(name: 'Laos', alpha2Code: 'LA'),
  Country(name: 'Latvia', alpha2Code: 'LV'),
  Country(name: 'Lebanon', alpha2Code: 'LB'),
  Country(name: 'Lesotho', alpha2Code: 'LS'),
  Country(name: 'Liberia', alpha2Code: 'LR'),
  Country(name: 'Libya', alpha2Code: 'LY'),
  Country(name: 'Liechtenstein', alpha2Code: 'LI'),
  Country(name: 'Lithuania', alpha2Code: 'LT'),
  Country(name: 'Luxembourg', alpha2Code: 'LU'),
  Country(name: 'Madagascar', alpha2Code: 'MG'),
  Country(name: 'Malawi', alpha2Code: 'MW'),
  Country(name: 'Malaysia', alpha2Code: 'MY'),
  Country(name: 'Maldives', alpha2Code: 'MV'),
  Country(name: 'Mali', alpha2Code: 'ML'),
  Country(name: 'Malta', alpha2Code: 'MT'),
  Country(name: 'Marshall Islands', alpha2Code: 'MH'),
  Country(name: 'Mauritania', alpha2Code: 'MR'),
  Country(name: 'Mauritius', alpha2Code: 'MU'),
  Country(name: 'Mexico', alpha2Code: 'MX'),
  Country(name: 'Micronesia', alpha2Code: 'FM'),
  Country(name: 'Moldova', alpha2Code: 'MD'),
  Country(name: 'Monaco', alpha2Code: 'MC'),
  Country(name: 'Mongolia', alpha2Code: 'MN'),
  Country(name: 'Montenegro', alpha2Code: 'ME'),
  Country(name: 'Morocco', alpha2Code: 'MA'),
  Country(name: 'Mozambique', alpha2Code: 'MZ'),
  Country(name: 'Myanmar (formerly Burma)', alpha2Code: 'MM'),
  Country(name: 'Namibia', alpha2Code: 'NA'),
  Country(name: 'Nauru', alpha2Code: 'NR'),
  Country(name: 'Nepal', alpha2Code: 'NP'),
  Country(name: 'Netherlands', alpha2Code: 'NL'),
  Country(name: 'New Zealand', alpha2Code: 'NZ'),
  Country(name: 'Nicaragua', alpha2Code: 'NI'),
  Country(name: 'Niger', alpha2Code: 'NE'),
  Country(name: 'Nigeria', alpha2Code: 'NG'),
  Country(name: 'North Korea', alpha2Code: 'KP'),
  Country(name: 'North Macedonia', alpha2Code: 'MK'),
  Country(name: 'Norway', alpha2Code: 'NO'),
  Country(name: 'Oman', alpha2Code: 'OM'),
  Country(name: 'Pakistan', alpha2Code: 'PK'),
  Country(name: 'Palau', alpha2Code: 'PW'),
  Country(name: 'Palestine State', alpha2Code: 'PS'),
  Country(name: 'Panama', alpha2Code: 'PA'),
  Country(name: 'Papua New Guinea', alpha2Code: 'PG'),
  Country(name: 'Paraguay', alpha2Code: 'PY'),
  Country(name: 'Peru', alpha2Code: 'PE'),
  Country(name: 'Philippines', alpha2Code: 'PH'),
  Country(name: 'Poland', alpha2Code: 'PL'),
  Country(name: 'Portugal', alpha2Code: 'PT'),
  Country(name: 'Qatar', alpha2Code: 'QA'),
  Country(name: 'Romania', alpha2Code: 'RO'),
  Country(name: 'Russia', alpha2Code: 'RU'),
  Country(name: 'Rwanda', alpha2Code: 'RW'),
  Country(name: 'Saint Kitts and Nevis', alpha2Code: 'KN'),
  Country(name: 'Saint Lucia', alpha2Code: 'LC'),
  Country(name: 'Saint Vincent and the Grenadines', alpha2Code: 'VC'),
  Country(name: 'Samoa', alpha2Code: 'WS'),
  Country(name: 'San Marino', alpha2Code: 'SM'),
  Country(name: 'Sao Tome and Principe', alpha2Code: 'ST'),
  Country(name: 'Saudi Arabia', alpha2Code: 'SA'),
  Country(name: 'Senegal', alpha2Code: 'SN'),
  Country(name: 'Serbia', alpha2Code: 'RS'),
  Country(name: 'Seychelles', alpha2Code: 'SC'),
  Country(name: 'Sierra Leone', alpha2Code: 'SL'),
  Country(name: 'Singapore', alpha2Code: 'SG'),
  Country(name: 'Slovakia', alpha2Code: 'SK'),
  Country(name: 'Slovenia', alpha2Code: 'SI'),
  Country(name: 'Solomon Islands', alpha2Code: 'SB'),
  Country(name: 'Somalia', alpha2Code: 'SO'),
  Country(name: 'South Africa', alpha2Code: 'ZA'),
  Country(name: 'South Korea', alpha2Code: 'KR'),
  Country(name: 'South Sudan', alpha2Code: 'SS'),
  Country(name: 'Spain', alpha2Code: 'ES'),
  Country(name: 'Sri Lanka', alpha2Code: 'LK'),
  Country(name: 'Sudan', alpha2Code: 'SD'),
  Country(name: 'Suriname', alpha2Code: 'SR'),
  Country(name: 'Sweden', alpha2Code: 'SE'),
  Country(name: 'Switzerland', alpha2Code: 'CH'),
  Country(name: 'Syria', alpha2Code: 'SY'),
  Country(name: 'Tajikistan', alpha2Code: 'TJ'),
  Country(name: 'Tanzania', alpha2Code: 'TZ'),
  Country(name: 'Thailand', alpha2Code: 'TH'),
  Country(name: 'Timor-Leste', alpha2Code: 'TL'),
  Country(name: 'Togo', alpha2Code: 'TG'),
  Country(name: 'Tonga', alpha2Code: 'TO'),
  Country(name: 'Trinidad and Tobago', alpha2Code: 'TT'),
  Country(name: 'Tunisia', alpha2Code: 'TN'),
  Country(name: 'Turkey', alpha2Code: 'TR'),
  Country(name: 'Turkmenistan', alpha2Code: 'TM'),
  Country(name: 'Tuvalu', alpha2Code: 'TV'),
  Country(name: 'Uganda', alpha2Code: 'UG'),
  Country(name: 'Ukraine', alpha2Code: 'UA'),
  Country(name: 'United Arab Emirates', alpha2Code: 'AE'),
  Country(name: 'United Kingdom', alpha2Code: 'GB'),
  Country(name: 'United States of America', alpha2Code: 'US'),
  Country(name: 'Uruguay', alpha2Code: 'UY'),
  Country(name: 'Uzbekistan', alpha2Code: 'UZ'),
  Country(name: 'Vanuatu', alpha2Code: 'VU'),
  Country(name: 'Vatican City', alpha2Code: 'VA'),
  Country(name: 'Venezuela', alpha2Code: 'VE'),
  Country(name: 'Vietnam', alpha2Code: 'VN'),
  Country(name: 'Yemen', alpha2Code: 'YE'),
  Country(name: 'Zambia', alpha2Code: 'ZM'),
  Country(name: 'Zimbabwe', alpha2Code: 'ZW'),
];

class _PatientSignupState extends State<PatientSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = 'US'; // Initial country code
  String _phoneNumber = ''; // Variable to store phone number

  @override
  Widget build(BuildContext context) {
    double fem = 1.0; // Placeholder value for fem
    double ffem = 1.0; // Placeholder value for ffem
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.fromLTRB(0 * fem, 6 * fem, 0 * fem, 0 * fem),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xff5a5a5a)),
              color: Color(0xff385a92),
              borderRadius: BorderRadius.circular(45 * fem),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color:
                      Color(0xff385a92), // Add this line to give the blue color
                  width: double
                      .infinity, // Set the width to span full device width
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 12 * fem),
                  padding:
                      EdgeInsets.fromLTRB(0 * fem, 25 * fem, 95.56 * fem, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color:
                      Color(0xff385a92), // Add this line to give the blue color
                  width: double
                      .infinity, // Set the width to span full device width
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 5),
                        width: 150 * fem,
                        height: 200 * fem,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15 * fem),
                          child: Image.asset(
                            'assets/images/patientportalclicked.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rest of your widgets...
                Container(
                  margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0),
                  color: Color.fromARGB(255, 255, 255,
                      255), // Add this line to give the blue color
                  width: double
                      .infinity, // Set the width to span full device width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 20 * fem, 0 * fem, 0 * fem),
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 30 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.2125 * ffem / fem,
                            letterSpacing: -0.45 * fem,
                            color: Color(0xff385a92),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20 * fem, 0 * fem, 20 * fem,
                            20 * fem), // Add margin around the form
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _fullNameController,
                                decoration:
                                    InputDecoration(labelText: 'Full Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                controller: _emailController,
                                decoration:
                                    InputDecoration(labelText: 'Email Address'),
                                keyboardType: TextInputType.emailAddress,
                                validator: EmailValidator
                                    .validate, // Using the custom validator
                              ),
                              SizedBox(height: 20.0),
                              InternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber number) {
                                  print(number.phoneNumber);
                                  // Update the phone number
                                  _phoneNumber = number.phoneNumber!;
                                },
                                inputDecoration: InputDecoration(
                                  labelText: 'WhatsApp Contact Number',
                                ),
                                selectorConfig: SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DIALOG,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle:
                                    TextStyle(color: Colors.black),
                                initialValue:
                                    PhoneNumber(isoCode: _selectedCountryCode),
                                textFieldController: TextEditingController(),
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        } else if (value.length < 8) {
                                          return 'Password must be at least 8 characters long';
                                        } else if (!RegExp(r'.*[A-Z].*')
                                            .hasMatch(value)) {
                                          return 'At least one uppercase letter';
                                        } else if (!RegExp(r'.*[a-z].*')
                                            .hasMatch(value)) {
                                          return 'At least one lowercase letter';
                                        } else if (!RegExp(r'.*[0-9].*')
                                            .hasMatch(value)) {
                                          return 'At least one digit';
                                        } else if (!RegExp(r'.*[!@#\$&*~].*')
                                            .hasMatch(value)) {
                                          return 'At least one special character';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Add some space between TextFormField and helper text
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character',
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  } else if (value !=
                                      _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // All fields are validated, proceed with signup
                                    // You can implement signup logic here
                                    // For demonstration purposes, just print the form data
                                    print(
                                        'Full Name: ${_fullNameController.text}');
                                    print(
                                        'Email Address: ${_emailController.text}');
                                    print('Phone Number: $_phoneNumber');
                                    print(
                                        'Password: ${_passwordController.text}');
                                    print(
                                        'Confirm Password: ${_confirmPasswordController.text}');
                                  }
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
