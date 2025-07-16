import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../database/transaction_service.dart';
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmation_screen.dart';

class PemasukanScreen extends StatefulWidget {
  const PemasukanScreen({super.key});

  @override
  State<PemasukanScreen> createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: 'Rp4.000.000',
  );
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Gaji';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    if (_amountController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tidak boleh kosong')),
      );
      return;
    }

    String amountStr = _amountController.text
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    double amount = double.tryParse(amountStr) ?? 0.0;

    final transaction = Transaction(
      userId: 0,
      type: 'income',
      category: _selectedCategory,
      description: _descriptionController.text,
      amount: amount,
      date: _selectedDate,
    );

    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationScreen(
        transaction: transaction,
        title: 'Total Pemasukan',
        icon: Icons.upload_rounded,
      ),
    );

    if (isConfirmed == true) {
      _executeSave(transaction);
    }
  }

  Future<void> _executeSave(Transaction transaction) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User tidak ditemukan')));
        return;
      }

      final finalTransaction = Transaction(
        userId: userId,
        type: transaction.type,
        category: transaction.category,
        description: transaction.description,
        amount: transaction.amount,
        date: transaction.date,
      );

      final result = await TransactionService().addTransaction(finalTransaction);

      if (!mounted) return;

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result['message'])));
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${result['message']}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Pemasukan',
          style: GoogleFonts.manrope(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Tanggal'),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: _inputDecoration(
                'Select the date',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel('Kategori'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(''),
              items: <String>['Gaji', 'Bonus', 'Investasi', 'Lainnya']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Keterangan'),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration('Tambahkan Keterangan'),
            ),
            const SizedBox(height: 20),
            _buildLabel('Jumlah'),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                '',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.money, color: Color(0xFF2C2C54), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'IDR',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _showConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C54),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      'Simpan Pemasukan',
                      style: GoogleFonts.manrope(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hintText, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}