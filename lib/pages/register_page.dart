import 'package:flutter/material.dart';
import 'package:flutter_chatapp/components/my_button.dart';
import 'package:flutter_chatapp/components/my_textfield.dart';
import 'package:flutter_chatapp/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  // sign up user
  void signUp() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        _displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte fülle alle Felder aus!"))
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Die Passwörter stimmen nicht überein!"))
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Das Passwort muss mindestens 6 Zeichen lang sein!"))
      );
      return;
    }

    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.registerWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        _displayNameController.text,
      );
    } catch (e) {
      String errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains("already registered") ||
          errorMsg.contains("email-already-in-use")) {
        errorMsg = "This Email is already in use";
      } else if (errorMsg.contains("invalid-email")) {
        errorMsg = "Please enter a valid email address!";
      } else if (errorMsg.contains("weak-password")) {
        errorMsg = "The password is too weak!";
      } else if (errorMsg.contains("network-request-failed")) {
        errorMsg = "Network error. Please check your internet connection.";
      } else if (errorMsg.contains("passwords do not match")) {
        errorMsg = "Passwords do not match!";
      } else if (errorMsg.contains("missing-fields")) {
        errorMsg = "Please fill out all fields!";
      } else {
        errorMsg = "An unknown error occurred: ${e.toString()}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.message, size: 100, color: Colors.blue.shade700),
            const SizedBox(height: 32),
            Text(
              "Let's create an account for you!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            MyTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            const SizedBox(height: 16),
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),
            MyTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),
            MyTextField(
              controller: _displayNameController,
              hintText: "Display Name",
              obscureText: false,
            ),
            const SizedBox(height: 24),
            MyButton(onTap: signUp, text: "Sign Up"),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already a member? ", style: TextStyle(color: Colors.blueGrey)),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          ),
      ),
    );
  }
}