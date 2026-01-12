import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/database_helper.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/report_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/wallets_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo sqflite FFI cho Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await initializeDateFormatting('vi_VN', null);
  // Khởi tạo database trước khi chạy app
  await DatabaseHelper().database;

  // Load saved user
  final authService = AuthService();
  await authService.loadSavedUser();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as int?;
          return MainScreen(initialTabIndex: args);
        },
      },
    );
  }
}

// Auth screen to check login state
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (AuthService.currentUserId != null) {
      return const MainScreen();
    }
    return const LoginScreen();
  }
}

class MainScreen extends StatefulWidget {
  final int? initialTabIndex;

  const MainScreen({Key? key, this.initialTabIndex}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final _homeScreenKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex ?? 0;
    _screens = <Widget>[
      HomeScreen(key: _homeScreenKey),
      const TransactionListScreen(),
      const ReportScreen(),
      const WalletsScreen(),
      const CategoriesScreen(),
    ];
  }

  static const List<String> _titles = [
    'Home',
    'Transactions',
    'Reports',
    'Wallets',
    'Categories',
  ];

  static const List<IconData> _icons = [
    Icons.home,
    Icons.list,
    Icons.assessment,
    Icons.account_balance_wallet,
    Icons.category,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile layout with bottom navigation
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue.shade700,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTransactionModal,
          backgroundColor: Colors.blue.shade700,
          child: const Icon(Icons.add),
        ),
      );
    } else {
      // Desktop layout with sidebar
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 250,
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  // Logo/Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.wallet,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PEM',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Personal Expense',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade300, height: 1),
                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _titles.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return _buildSidebarItem(
                          icon: _icons[index],
                          label: _titles[index],
                          isSelected: isSelected,
                          onTap: () => _onItemTapped(index),
                        );
                      },
                    ),
                  ),
                  // Divider before button
                  Divider(color: Colors.grey.shade300, height: 1),
                  // Add Button at bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showAddTransactionModal,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Transaction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _titles[_selectedIndex],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            // IconButton(
                            //   icon: const Icon(Icons.search),
                            //   onPressed: () {},
                            // ),
                            // IconButton(
                            //   icon: const Icon(Icons.notifications),
                            //   onPressed: () {},
                            // ),
                            PopupMenuButton(
                              icon: const Icon(Icons.account_circle),
                              offset: const Offset(0, 50),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: const [
                                      Icon(Icons.settings),
                                      SizedBox(width: 12),
                                      Text('Account Settings'),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountSettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: const [
                                      Icon(Icons.logout, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text(
                                        'Log Out',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  onTap: _handleLogout,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Screen Content
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        hoverColor: Colors.blue.shade200.withOpacity(0.5),
      ),
    );
  }

  void _showAddTransactionModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh HomeScreen with UI update
        _homeScreenKey.currentState?.refreshData();
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
