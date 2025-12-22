import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/wallet_repository.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../utils/app_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WalletRepository _walletRepository = WalletRepository();
  late Future<List<TransactionModel>> _transactionsFuture;
  late Future<double> _incomeMonthlyFuture;
  late Future<double> _expenseMonthlyFuture;
  late Future<List<Wallet>> _walletsFuture;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final now = DateTime.now();
    _transactionsFuture = _transactionRepository.getAllTransactions();
    _incomeMonthlyFuture =
        _transactionRepository.getMonthlyIncome(now.month, now.year);
    _expenseMonthlyFuture =
        _transactionRepository.getMonthlyExpense(now.month, now.year);
    _walletsFuture = _walletRepository.getAllWallets();
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
                  future: _incomeMonthlyFuture,
                  builder: (context, snapshot) {
                    final income = snapshot.data ?? 0.0;
                    return FutureBuilder<double>(
                      key: ValueKey(_refreshKey),
                      future: _expenseMonthlyFuture,
                      builder: (context, snapshotExpense) {
                        final expense = snapshotExpense.data ?? 0.0;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Thu Nhập Tháng
                              _buildCompactCard(
                                title: 'Income this Month',
                                amount: income,
                                color: Colors.green,
                                icon: Icons.arrow_downward,
                                width: 150,
                              ),
                              const SizedBox(width: 12),
                              // Chi Tiêu Tháng
                              _buildCompactCard(
                                title: 'Expense this Month',
                                amount: expense,
                                color: Colors.blue,
                                icon: Icons.arrow_upward,
                                width: 150,
                                isHighlight: true,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Wallets Section
                FutureBuilder<List<Wallet>>(
                  future: _walletsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }

                    final wallets = snapshot.data ?? [];
                    if (wallets.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Wallets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: wallets.take(5).map((wallet) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Card(
                                  child: Container(
                                    width: 160,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.wallet,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                            Text(
                                              wallet.currency,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          wallet.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppUtils.formatCurrency(
                                              wallet.balance),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // Calendar Section
                _buildCalendarSection(),
                const SizedBox(height: 24),

                // Category Statistics (Pie Charts)
                _buildCategoryStatistics(),
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
                        child: Text('No transactions yet'),
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

  // Build Category Statistics with Pie Charts
  Widget _buildCategoryStatistics() {
    return FutureBuilder<List<TransactionModel>>(
      key: ValueKey('$_refreshKey-stats'),
      future: _transactionRepository.getAllTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];

        // Group by category and type
        final incomeByCategory = <String, double>{};
        final expenseByCategory = <String, double>{};

        for (var tx in transactions) {
          if (tx.type == 'income') {
            incomeByCategory[tx.category] =
                (incomeByCategory[tx.category] ?? 0) + tx.amount;
          } else {
            expenseByCategory[tx.category] =
                (expenseByCategory[tx.category] ?? 0) + tx.amount;
          }
        }

        if (incomeByCategory.isEmpty && expenseByCategory.isEmpty) {
          return const SizedBox();
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
                const Text(
                  'Category statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Income Pie Chart
                    if (incomeByCategory.isNotEmpty)
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildPieChart(
                                      data: incomeByCategory,
                                      type: 'income',
                                      radius: 60,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _buildLegend(
                                      data: incomeByCategory,
                                      type: 'income',
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Expense Pie Chart
                    if (expenseByCategory.isNotEmpty)
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildPieChart(
                                      data: expenseByCategory,
                                      type: 'expense',
                                      radius: 60,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _buildLegend(
                                      data: expenseByCategory,
                                      type: 'expense',
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build Pie Chart
  Widget _buildPieChart({
    required Map<String, double> data,
    required String type,
    double radius = 80,
  }) {
    final sections = <PieChartSectionData>[];
    final total = data.values.fold<double>(0, (sum, val) => sum + val);

    int colorIndex = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    data.forEach((category, amount) {
      final percentage = (amount / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          radius: radius,
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: radius * 0.5,
        sectionsSpace: 2,
      ),
      swapAnimationDuration: const Duration(milliseconds: 750),
    );
  }

  // Build Legend
  Widget _buildLegend({
    required Map<String, double> data,
    required String type,
    bool compact = false,
  }) {
    final total = data.values.fold<double>(0, (sum, val) => sum + val);
    int colorIndex = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          final category = entry.key;
          final amount = entry.value;
          final percentage = (amount / total) * 100;
          final color = colors[colorIndex % colors.length];
          colorIndex++;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 4.0 : 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: compact ? 10 : 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(amount),
                        style: TextStyle(
                          fontSize: compact ? 10 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
