import '../../../core/services/receipt_scan_service.dart';

class ReceiptScanState {
  final bool isScanning;
  final ReceiptScanResult? result;
  final String? error;

  const ReceiptScanState({this.isScanning = false, this.result, this.error});

  ReceiptScanState copyWith({bool? isScanning, ReceiptScanResult? result, String? error}) {
    return ReceiptScanState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}