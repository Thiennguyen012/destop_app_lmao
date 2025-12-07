import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/app_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  late Future<List<TransactionModel>> _transactionsFuture;
  late Future<double> _incomeFuture;
  late Future<double> _expenseFuture;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    _transactionsFuture = _transactionRepository.getAllTransactions();
    _incomeFuture = _transactionRepository.getTotalIncome();
    _expenseFuture = _transactionRepository.getTotalExpense();
  }

  void refreshData() {
    _refresh();
  }

  void _refresh() {
    setState(() {
      _refreshKey++;
      loadData();
    });
  }

  Future<String> _getCategoryIcon(String categoryName) async {
    final categories = await _categoryRepository.getAllCategories();
    final category =
        categories.firstWhere((c) => c.name == categoryName, orElse: () {
      return Category(name: categoryName, type: 'expense', icon: '💰');
    });
    return category.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Quản Lý Tài Chính'),
      //   elevation: 0,
      //   backgroundColor: Colors.blue.shade700,
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Title
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Summary Cards in Horizontal Scroll
                FutureBuilder<double>(
                  future: _incomeFuture,
                  builder: (context, snapshot) {
                    final income = snapshot.data ?? 0.0;
                    return FutureBuilder<double>(
                      key: ValueKey(_refreshKey),
                      future: _expenseFuture,
                      builder: (context, snapshotExpense) {
                        final expense = snapshotExpense.data ?? 0.0;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Total Salary
                              _buildCompactCard(
                                title: 'Total Salary',
                                amount: income,
                                color: Colors.green,
                                icon: Icons.card_giftcard,
                                width: 150,
                              ),
                              const SizedBox(width: 12),
                              // Total Expense
                              _buildCompactCard(
                                title: 'Total Expense',
                                amount: expense,
                                color: Colors.blue,
                                icon: Icons.card_giftcard,
                                width: 150,
                                isHighlight: true,
                              ),
                              const SizedBox(width: 12),
                              // Monthly Balance
                              _buildCompactCard(
                                title: 'Monthly',
                                amount: income - expense,
                                color: Colors.grey,
                                icon: Icons.card_giftcard,
                                width: 150,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Calendar Section
                _buildCalendarSection(),
                const SizedBox(height: 24),

                // Latest Entries
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Entries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transactions List
                FutureBuilder<List<TransactionModel>>(
                  key: ValueKey(_refreshKey),
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Chưa có giao dịch nào'),
                      );
                    }

                    final transactions =
                        snapshot.data!.take(10).toList(); // Show latest 10
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return FutureBuilder<String>(
                          future: _getCategoryIcon(tx.category),
                          builder: (context, iconSnapshot) {
                            final icon = iconSnapshot.data ?? '💰';
                            return _buildTransactionItem(
                              title: tx.title,
                              category: tx.category,
                              amount: tx.amount,
                              type: tx.type,
                              icon: icon,
                              date: AppUtils.formatDate(tx.date),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build compact summary card
  Widget _buildCompactCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required double width,
    bool isHighlight = false,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isHighlight ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight ? Border.all(color: color, width: 2) : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 20,
                color: isHighlight ? Colors.white : color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppUtils.formatCurrency(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.white : color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Build transaction item
  Widget _buildTransactionItem({
    required String title,
    required String category,
    required double amount,
    required String type,
    required String icon,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${type == 'income' ? '+' : '- '}${AppUtils.formatCurrency(amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: type == 'income' ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Calendar Section
  Widget _buildCalendarSection() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return FutureBuilder<List<TransactionModel>>(
      key: ValueKey('$_refreshKey-calendar'),
      future: _transactionRepository.getAllTransactions(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];

        // Group transactions by day
        final transactionsByDay = <int, List<TransactionModel>>{};
        for (var tx in transactions) {
          final day = tx.date.day;
          transactionsByDay.putIfAbsent(day, () => []).add(tx);
        }

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tháng ${now.month}/${now.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 42, // 6 rows * 7 days
                  itemBuilder: (context, index) {
                    // Calculate which day this cell represents
                    final firstWeekday = firstDay.weekday % 7; // 0 = Sunday
                    final dayNumber = index - firstWeekday + 1;

                    if (dayNumber < 1 || dayNumber > lastDay.day) {
                      return const SizedBox();
                    }

                    final dayTransactions = transactionsByDay[dayNumber] ?? [];
                    final hasTransactions = dayTransactions.isNotEmpty;

                    // Calculate totals
                    final totalIncome = dayTransactions
                        .where((tx) => tx.type == 'income')
                        .fold<double>(0, (sum, tx) => sum + tx.amount);
                    final totalExpense = dayTransactions
                        .where((tx) => tx.type == 'expense')
                        .fold<double>(0, (sum, tx) => sum + tx.amount);

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasTransactions
                              ? Colors.blue.shade300
                              : Colors.grey.shade200,
                          width: hasTransactions ? 1.5 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: hasTransactions
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Day number
                          Text(
                            dayNumber.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Transaction amounts
                          if (hasTransactions)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (totalIncome > 0)
                                    Text(
                                      '+${AppUtils.formatCurrency(totalIncome)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (totalExpense > 0)
                                    Text(
                                      '-${AppUtils.formatCurrency(totalExpense)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
