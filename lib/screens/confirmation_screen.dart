import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class ConfirmationScreen extends StatelessWidget {
  final Transaction transaction;
  final String title; // <-- Parameter baru untuk judul
  final IconData icon;  // <-- Parameter baru untuk ikon

  const ConfirmationScreen({
    super.key,
    required this.transaction,
    required this.title,
    required this.icon,
  });

  // Helper untuk memformat angka menjadi format mata uang Rupiah
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon( // <-- Menggunakan ikon dari parameter
                icon,
                color: Colors.black87,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Judul
            Text(
              title, // <-- Menggunakan judul dari parameter
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            // Jumlah
            Text(
              _formatCurrency(transaction.amount),
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Detail
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 16),
                _buildDetailRow('Kategori', transaction.category),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Tanggal',
                  DateFormat('d/M/y').format(transaction.date),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Total',
                  _formatCurrency(transaction.amount),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}