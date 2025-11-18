import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Trade With AI'),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.trending_up,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Trade With AI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Auto Trading System',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (_user == null) ...[
              const Text('Please sign in to continue'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement authentication
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentication feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ] else ...[
              Text('Signed in as: ${_user!.email ?? "User"}'),
              const SizedBox(height: 20),
              const Text('Trading features coming soon...'),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trading features will be available soon'),
            ),
          );
        },
        tooltip: 'Start Trading',
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
