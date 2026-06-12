import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/db_helper.dart';
import '../../../data/models/chat_meesage/chat_message_model.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  return ChatViewModel();
});

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel() : super(ChatState(messages: []));

  final List<ChatMessage> _messages = [];
  static const _model = 'gemma-4-26b-a4b-it';
  static const _modelFlashLite = 'gemini-3.1-flash-lite';
  static final _key = AppConstants.geminiApiKey;

  static final _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_key';
  static final _urlFlashLite =
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelFlashLite:generateContent?key=$_key';

  Future<void> sendMessage(String userText) async {
    // 1. Immediately append the user message to the UI state
    final userMsg = ChatMessage(
      text: userText,
      isUser: true,
      time: DateTime.now(),
    );
    _messages.add(userMsg);
    state = state.copyWith(messages: List.from(_messages), isLoading: true);

    try {
      // 2. Convert natural phrase to safe SQL via Gemini
      final sqlQuery = await _generateSqlFromText(userText);
      dev.log('RAG Engine Generated SQL: $sqlQuery');

      // 3. Directly query your existing local SQLite DBHelper
      dynamic dbResult;
      if (sqlQuery.trim().toUpperCase().startsWith('SELECT')) {
        dbResult = await DBHelper().rawQuery(sqlQuery);
      } else {
        final db = await DBHelper().database;
        dbResult = await db.rawInsert(sqlQuery);
      }

      // 4. Send the raw query results back to Gemini for a human-readable summary
      final narrativeAnswer = await _generateFinalSummary(
        userText,
        sqlQuery,
        dbResult,
      );

      // 5. Append the AI reply to the UI state
      final aiMsg = ChatMessage(
        text: narrativeAnswer,
        isUser: false,
        time: DateTime.now(),
        thinkingText: "Executed Query: $sqlQuery",
      );
      _messages.add(aiMsg);
      state = state.copyWith(messages: List.from(_messages), isLoading: false);
    } catch (e, s) {
      dev.log('RAG execution failure', error: e, stackTrace: s);

      final errorMsg = ChatMessage(
        text:
            "I couldn't process that database request. Please try phrasing it differently.",
        isUser: false,
        time: DateTime.now(),
      );
      _messages.add(errorMsg);
      state = state.copyWith(messages: List.from(_messages), isLoading: false);
    }
  }

  Future<String> _generateSqlFromText(String userPrompt) async {
    // 1. Get current date dynamically (e.g., "2026-06-12")
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    // 2. Compact, highly compressed system prompt
    final systemPrompt =
        '''
You are a SQLite translator. Output ONLY raw executable SQL based on this schema:
categories(id INTEGER PK, name TEXT UNIQUE, icon TEXT, color TEXT, type TEXT CHECK(type IN('expense','income')))
expenses(id INTEGER PK, title TEXT, amount REAL, type TEXT CHECK(type IN('expense','income')), category_id FK->categories.id, merchant TEXT, date TEXT, note TEXT, source TEXT, receipt_path TEXT, created_at TEXT)

RULES:
- No markdown wrappers (Do NOT use \`\`\`sql or \`\`\`).
- No text explanations, greetings, or punctuation outside the valid query.
- Date format is ISO8601 (YYYY-MM-DDThh:mm:ss.sss).
- Current date is $todayStr. Use this for relative dates ("today", "this week", "last month").
''';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$systemPrompt\n\nUser Request: $userPrompt'},
          ],
        },
      ],
    });

    final res = await http.post(
      Uri.parse(_urlFlashLite),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode != 200) throw Exception('SQL Generation Failed');

    final data = jsonDecode(res.body);
    final parts = data['candidates']?[0]?['content']?['parts'] as List?;
    final textResult = parts
        ?.where((p) => p['thought'] != true)
        .map((p) => p['text'] as String? ?? '')
        .join('');
    return textResult?.replaceAll('```sql', '').replaceAll('```', '').trim() ??
        '';
  }

  Future<String> _generateFinalSummary(
    String userPrompt,
    String sqlUsed,
    dynamic dbRows,
  ) async {
    final systemPrompt =
        '''
You are an expert data analyst assistant for an expense tracker application. 
Translate the provided raw SQLite table results into an answer for the user's original request.

Original User Intent: "$userPrompt"
SQL Query Run: "$sqlUsed"
Database Result JSON Rows: "${jsonEncode(dbRows)}"

Formatting Rules:
- Display datasets cleanly using Markdown bulleted lists or standard markdown tables.
- Keep responses concise and highlight critical numeric targets in **bold**.
- If no matching data exists in the JSON rows, tell the user gracefully.
''';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': systemPrompt},
          ],
        },
      ],
    });

    final res = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode != 200) throw Exception('Summary Generation Failed');

    final data = jsonDecode(res.body);
    final parts = data['candidates']?[0]?['content']?['parts'] as List?;
    return parts
            ?.where((p) => p['thought'] != true)
            .map((p) => p['text'] as String? ?? '')
            .join('')
            .trim() ??
        'No narrative output found.';
  }

  void clearChat() {
    _messages.clear();
    state = ChatState(messages: []);
  }
}
