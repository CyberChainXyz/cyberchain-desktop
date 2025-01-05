import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_channel.freezed.dart';
part 'chat_channel.g.dart';

@freezed
class ChatChannel with _$ChatChannel {
  const factory ChatChannel({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatChannel;

  factory ChatChannel.fromJson(Map<String, dynamic> json) =>
      _$ChatChannelFromJson(json);
}
