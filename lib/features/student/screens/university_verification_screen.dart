import 'package:flutter/material.dart';

class UniversityVerificationScreen extends StatelessWidget {
  const UniversityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Verification'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Icon(
                  Icons.verified_user_outlined,
                  size: 96,
                ),
                SizedBox(height: 16),
                Text(
                  'University Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your university email to verify your account.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'University email',
                    hintText: 'name@redhawks.edu',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Verify Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
