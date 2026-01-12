import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/wallet_repository.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../utils/app_utils.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WalletRepository _walletRepository = WalletRepository();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense';
  String? _selectedCategory;
  int? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();
  List<Category> _categories = [];
  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await _walletRepository.getAllWallets();
    setState(() {
      _wallets = wallets;
      _selectedWalletId = wallets.isNotEmpty ? wallets[0].id : null;
    });
  }

  Future<void> _loadCategories() async {
    final categories =
        await _categoryRepository.getCategoriesByType(_selectedType);
    setState(() {
      _categories = categories;
      _selectedCategory = categories.isNotEmpty ? categories[0].name : null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTransaction() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill in all fields (including selecting a wallet')),
      );
      return;
    }

    try {
      final transaction = TransactionModel(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        type: _selectedType,
        date: _selectedDate,
        description: _descriptionController.text,
        walletId: _selectedWalletId,
      );

      await _transactionRepository.addTransaction(transaction);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add transaction'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: !isMobile,
      ),
      body: isMobile
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFormFields(),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFormFields(),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Type Selection
      const Text('Transaction type'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
                _loadCategories();
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Title
      TextField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Amount
      TextField(
        controller: _amountController,
        decoration: InputDecoration(
          labelText: 'Amount (VND)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),

      // Wallet Selection
      const Text('Wallet'),
      const SizedBox(height: 8),
      _wallets.isEmpty
          ? InkWell(
              onTap: () {
                // Navigate to MainScreen with Wallets tab (index 3)
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context)
                    .pushReplacementNamed('/home', arguments: 3);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Please create a wallet before adding a transaction',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          : DropdownButton<int>(
              isExpanded: true,
              value: _selectedWalletId,
              items: _wallets.map((wallet) {
                return DropdownMenuItem<int>(
                  value: wallet.id,
                  child: Text(
                      '${wallet.name} - ${AppUtils.formatCurrency(wallet.balance)}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWalletId = value;
                });
              },
            ),
      const SizedBox(height: 16),

      // Category
      const Text('Category'),
      const SizedBox(height: 8),
      _categories.isEmpty
          ? InkWell(
              onTap: () {
                // Navigate to MainScreen with Categories tab (index 4)
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context)
                    .pushReplacementNamed('/home', arguments: 4);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Please create a category before adding a transaction',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          : DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text('${category.icon} ${category.name}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
      const SizedBox(height: 16),

      // Date
      const Text('Date'),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 12),
              Text(AppUtils.formatDateShort(_selectedDate)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Description
      TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Notes (Optional)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        maxLines: 3,
      ),
      const SizedBox(height: 24),

      // Add Button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
