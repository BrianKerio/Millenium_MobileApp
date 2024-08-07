import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:millenium/components/landing.dart';
import 'package:millenium/widgets/login.dart';
import 'package:millenium/widgets/register.dart';

// FlutterSecureStorage
final storage = FlutterSecureStorage();

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final String pinKey = "passcode";

  @override
  void initState() {
    super.initState();
    _setDefaultPin();
  }

  // Default PIN
  Future<void> _setDefaultPin() async {
    String? existingPin = await storage.read(key: pinKey);
    if (existingPin == null) {
      await storage.write(key: pinKey, value: "1234");
    }
  }

  // Show the PIN input dialog
  void _showPinDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinEntryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: Image.asset(
                "lib/asset/img-3.png",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              flex: 2,
              child: Image.asset(
                "lib/asset/images.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              flex: 2,
              child: const Text(
                "Millenium Solutions E.A. LTD",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF35C2C1),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: const Text(
                "Your Technology Partner!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      color: const Color(0xFF1E232C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Register button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xFF1E232C),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Color(0xFF1E232C),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expert Login
            const Spacer(),
            GestureDetector(
              onTap: () {
                _showPinDialog(context);
              },
              child: const Text(
                "Staff Login",
                style: TextStyle(
                  color: Color(0xFF35C2C1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({Key? key}) : super(key: key);

  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  // Define a key for the PIN storage
  final String pinKey = "passcode";
  List<String> pin = ["", "", "", ""];
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _setDefaultPin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Default PIN
  Future<void> _setDefaultPin() async {
    String? existingPin = await storage.read(key: pinKey);
    if (existingPin == null) {
      await storage.write(key: pinKey, value: "1234");
    }
  }

  // Method to build the PIN entry field
  Widget _buildPinField(int index) {
    bool hasValue = pin[index].isNotEmpty;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasValue ? Colors.white : Colors.transparent,
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
      ),
      child: Center(
        child: hasValue
            ? Text(
                pin[index],
                style: const TextStyle(fontSize: 20, color: Colors.white),
              )
            : null,
      ),
    );
  }

  // Method to build the number pad
  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                List.generate(3, (index) => _buildNumberButton(index + 1)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                List.generate(3, (index) => _buildNumberButton(index + 4)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                List.generate(3, (index) => _buildNumberButton(index + 7)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDeleteButton(),
              _buildNumberButton(0),
              _buildCancelButton(),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build each number button
  Widget _buildNumberButton(int number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: MaterialButton(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: () {
            for (int i = 0; i < pin.length; i++) {
              if (pin[i] == "") {
                setState(() {
                  pin[i] = number.toString();
                });
                if (i == 3) {
                  _validatePin();
                } else {
                  FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                }
                break;
              }
            }
          },
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  // Method to build the delete button
  Widget _buildDeleteButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: MaterialButton(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: () {
            for (int i = pin.length - 1; i >= 0; i--) {
              if (pin[i] != "") {
                setState(() {
                  pin[i] = "";
                });
                FocusScope.of(context).requestFocus(_focusNodes[i]);
                break;
              }
            }
          },
          child: const Icon(
            Icons.backspace,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  // Method to build the cancel button
  Widget _buildCancelButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: MaterialButton(
          color: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  // Method to validate the entered PIN
  Future<void> _validatePin() async {
    String enteredPin = pin.join();
    String? correctPin = await storage.read(key: pinKey);
    if (enteredPin == correctPin) {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Wrong One Time Pin!",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ));

      setState(() {
        pin = ["", "", "", ""];
      });
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              color: Color(0xFF35C2C1),
              size: 48,
            ),
            const SizedBox(height: 10),
            const Text(
              "To Proceed Enter One Time PIN.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF35C2C1),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPinField(index)),
            ),
            const SizedBox(height: 20),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }
}
