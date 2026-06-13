import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ReceiptScanResult {
  final String? merchantName;
  final String? date;
  final double? amount;
  final String? category; // matches your seeded category names
  final String? rawError;

  ReceiptScanResult({this.merchantName, this.date, this.amount, this.category, this.rawError});
}

class ReceiptScanService {
  static const _model = 'gemma-4-26b-a4b-it';
  static final _key = AppConstants.geminiApiKey;
  static final _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_key';

  Future<ReceiptScanResult> scanReceipt(File imageFile, List<String> categoryNames) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = imageFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
    dev.log("scan start");

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image}
            },
            {
              'text': '''Extract from this receipt and respond ONLY with valid JSON (no markdown, no extra text):
{
  "merchant": "<merchant name or null>",
  "date": "<ISO8601 date YYYY-MM-DDT00:00:00.000 or null>",
  "amount": <total amount as number or null>,
  "category": "<one of: ${categoryNames.join(', ')} — or suggest a new single-word category name if none fit>"
}'''
            }
          ]
        }
      ]
    });

    final res = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      dev.log("${res.body}");
      return ReceiptScanResult(rawError: 'API error ${res.statusCode}');
    }

    try {
      final data = jsonDecode(res.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;
      final text = parts
              ?.where((p) => p['thought'] != true)
              .map((p) => p['text'] as String? ?? '')
              .join('')
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim() ??
          '';

      final json = jsonDecode(text);
      return ReceiptScanResult(
        merchantName: json['merchant'],
        date: json['date'],
        amount: (json['amount'] as num?)?.toDouble(),
        category: json['category'],
      );
    } catch (e) {
      return ReceiptScanResult(rawError: 'Parse failed: $e');
    }
  }

}