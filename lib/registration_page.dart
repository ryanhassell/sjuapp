import 'package:flutter/material.dart';
import 'package:sjuapp/global_vars.dart';
import 'package:sjuapp/user.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  String? _userType;
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
          userType: _userType!,
        );

        try {
          await User.registerUser(newUser);

          // Log in the user after successful registration
          final response = await http.get(Uri.parse(
              'http://$ip/users/login/${newUser.sjuId}/${newUser.password}'));
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            final userId = jsonResponse['id'] as int;
            final type = jsonResponse['user_type'] as String;

            // Set current_user directly to the user ID and user type
            current_user_id = userId;
            userType = type;

            // Navigate to the main page after successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(title: "Home"),
              ),
            );
          } else {
          }
        } catch (e) {
          // Handle registration failure
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to register. Please try again.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Show error message for no user type selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a user type.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Show error message for invalid information
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        title: const Text('Registration'),
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
                const SizedBox(height: 10),
                const Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('First Name', _firstNameController),
                const SizedBox(height: 20),
                _buildTextField('Last Name', _lastNameController),
                const SizedBox(height: 20),
                _buildTextField('Email Address', _emailController),
                const SizedBox(height: 20),
                _buildTextField('Phone Number', _phoneController),
                const SizedBox(height: 20),
                _buildTextField('SJU ID', _sjuIdController),
                const SizedBox(height: 20),
                _buildTextField('Password', _passwordController, isObscure: true),
                const SizedBox(height: 20),
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
                      child: const Text('I\'m a Student'),
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
                      child: const Text('I\'m a Driver'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[700],
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;

        },
      ),
    );
  }
}

