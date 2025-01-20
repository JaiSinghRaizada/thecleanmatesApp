import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../home/bottom_navbar.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate after 3 seconds
    Timer(Duration(seconds: 3), _navigateBasedOnAuth);
  }

  void _navigateBasedOnAuth() {
    final authState = BlocProvider.of<AuthBloc>(context).state;

    if (authState is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, ${authState.email}")),
      );
      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavbar()),
      );
    } else if (authState is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.message)),
      );
    } else {
      // Navigate to login or any other screen if user is not authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            Icon(
              Icons.star, // Replace with your logo or image
              size: 100,
              color: Color(0xFFDC2626), // Preferred color
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to My App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626), // Preferred color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
