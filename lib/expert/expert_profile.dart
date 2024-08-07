import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:millenium/config/server.dart';

class Staff {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String password;
  final String image;

  Staff({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.password,
    required this.image,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'password': password,
      'image': image,
    };
  }
}

class StaffProfileScreen extends StatefulWidget {
  @override
  _StaffProfileScreenState createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  Staff? _staff;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImage;

  Future<void> _fetchStaff(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/staff/expert_profile.php'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('name')) {
          setState(() {
            _staff = Staff.fromJson(data);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile not found!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStaff(Staff staff) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/staff/update_staff.php'),
      );

      request.fields['email'] = staff.email;
      request.fields['name'] = staff.name;
      request.fields['role'] = staff.role;
      request.fields['phone'] = staff.phone;
      request.fields['password'] = staff.password;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      if (data['success']) {
        _fetchStaff(staff.email);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Staff update successful!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
      _clearImageField();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  void _clearImageField() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showEditDialog(Staff staff) {
    final TextEditingController _nameController =
        TextEditingController(text: staff.name);
    final TextEditingController _roleController =
        TextEditingController(text: staff.role);
    final TextEditingController _emailController =
        TextEditingController(text: staff.email);
    final TextEditingController _phoneController =
        TextEditingController(text: staff.phone);
    final TextEditingController _passwordController =
        TextEditingController(text: staff.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Profile.'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Update Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Update Your Role',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  enabled: false,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Update Your Phone No.',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Change Your (Password)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              _selectedImage != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _selectedImage!,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text('No image selected'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedStaff = Staff(
                name: _nameController.text,
                role: _roleController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
                image: _selectedImage?.path.split('/').last ?? staff.image,
              );
              _updateStaff(updatedStaff);
              Navigator.of(context).pop();
            },
            child: Text('Update Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 241, 242, 243),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: const Text(
            "Manage Your Profile",
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
          ),
          centerTitle: false,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _staff == null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Manage Your profile',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFF35C2C1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  'lib/asset/images.png',
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Enter Provide Your Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _fetchStaff(_emailController.text);
                          },
                          child: Text(
                            'Fetch Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(
                              '${Config.baseUrl}/staff/staffs/${_staff!.image}'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _staff!.name,
                          style: TextStyle(
                            fontSize: 23,
                            color: Color(0xFF35C2C1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _staff!.role,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _staff!.email,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _staff!.phone,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                _showEditDialog(_staff!);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
  }
}
