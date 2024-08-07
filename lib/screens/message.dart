import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:millenium/config/server.dart';

class MessageUsScreen extends StatefulWidget {
  const MessageUsScreen({Key? key}) : super(key: key);

  @override
  _MessageUsScreenState createState() => _MessageUsScreenState();
}

class _MessageUsScreenState extends State<MessageUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _rating = 0;

  Future<void> submitMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}/clients/message.php'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'message': _messageController.text,
            'rating': _rating.toString(),
          }),
        );

        final data = json.decode(response.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Message Sent to Millenium Admin!',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the fields
          _nameController.clear();
          _phoneController.clear();
          _emailController.clear();
          _messageController.clear();
          setState(() {
            _rating = 0;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something Went Wrong, Not Your Fault!',
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = index;
        });
      },
      child: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 242, 243),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Message Millenium',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1.0,
                    child: const Text(
                      "We're here to assist you, Talk to Us and Give us a 5 Star Rating!",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF35C2C1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _nameController,
                    hintText: 'Enter Your Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // phone Number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _phoneController,
                    hintText: 'Enter Your Phone number.',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Your Phone Number Must be 10 Numbers';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _emailController,
                    hintText: 'Enter Your Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _messageController,
                    hintText: 'Enter Your Message',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Rating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Text(
                        "Rate Millenium!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF35C2C1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(5, (index) => _buildStar(index + 1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Submit button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          color: Color(0xFF35C2C1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: _isLoading ? null : submitMessage,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  )
                                : Text(
                                    "Message Us",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        border: Border.all(
          color: const Color(0xFFE8ECF4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8391A1),
            ),
            suffixIcon: suffixIcon,
          ),
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
        ),
      ),
    );
  }
}
