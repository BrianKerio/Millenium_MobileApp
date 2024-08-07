import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:millenium/config/server.dart';
import 'package:url_launcher/url_launcher.dart';

class Staff {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String image;

  Staff({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.image,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }
}

class StaffScreen extends StatefulWidget {
  @override
  _StaffScreenState createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final List<Staff> _staffList = [];
  bool _isLoading = false;

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${Config.baseUrl}/staff/view_staff.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _staffList.clear();
          for (var item in data) {
            _staffList.add(Staff.fromJson(item));
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed To Load Team Data!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something Went Wrong, Not Your Fault!',
            style:
                TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

// Calling Call and Whatsapp APIs
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'api.whatsapp.com',
      path: 'send',
      queryParameters: {'phone': phoneNumber},
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 241, 242, 243),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Millenium E.A. Team Members",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Divider before fetching team cards
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFF35C2C1),
                          thickness: 3,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFF35C2C1),
                          thickness: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Team cards
                ..._staffList.map((staff) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(
                              '${Config.baseUrl}/staff/staffs/${staff.image}'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_staffList.indexOf(staff) + 1}. ${staff.name}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF35C2C1),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          staff.role,
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          staff.email,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          staff.phone,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.phone_enabled_rounded,
                                color: Colors.grey,
                                size: 40,
                              ),
                              onPressed: () => _makePhoneCall(staff.phone),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.message_rounded,
                                color: Colors.green,
                                size: 40,
                              ),
                              onPressed: () => _openWhatsApp(staff.phone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
