import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/presentation/widgets/invoice_pdf_generator.dart';

/// Invoice Preview Dialog
/// Shows the invoice details and allows PDF download/print
class InvoicePreviewDialog extends StatelessWidget {
  final InvoiceEntity invoice;
  final ClientEntity client;

  const InvoicePreviewDialog({
    super.key,
    required this.invoice,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 600.w,
        padding: EdgeInsets.all(32.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACTURE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Boutique de Pièces Motos',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appDateTimeFormat.format(invoice.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              const Divider(),
              SizedBox(height: 16.h),

              // Client Info
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FACTURÉ À',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      invoice.clientName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4.h),
                    Text('CIN : ${invoice.clientCin}', style: const TextStyle(fontSize: 13)),
                    Text('Tél : ${invoice.clientMobile}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Items Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Produit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(child: Text('Réf', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(child: Text('Qté', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                          Expanded(child: Text('Prix Unit.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
                          Expanded(child: Text('Total HT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    // Item rows
                    ...invoice.items.map((item) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 13))),
                          Expanded(child: Text(item.referenceCode, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                          Expanded(child: Text(item.quantity.toString(), style: const TextStyle(fontSize: 13), textAlign: TextAlign.center)),
                          Expanded(child: Text(appCurrencyFormat.format(item.unitPrice), style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
                          Expanded(child: Text(appCurrencyFormat.format(item.lineTotalHT), style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Totals
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 250.w,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      AppLabelValueRow(
                        label: 'Sous-total (HT)',
                        value: appCurrencyFormat.format(invoice.totalWithoutTVA),
                      ),
                      SizedBox(height: 8.h),
                      AppLabelValueRow(
                        label: 'TVA (19%)',
                        value: appCurrencyFormat.format(invoice.tvaAmount),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      AppLabelValueRow(
                        label: 'Total (TTC)',
                        value: appCurrencyFormat.format(invoice.totalWithTVA),
                        isBold: true,
                        valueColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pdfData = await InvoicePdfGenerator.generateInvoicePdf(
                        invoice: invoice,
                      );
                      await Printing.layoutPdf(onLayout: (_) => pdfData);
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Imprimer / Sauv. PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
