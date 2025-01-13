import 'package:http/http.dart';

// Add these imports - but note they won't work on browsers (i.e., Flutter for Web)
import 'dart:io';
import 'package:http/io_client.dart';
import 'user_agent_utils.dart';

Client getClient() {
  final innerClient = HttpClient()..userAgent = UserAgentUtils.getUserAgent();

  return IOClient(innerClient);
}
