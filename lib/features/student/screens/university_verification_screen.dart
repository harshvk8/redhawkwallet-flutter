import 'package:flutter/material.dart';
import 'package:redhawkwallet_flutter/core/widgets/demo_screen_scaffold.dart';

class UniversityVerificationScreen extends StatefulWidget {
  const UniversityVerificationScreen({super.key});

  @override
  State<UniversityVerificationScreen> createState() =>
      _UniversityVerificationScreenState();
}

class _UniversityVerificationScreenState
    extends State<UniversityVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(
    text: 'jordan.hawke@redhawks.edu',
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitVerification() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email sent!')));
  }

  @override
  Widget build(BuildContext context) {
    return DemoScreenScaffold(
      title: 'University Verification',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _VerificationBanner(),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'University email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your university email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _submitVerification,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Submit verification'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.verified_outlined),
                  title: Text('Verification status'),
                  subtitle: Text('Verified for campus wallet access'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.emoji_events_outlined),
                  title: Text('Next step'),
                  subtitle: Text('Check your inbox after submitting the form'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.tertiaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.verified_user_outlined, size: 80),
            SizedBox(height: 12),
            Text(
              'University Verification',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Demo verification data is shown here so the screen is usable before the real flow is connected.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
