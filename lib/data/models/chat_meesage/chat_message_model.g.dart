// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  text: json['text'] as String,
  isUser: json['isUser'] as bool,
  time: DateTime.parse(json['time'] as String),
  thinkingText: json['thinkingText'] as String?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'text': instance.text,
      'isUser': instance.isUser,
      'time': instance.time.toIso8601String(),
      'thinkingText': instance.thinkingText,
    };
