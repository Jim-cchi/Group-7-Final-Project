import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login_page.dart';
import 'user_auth/firebase_auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool _isSigning = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    } else if (!RegExp(
            r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$')
        .hasMatch(password)) {
      return 'Minimum eight characters, at least one letter, one number and one special character';
    }
    return null;
  }

  String? _cPasswordValidator(String? cPassword) {
    if (cPassword == null || cPassword.isEmpty) {
      return 'Please confirm your password';
    } else if (_passwordController.text != cPassword) {
      return 'Password must be same as above';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Column(
                    children: [
                      Image.asset('assets/logo_2.png', width: 300,),
                      const Text('Sign up',
                          style: TextStyle(fontSize: 20, color: Colors.white))
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red[300]),
                            prefixIcon: const Icon(Icons.mail),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: _emailValidator,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red[300]),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: GestureDetector(
                              onTap: _toggle,
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 20,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscureText,
                          validator: _passwordValidator,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _cPasswordController,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red[300]),
                            prefixIcon: const Icon(Icons.check_circle),
                            suffixIcon: GestureDetector(
                              onTap: _toggle,
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 20,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscureText,
                          validator: _cPasswordValidator,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blueGrey,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: _isSigning
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.amber,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Signup ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: "Already have an account? ",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white)),
                          TextSpan(
                              text: 'Sign in',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()))),
                        ]))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      _isSigning = true;
    });
    String email = _emailController.text;
    String password = _passwordController.text;
    String cPassword = _cPasswordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    setState(() {
      _isSigning = false;
    });
    if (_formKey.currentState!.validate()) {
      if (user != null && mounted) {
        debugPrint("User is successfully created");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyHome()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Email already exists')));
      }
    }
  }
}
