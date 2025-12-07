import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/app_utils.dart';
import '../widgets/transaction_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  late Future<List<TransactionModel>> _transactionsFuture;
  late Future<double> _incomeFuture;
  late Future<double> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _transactionsFuture = _transactionRepository.getAllTransactions();
    _incomeFuture = _transactionRepository.getTotalIncome();
    _expenseFuture = _transactionRepository.getTotalExpense();
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
      appBar: AppBar(
        title: const Text('Quản Lý Tài Chính'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                FutureBuilder<double>(
                  future: _incomeFuture,
                  builder: (context, snapshot) {
                    final income = snapshot.data ?? 0.0;
                    return FutureBuilder<double>(
                      future: _expenseFuture,
                      builder: (context, snapshotExpense) {
                        final expense = snapshotExpense.data ?? 0.0;
                        return Column(
                          children: [
                            SummaryCard(
                              title: 'Tổng Thu Nhập',
                              amount: income,
                              color: Colors.green,
                              icon: Icons.arrow_downward,
                            ),
                            const SizedBox(height: 12),
                            SummaryCard(
                              title: 'Tổng Chi Tiêu',
                              amount: expense,
                              color: Colors.red,
                              icon: Icons.arrow_upward,
                            ),
                            const SizedBox(height: 12),
                            SummaryCard(
                              title: 'Số Dư',
                              amount: income - expense,
                              color: Colors.blue,
                              icon: Icons.wallet,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Giao Dịch Gần Đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Transactions List
                FutureBuilder<List<TransactionModel>>(
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
                            return TransactionCard(
                              title: tx.title,
                              amount: tx.amount,
                              category: tx.category,
                              icon: icon,
                              date: AppUtils.formatDate(tx.date),
                              type: tx.type,
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
}
