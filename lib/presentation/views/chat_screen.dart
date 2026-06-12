import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/chat/chat_view_model.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatViewModelProvider);
    final inputController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () =>
                ref.read(chatViewModelProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Message Bubble Thread List View
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Ask me details about your spending!\ne.g., "How much did I spend on food?"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? theme.colorScheme.primary
                                : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              message.isUser
                                  ? Text(
                                      message.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: message.text,
                                      styleSheet: MarkdownStyleSheet.fromTheme(
                                        theme,
                                      ).copyWith(p: theme.textTheme.bodyLarge),
                                    ),
                              // if (!message.isUser &&message.thinkingText != null) ...[
                              //   const Divider(height: 12),
                              //   Text(
                              //     message.thinkingText!,
                              //     style: TextStyle(
                              //       fontSize: 11,
                              //       color: theme.disabledColor,
                              //       fontStyle: FontStyle.italic,
                              //     ),
                              //   ),
                              // ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 2. Linear Loading Block during execution waits
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator.adaptive(),
            ),

          // 3. User Input Text Field Action Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: InputDecoration(
                        hintText: 'Ask financial data trends...',
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      final txt = inputController.text.trim();
                      if (txt.isNotEmpty) {
                        ref
                            .read(chatViewModelProvider.notifier)
                            .sendMessage(txt);
                        inputController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
