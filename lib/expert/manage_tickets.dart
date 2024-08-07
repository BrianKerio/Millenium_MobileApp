import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:millenium/config/server.dart';

class Ticket {
  final int id;
  final String name;
  final String email;
  final String companyName;
  final String description;
  final String date;
  final List<String> images;

  Ticket({
    required this.id,
    required this.name,
    required this.email,
    required this.companyName,
    required this.description,
    required this.date,
    required this.images,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      name: json['name'],
      email: json['email'],
      companyName: json['company_name'],
      description: json['description'],
      date: json['date'],
      images: List<String>.from(json['images']),
    );
  }
}

class ManageTicketsScreen extends StatefulWidget {
  @override
  _ManageTicketsScreenState createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen> {
  late Future<List<Ticket>> _futureTickets;

  @override
  void initState() {
    super.initState();
    _futureTickets = fetchTickets();
  }

  Future<List<Ticket>> fetchTickets() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/clients/get_ticket.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((ticket) => Ticket.fromJson(ticket)).toList();
    } else {
      throw Exception('Failed to load Tickets');
    }
  }

  Future<void> deleteTicket(int id) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/clients/delete_ticket.php'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureTickets = fetchTickets();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Ticket Sorted & deleted successful',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete Ticket')));
    }
  }

  void _showDeleteConfirmationDialog(int ticketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteTicket(ticketId);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                    '${Config.baseUrl}/clients/uploads/${images[index]}'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: index),
            onPageChanged: (index) {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 241, 242, 243),
        title: Text(
          'Manage Raised Tickets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _futureTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No Tickets Found!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color(0xFF35C2C1),
              ),
            ));
          }

          List<Ticket> tickets = snapshot.data!;
          tickets.sort((a, b) => a.date.compareTo(b.date));

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              Ticket ticket = tickets[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    '${index + 1}.${ticket.name}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF35C2C1),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    "Partner's Name : ${ticket.companyName}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.orange,
                    ),
                    onPressed: () => _showDeleteConfirmationDialog(ticket.id),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Customer: ${ticket.name}'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Card(
                              child: ListTile(
                                title: Text('Email: ${ticket.email}'),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              child: ListTile(
                                title: Text(
                                    "Partner's Name: ${ticket.companyName}"),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              child: ListTile(
                                title:
                                    Text('Description: ${ticket.description}'),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              child: ListTile(
                                title: Text('Date Raised: ${ticket.date}'),
                              ),
                            ),
                            SizedBox(height: 10),
                            ...ticket.images.map((image) {
                              return GestureDetector(
                                onTap: () => _showImageGallery(
                                    context,
                                    ticket.images,
                                    ticket.images.indexOf(image)),
                                child: Image.network(
                                  '${Config.baseUrl}/clients/uploads/$image',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              color: Color(0xFF35C2C1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
