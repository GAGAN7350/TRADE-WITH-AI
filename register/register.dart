import 'package:flutter/material.dart';
// import 'terms_and_conditions_page.dart'; // We will create this file next

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onSwitchToLogin;

  const RegistrationScreen({
    super.key,
    required this.onRegister,
    required this.onSwitchToLogin,
  });

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 0;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onSwitchToLogin,
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          final isLastStep = _currentStep == getSteps().length - 1;
          if (isLastStep) {
            // In a real app, you would validate all fields here before submitting.
            if (!_termsAccepted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You must accept the terms and conditions.')),
              );
              return;
            }
            print('Submitting registration...');
            // IMPORTANT: Here you would send the data to your secure backend (Firebase Cloud Function)
            // Do NOT handle registration logic on the client.
            widget.onRegister();
          } else {
            setState(() => _currentStep += 1);
          }
        },
        onStepCancel: _currentStep == 0 ? null : () => setState(() => _currentStep -= 1),
        steps: getSteps(),
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == getSteps().length - 1;
          return Container(
            margin: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'REGISTER' : 'NEXT'),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep != 0)
                  Expanded(
                    child: TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('BACK'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Step> getSteps() => [
        Step(
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 0,
          title: const Text('Personal Details'),
          content: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextFormField(decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 8),
              TextFormField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
        ),
        Step(
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 1,
          title: const Text('KYC Verification (India)'),
          content: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'PAN Card Number')),
              const SizedBox(height: 8),
              TextFormField(decoration: const InputDecoration(labelText: 'Aadhaar Number')),
              // In a real app, you'd have a button to upload documents.
            ],
          ),
        ),
        Step(
          isActive: _currentStep >= 2,
          title: const Text('Bank & T&C'),
          content: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Bank Account Number')),
              const SizedBox(height: 8),
              TextFormField(decoration: const InputDecoration(labelText: 'IFSC Code')),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TermsAndConditionsPage(),
                    ));
                  },
                  child: const Text('I accept the Terms & Conditions', style: TextStyle(decoration: TextDecoration.underline)),
                ),
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ];
}

// Create this new file for the T&C page
class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '''
          **Last updated: October 13, 2025**

          Please read these terms and conditions carefully before using Our Service.

          **1. Interpretation and Definitions**
          The words of which the initial letter is capitalized have meanings defined under the following conditions...

          [... Add your full T&C legal text here ...]

          **10. Disclaimer**
          The service is provided to You "AS IS" and "AS AVAILABLE". All investments in the stock market are subject to market risks. The AI signals provided are for informational purposes only and do not constitute financial advice...

          ''',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
