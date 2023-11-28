import 'package:flutter/material.dart';
import 'package:sjuapp/global_vars.dart';
import 'package:sjuapp/user.dart'; // Import your User class
import 'package:sjuapp/user.dart';
import 'login_page.dart'; // Repeated import, should be removed

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sjuIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  String? _userType; // Declare a variable to store the selected user type
  bool _isStudentPressed = false;
  bool _isDriverPressed = false;

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      if (_userType != null) {
        _formKey.currentState!.save();

        final newUser = User(
          id: 0,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dateRegistered: DateTime.now(),
          emailAddress: _emailController.text,
          phoneNumber: _phoneController.text,
          sjuId: _sjuIdController.text,
          password: _passwordController.text,
          authenticated: false,
          userType: _userType!, // Assign the selected user type
        );

        try {
          await User.registerUser(newUser);

          // Display a dialog for account creation confirmation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success!'),
                content: Text('Account Created!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).pop(); // Go back to the previous screen (login page)
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          // Handle registration failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to register. Please try again.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Show error message for no user type selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a user type.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Show error message for invalid information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid information in all fields.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16.0, 16.0, 16.0, MediaQuery.of(context).viewInsets.bottom + 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('First Name', _firstNameController),
                SizedBox(height: 20),
                _buildTextField('Last Name', _lastNameController),
                SizedBox(height: 20),
                _buildTextField('Email Address', _emailController),
                SizedBox(height: 20),
                _buildTextField('Phone Number', _phoneController),
                SizedBox(height: 20),
                _buildTextField('SJU ID', _sjuIdController),
                SizedBox(height: 20),
                _buildTextField('Password', _passwordController, isObscure: true),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userType = 'student';
                          _isStudentPressed = true;
                          _isDriverPressed = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _isStudentPressed ? Colors.redAccent : Colors.red[700],
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('I\'m a Student'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userType = 'driver';
                          _isStudentPressed = false;
                          _isDriverPressed = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _isDriverPressed ? Colors.redAccent : Colors.red[700],
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('I\'m a Driver'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[700],
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label'; // Updated error message
          }
          return null;
        },
      ),
    );
  }
}
