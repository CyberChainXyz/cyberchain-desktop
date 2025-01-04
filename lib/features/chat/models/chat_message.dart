import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    required DateTime timestamp,
    @Default(MessageType.text) MessageType type,
    @Default(1) int version,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

enum MessageType {
  text,
  emoji,
}
