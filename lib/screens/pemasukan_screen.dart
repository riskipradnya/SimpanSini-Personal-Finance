import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  String _selectedCategory = 'Gaji';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format tanggal ke dalam string 'dd MMMM yyyy' (e.g., 07 Juli 2025)
        _dateController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
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
        title: const Text(
          'Tambah Pemasukan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            // Tanggal
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

            // Kategori
            _buildLabel('Kategori'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(''),
              items: <String>['Gaji', 'Bonus', 'Investasi', 'Lainnya'].map((
                String value,
              ) {
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

            // Keterangan
            _buildLabel('Keterangan'),
            TextFormField(decoration: _inputDecoration('Tambahkan Keterangan')),
            const SizedBox(height: 20),

            // Jumlah
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.money, color: Color(0xFF2C2C54), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'IDR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Tombol Simpan
            ElevatedButton(
              onPressed: () {
                // Logika untuk menyimpan data
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C54),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Simpan Pemasukan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // Helper untuk dekorasi input
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
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 10.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
