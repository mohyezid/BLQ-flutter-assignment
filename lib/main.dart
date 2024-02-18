import 'package:chat/view/ChatPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SendbirdSdk(appId: 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF');
    print('SendBird initialized');
  } catch (e) {
    print('Error initializing SendBird: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}
