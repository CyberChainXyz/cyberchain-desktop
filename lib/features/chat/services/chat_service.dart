import '../models/chat_message.dart';
import '../models/chat_user.dart';

abstract class ChatService {
  Future<ChatUser> createUser(String name, String avatarId);
  Future<void> connect();
  Future<void> disconnect();
  Future<void> sendMessage(String content);
  Stream<ChatMessage> get messageStream;
  Stream<List<ChatMessage>> get initialMessages;
  bool get isConnected;
  ChatUser? get currentUser;
}
