import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction.dart';
import '../utils/app_utils.dart';
import '../widgets/transaction_card.dart';
import 'transaction_detail_screen.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  String _selectedFilter = 'all';
  String _selectedSort =
      'date_newest'; // date_newest, date_oldest, amount_asc, name_asc
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  List<TransactionModel> _sortTransactions(
      List<TransactionModel> transactions) {
    final sorted = List<TransactionModel>.from(transactions);

    switch (_selectedSort) {
      case 'name_asc':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'amount_asc':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'date_oldest':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_newest':
      default:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Danh Sách Giao Dịch'),
      //   backgroundColor: Colors.blue.shade700,
      // ),
      body: Column(
        children: [
          // Filter Buttons (Type)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('income', 'Income'),
                  _buildFilterChip('expense', 'Expense'),
                ],
              ),
            ),
          ),

          // Sort Dropdown
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 20.0),
              child: SizedBox(
                width: 150,
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  underline: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'date_newest',
                      child:
                          Text('Date (Newest)', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'date_oldest',
                      child:
                          Text('Date (Oldest)', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'name_asc',
                      child: Text('Name (A-Z)', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'amount_asc',
                      child: Text('Amount (Low to High)',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSort = value;
                      });
                    }
                  },
                ),
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
                      child: Text('No transactions'),
                    );
                  }

                  final transactions = _sortTransactions(snapshot.data!);
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
                        onTap: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) =>
                                TransactionDetailScreen(transaction: tx),
                          );
                          if (result == true) {
                            _refresh();
                          }
                        },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
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
        _refresh();
      }
    });
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
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _transactionRepository.deleteTransaction(id);
      if (mounted) {
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      }
    }
  }
}
