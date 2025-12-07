import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction.dart';
import '../utils/app_utils.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  String _selectedFilter = 'all';
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Giao Dịch'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tất Cả'),
                  _buildFilterChip('income', 'Thu Nhập'),
                  _buildFilterChip('expense', 'Chi Tiêu'),
                ],
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refresh();
              },
              child: FutureBuilder<List<TransactionModel>>(
                key: ValueKey(_refreshKey),
                future: _getTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Không có giao dịch nào'),
                    );
                  }

                  final transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionCard(
                        title: tx.title,
                        amount: tx.amount,
                        category: tx.category,
                        icon: tx.type == 'income' ? '💰' : '💸',
                        date: AppUtils.formatDate(tx.date),
                        type: tx.type,
                        onDelete: () => _deleteTransaction(tx.id!),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color: _selectedFilter == value ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Future<List<TransactionModel>> _getTransactions() async {
    if (_selectedFilter == 'all') {
      return await _transactionRepository.getAllTransactions();
    } else {
      return await _transactionRepository
          .getTransactionsByType(_selectedFilter);
    }
  }

  Future<void> _deleteTransaction(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Giao Dịch'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _transactionRepository.deleteTransaction(id);
      if (mounted) {
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa giao dịch thành công')),
        );
      }
    }
  }
}
