import 'package:flutter/material.dart';
import 'dart:async'; // For Future

// --- NEW IMPORTS FOR FIREBASE & EMULATORS ---
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ---------------------------------------------

// These are the new files you created. Make sure they exist in your 'lib' folder.
import 'registration_screen.dart';
import 'chatbot_view.dart';

// --- Mock Data Models ---
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final AutoTradingSettings autoTradingSettings;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.autoTradingSettings,
  });
}

class AutoTradingSettings {
  bool isEnabled;
  String riskLevel; // e.g., "Conservative", "Moderate", "Aggressive"
  String strategyCadence; // New field: "Daily", "Weekly", "Monthly"
  double maxTradeAmount;
  List<String> watchList;

  AutoTradingSettings({
    this.isEnabled = false,
    this.riskLevel = "Moderate",
    this.strategyCadence = "Weekly",
    this.maxTradeAmount = 1000.0,
    this.watchList = const ['AAPL', 'GOOGL', 'TSLA'],
  });
}

// --- CORRECTED TradeSignal MODEL ---
// This model matches the REAL data from Polygon.io
class TradeSignal {
  final String symbol;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  TradeSignal({
    required this.symbol,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // Factory constructor to parse the data from our Cloud Function
  factory TradeSignal.fromPolygonResult(String symbol, Map<String, dynamic> result) {
    return TradeSignal(
      symbol: symbol,
      open: (result['o'] ?? 0.0).toDouble(),
      high: (result['h'] ?? 0.0).toDouble(),
      low: (result['l'] ?? 0.0).toDouble(),
      close: (result['c'] ?? 0.0).toDouble(),
      volume: (result['v'] ?? 0.0).toDouble(),
    );
  }
}

// --- CORRECTED Main Application Entry Point ---
// This function now initializes Firebase and connects to the emulators
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "---", // Studio will inject
      appId: "---", // Studio will inject
      messagingSenderId: "---", // Studio will inject
      projectId: "---", // Studio will inject
    ),
  );

  // --- THIS IS THE NEW CODE ---
  // If we are in debug mode (testing), talk to the local emulators
  if (kDebugMode) {
    try {
      print("--- RUNNING IN DEBUG MODE: USING EMULATORS ---");
      // Point Functions to the local emulator
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      // You can also add Firestore, etc., here later
    } catch (e) {
      print("Error setting up emulators: $e");
    }
  }
  // --- END OF NEW CODE ---

  // Sign in anonymously for now
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Firebase signed in anonymously.");
  } catch (e) {
    print("Error signing in anonymously: $e");
  }

  runApp(const AiTradingApp());
}


class AiTradingApp extends StatelessWidget {
  const AiTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Trading App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101213),
        cardColor: const Color(0xFF1B1F24),
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          surface: const Color(0xFF1B1F24),
          onPrimary: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[900],
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white38,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Authentication Wrapper (No changes) ---

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _showLoginPage = true;

  void _login() => setState(() => _isAuthenticated = true);
  void _logout() => setState(() => _isAuthenticated = false);
  void _toggleView() => setState(() => _showLoginPage = !_showLoginPage);

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return MainScreen(onLogout: _logout);
    } else {
      if (_showLoginPage) {
        return LoginScreen(onLogin: _login, onSwitchToRegister: _toggleView);
      } else {
        // This assumes you have a registration_screen.dart file
        return RegistrationScreen(
          onRegister: _login,
          onSwitchToLogin: _toggleView,
        );
      }
    }
  }
}

// --- Login Screen (No changes) ---

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSwitchToRegister;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSwitchToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Colors.tealAccent, size: 60),
              const SizedBox(height: 20),
              const Text(
                'AI Trading Assistant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Login'),
                ),
              ),
              TextButton(
                onPressed: onSwitchToRegister,
                child: const Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(color: Colors.tealAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main App Screen (No changes) ---

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MainScreen({super.key, required this.onLogout});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DashboardScreen(),
      const SignalsScreen(), // This screen is now functional!
      const AutoTradingScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ChatbotView()));
        },
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        tooltip: 'AI Assistant',
        child: const Icon(Icons.support_agent),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.signal_cellular_alt),
            label: 'Signals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Auto-Trade',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- Screen 1: Dashboard (No changes) ---

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            indicatorColor: Colors.tealAccent,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Portfolio'),
              Tab(icon: Icon(Icons.star), text: 'Watchlist'),
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Mutual Funds',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [PortfolioView(), WatchlistView(), MutualFundsView()],
        ),
      ),
    );
  }
}

// --- Dashboard Tab 1: Portfolio View (No changes) ---
class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Your existing code is fine)
    const double portfolioValue = 125430.50;
    const double todayChange = 1230.75;
    const double todayChangePercent = todayChange / portfolioValue;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPortfolioSummary(portfolioValue, todayChange, todayChangePercent),
        const SizedBox(height: 24),
        Text('Your Holdings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _buildHoldingCard('Apple Inc.', 'AAPL', 50, 175.50, 15.20),
        _buildHoldingCard('Google LLC', 'GOOGL', 20, 140.25, -5.10),
        _buildHoldingCard('Tesla, Inc.', 'TSLA', 30, 250.80, 45.90),
      ],
    );
  }

  Widget _buildPortfolioSummary(double value, double change, double percent) {
    // ... (Your existing code is fine)
    final bool isPositive = change >= 0;
    final Color changeColor = isPositive
        ? Colors.greenAccent
        : Colors.redAccent;
    final String sign = isPositive ? '+' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Value',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$sign\$${change.toStringAsFixed(2)} (${(percent * 100).toStringAsFixed(2)}%) Today',
                  style: TextStyle(fontSize: 18, color: changeColor),
                ),
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: changeColor,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingCard(
    String name,
    String symbol,
    int shares,
    double price,
    double dayChange,
  ) {
    // ... (Your existing code is fine)
    final bool isPositive = dayChange >= 0;
    final Color changeColor = isPositive
        ? Colors.greenAccent
        : Colors.redAccent;
    final String sign = isPositive ? '+' : '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$shares shares',
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${(shares * price).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '$sign\$${dayChange.toStringAsFixed(2)}',
              style: TextStyle(color: changeColor),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Tab 2: Watchlist View (No changes) ---
class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});
  // ... (Your existing code is fine)
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildWatchlistItem(
          context,
          'Reliance Industries',
          'RELIANCE',
          2850.55,
          12.30,
        ),
        _buildWatchlistItem(
          context,
          'Tata Consultancy',
          'TCS',
          4100.20,
          -25.10,
        ),
        _buildWatchlistItem(context, 'HDFC Bank', 'HDFCBANK', 1580.70, 5.05),
      ],
    );
  }

  Widget _buildWatchlistItem(
    BuildContext context,
    String name,
    String symbol,
    double price,
    double change,
  ) {
    final bool isPositive = change >= 0;
    final Color changeColor = isPositive
        ? Colors.greenAccent
        : Colors.redAccent;
    final String sign = isPositive ? '+' : '';
    return Card(
      child: ListTile(
        title: Text(name, style: TextStyle(color: Colors.white)),
        subtitle: Text(symbol, style: TextStyle(color: Colors.white70)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '$sign₹${change.toStringAsFixed(2)}',
              style: TextStyle(color: changeColor),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Tab 3: Mutual Funds View (No changes) ---
class MutualFundsView extends StatelessWidget {
  const MutualFundsView({super.key});
  // ... (Your existing code is fine)
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildMfCard(context, 'Parag Parikh Flexi Cap', 150000.0, 1.2),
        _buildMfCard(context, 'Axis Small Cap Fund', 75000.0, -0.5),
        _buildMfCard(context, 'Mirae Asset Large Cap', 225000.0, 0.8),
      ],
    );
  }

  Widget _buildMfCard(
    BuildContext context,
    String name,
    double value,
    double dayChangePercent,
  ) {
    final bool isPositive = dayChangePercent >= 0;
    final Color changeColor = isPositive
        ? Colors.greenAccent
        : Colors.redAccent;
    final String sign = isPositive ? '+' : '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Value: ₹${value.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Today\'s Change: $sign${dayChangePercent.toStringAsFixed(2)}%',
              style: TextStyle(color: changeColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// --------- CORRECTED SignalsScreen (Now calls the function) ---------
// -----------------------------------------------------------------

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  _SignalsScreenState createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  // Local state to hold our signals
  final List<TradeSignal> _signals = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // --- This is the function that calls your backend ---
  Future<void> _fetchSignals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Get a reference to your "middle-man" function
      final callable = FirebaseFunctions.instance.httpsCallable('getMarketData');

      // 2. Call the function. We can send data (like a symbol) in a map.
      // Let's test with 'RELIANCE' (NSE) or 'MSFT' (NASDAQ)
      // Note: Polygon.io needs the ticker symbol (e.g., 'RELIANCE' for Reliance Industries)
      final response = await callable.call<Map<String, dynamic>>({
        'symbol': 'MSFT', // Let's test Microsoft
      });

      // 3. Print the raw data to the CONSOLE (bottom panel)
      print("--- RAW DATA FROM FUNCTION ---");
      print(response.data);
      print("------------------------------");

      // 4. Parse the data and update our UI
      final responseData = response.data['data']; // Get the inner 'data' object
      final results = responseData['results'] as List<dynamic>?;
      
      if (results != null && results.isNotEmpty) {
        final signal = TradeSignal.fromPolygonResult(
          responseData['ticker'],
          results[0] as Map<String, dynamic>,
        );
        setState(() {
          _signals.clear(); // Clear old data
          _signals.add(signal); // Add new signal
        });
      } else {
        setState(() {
          _errorMessage = "No results found for that symbol.";
        });
      }

    } on FirebaseFunctionsException catch (e) {
      // This is the error you will see UNTIL the billing is fixed
      print("--- FIREBASE ERROR ---");
      print("Code: ${e.code}");
      print("Message: ${e.message}");
      print("----------------------");
      setState(() {
        _errorMessage = "Error: ${e.message}";
      });
    } catch (e) {
      // Catch any other errors
      print("--- UNKNOWN ERROR ---");
      print(e.toString());
      print("---------------------");
      setState(() {
        _errorMessage = "An unknown error occurred.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live AI Signals'),
        actions: [
          // Add a refresh button to call the function
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchSignals,
          ),
        ],
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  // --- Helper widget to build the UI ---
  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_signals.isEmpty) {
      return ElevatedButton(
        onPressed: _fetchSignals,
        child: const Text('Load Market Data'),
      );
    }

    // If we have data, display it in a ListView
    return ListView.builder(
      itemCount: _signals.length,
      itemBuilder: (context, index) {
        final signal = _signals[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: signal.close > signal.open ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
              child: Icon(
                signal.close > signal.open ? Icons.arrow_upward : Icons.arrow_downward,
                color: signal.close > signal.open ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            title: Text(signal.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Close: \$${signal.close.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
            trailing: Text(
              'Vol: ${signal.volume.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        );
      },
    );
  }
}

// --- Screen 3: Auto-Trading Controls (CORRECTED) ---

class AutoTradingScreen extends StatefulWidget {
  const AutoTradingScreen({super.key});

  @override
  _AutoTradingScreenState createState() => _AutoTradingScreenState();
}

class _AutoTradingScreenState extends State<AutoTradingScreen> {
  late AutoTradingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = UserProfile(
      uid: '123',
      email: 'test@test.com',
      name: 'Test User',
      autoTradingSettings: AutoTradingSettings(),
    ).autoTradingSettings;
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-Trading settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automated Trading'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile.adaptive(
            title: const Text(
              'Enable Auto-Trading',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: Text(
              _settings.isEnabled
                  ? 'The AI will trade on your behalf.'
                  : 'Trading is paused.',
              style: const TextStyle(color: Colors.white70),
            ),
            value: _settings.isEnabled,
            onChanged: (bool value) =>
                setState(() => _settings.isEnabled = value),
            activeColor: Colors.tealAccent,
          ),
          const Divider(height: 30),
          _buildRiskLevelSelector(),
          const Divider(height: 30),
          _buildStrategyCadenceSelector(), // New Selector
          const Divider(height: 30),
          _buildMaxTradeAmountSlider(),
          const Divider(height: 30),
          Text(
            'Watchlist for Auto-Trading',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ..._settings.watchList.map(
            (symbol) => ListTile(
              title: Text(symbol, style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevelSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk Level', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _settings.riskLevel, // <-- CORRECTED
            items: ['Conservative', 'Moderate', 'Aggressive']
                .map(
                  (String value) =>
                      DropdownMenuItem<String>(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (newValue) =>
                setState(() => _settings.riskLevel = newValue!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );

  Widget _buildStrategyCadenceSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Strategy Cadence', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _settings.strategyCadence, // <-- CORRECTED
            items: ['Daily', 'Weekly', 'Monthly']
                .map(
                  (String value) =>
                      DropdownMenuItem<String>(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (newValue) =>
                setState(() => _settings.strategyCadence = newValue!),
            decoration: InputDecoration(
              hintText: 'How often the AI re-evaluates.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );

  Widget _buildMaxTradeAmountSlider() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Max Amount per Trade',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_settings.maxTradeAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _settings.maxTradeAmount,
            min: 100,
            max: 5000,
            divisions: 49,
            label: _settings.maxTradeAmount.round().toString(),
            onChanged: (double value) =>
                setState(() => _settings.maxTradeAmount = value),
            activeColor: Colors.tealAccent,
          ),
        ],
      );
}

// --- Screen 4: Profile (No changes) ---

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // ... (Your existing code is fine)
    final user = UserProfile(
      uid: 'xyz-123',
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      autoTradingSettings: AutoTradingSettings(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.tealAccent,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('My Balance'),
                  subtitle: const Text('View account funds'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Trade History'),
                  subtitle: const Text('See all past transactions'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Bank Details'),
                  subtitle: const Text('Manage your linked accounts'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage alerts'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security'),
                  subtitle: const Text('Change password, 2FA'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
