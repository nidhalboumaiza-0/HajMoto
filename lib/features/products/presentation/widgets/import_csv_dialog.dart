import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';

/// Import CSV Dialog
/// Allows importing products from a CSV file
/// Expected CSV format: referenceCode, name, category, purchasePrice, sellingPrice, quantity
class ImportCsvDialog extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onImport;

  const ImportCsvDialog({super.key, required this.onImport});

  @override
  State<ImportCsvDialog> createState() => _ImportCsvDialogState();
}

class _ImportCsvDialogState extends State<ImportCsvDialog> {
  String? _fileName;
  List<Map<String, dynamic>>? _parsedData;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 500.w,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    'Importer des Produits depuis un CSV',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Instructions
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CSV Format:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'referenceCode, name, category, purchasePrice, sellingPrice, quantity',
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Categories: vespa_parts, forza_parts, vespa_scooter, forza_scooter',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Pick file button
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file_rounded),
                  label: Text(_fileName ?? 'Sélectionner un Fichier CSV'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                ),
              ),
            ),

            if (_error != null) ...[
              SizedBox(height: 12.h),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],

            if (_parsedData != null) ...[
              SizedBox(height: 12.h),
              Text(
                  '${_parsedData!.length} produits trouvés dans le fichier',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],

            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _parsedData != null
                      ? () {
                          widget.onImport(_parsedData!);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Import'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.length < 2) {
        setState(() {
            _error = 'Le fichier CSV doit contenir au moins un en-tête et une ligne de données';
          _parsedData = null;
        });
        return;
      }

      // Skip header row
      final dataRows = rows.sublist(1);
      final parsed = dataRows.map((row) {
        return {
          'referenceCode': row[0].toString().trim(),
          'name': row[1].toString().trim(),
          'category': row[2].toString().trim(),
          'purchasePrice': row[3].toString().trim(),
          'sellingPrice': row[4].toString().trim(),
          'quantity': row[5].toString().trim(),
        };
      }).toList();

      setState(() {
        _fileName = result.files.single.name;
        _parsedData = parsed;
        _error = null;
      });
    } catch (e) {
      setState(() {
          _error = 'Échec de l\'analyse du CSV : ${e.toString()}';
        _parsedData = null;
      });
    }
  }
}
