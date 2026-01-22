import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  const SignInScreen({super.key, required this.child});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final signedIn = await UserService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isSignedIn = signedIn;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateSignedInState() {
    _checkSignInStatus();
  }

  @override
  Widget build(BuildContext context) {
    return _isSignedIn
        ? widget.child
        : Center(
            child: SignInWidget(
              client: client,
              onAuthenticated: () {},
            ),
          );
  }
}
