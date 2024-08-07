import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:millenium/config/server.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<File> _images = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please upload images of the problem!',
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${Config.baseUrl}/clients/tickets.php'),
        );
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['company_name'] = _companyController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['date'] = _dateController.text;

        for (var image in _images) {
          request.files
              .add(await http.MultipartFile.fromPath('images[]', image.path));
        }

        final response = await request.send();
        final responseData = await http.Response.fromStream(response);
        final data = json.decode(responseData.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ticket Raised Successful and Email Notification sent to Technical!',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Clear all the fields after a successful submission.
          _nameController.clear();
          _emailController.clear();
          _companyController.clear();
          _descriptionController.clear();
          _dateController.clear();
          setState(() {
            _images = [];
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
          'Raise a Ticket to Technical Team',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.normal),
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
                      "We're here to offer Support, Please raise a Ticket to Technical Team!",
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
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Company Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _companyController,
                    hintText: 'Enter Your Company Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTextField(
                    controller: _descriptionController,
                    hintText: 'Enter Description of the Problem',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description of the problem';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dateController,
                        hintText: 'Pick a Date(e.g Today)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please pick a date';
                          }
                          return null;
                        },
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          size: 40,
                          color: Color(0xFF35C2C1),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Image Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _pickImages,
                        child: Text(
                          'Upload an Image of the sort!',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _images.isNotEmpty
                          ? Wrap(
                              spacing: 10,
                              children: _images.map((image) {
                                return Stack(
                                  children: [
                                    Image.file(
                                      image,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _images.remove(image);
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : const Text('No images selected!'),
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
                          height: 45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: _isLoading ? null : submitComplaint,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                )
                              : Text(
                                  'Raise a Ticket',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
