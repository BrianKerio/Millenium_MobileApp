import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  int yearsOfExperience = 0;
  int happyClients = 0;

  @override
  void initState() {
    super.initState();
    _startCounters();
  }

  void _startCounters() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          yearsOfExperience = 9;
          happyClients = 560;
        });
      }
    });
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
        title: const Text(
          'About Us Millenium',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Millenium Solutions E.A. LTD',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF35C2C1),
                ),
              ),
              const Center(
                child: Text(
                  'We are a Microsoft Certified Business Solutions Partner.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF35C2C1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Image.asset(
                'lib/asset/images.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCounter('Years of Experience', yearsOfExperience),
                    _buildCounter('Happy Clients', happyClients),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildContactUsBox(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int count) {
    return Column(
      children: [
        Text(
          '$count+',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF35C2C1),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactUsBox(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        border: Border.all(
          color: const Color(0xFFE8ECF4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF35C2C1),
            ),
          ),
          const SizedBox(height: 10),
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: 'info@millenium.com\n24*7 Online Support',
            backgroundColor: Colors.blue.shade50,
            borderColor: Colors.blue.shade200,
            context: context,
          ),
          const SizedBox(height: 10),
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: '+254715-844-844',
            backgroundColor: Colors.blue.shade50,
            borderColor: Colors.blue.shade200,
            context: context,
          ),
          const SizedBox(height: 10),
          _buildContactItem(
            icon: Icons.location_on,
            label: 'Location',
            value: 'Block 4, 12, Masaba Rd, Upperhill, Nairobi',
            backgroundColor: Colors.blue.shade50,
            borderColor: Colors.blue.shade200,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
    required Color borderColor,
    required BuildContext context,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: Color(0xFF35C2C1),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
