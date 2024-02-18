import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String APP_ID = 'YOUR_APP_ID';
  final String USER_ID = 'YOUR_USER_ID';
  final String USER_NICKNAME = 'YOUR_USER_NICKNAME';
  final String OPEN_CHANNEL_URL = 'YOUR_OPEN_CHANNEL_URL';
  final sendbird = SendbirdSdk(appId: 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF');
  TextEditingController _messageController = TextEditingController();
  List<BaseMessage> _messages = [];
  @override
  void initState() {
    super.initState();

    initSendbird();
    // openChannel();
  }

  void initSendbird() async {
    try {
      SendbirdSdk(appId: 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF');
      print('SendBird initialized');
      connectToSendBird();
    } catch (e) {
      print('Error initializing SendBird: $e');
    }
  }

  void connectToSendBird() async {
    try {
      final user = await sendbird.connect('1');
      print('user $user');
      joinChannel();
    } catch (e) {
      // error
      print('user error $e');
    }
  }

  void joinChannel() async {
    try {
      final channel = await OpenChannel.getChannel(
          'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211');
      await channel.enter();
      print('Joined channel: ${channel.name}');
      await fetchMessages(channel);
    } catch (e) {
      print('Error joining channel: $e');
    }
  }

  void sendMessage(String text) async {
    try {
      final channel = await OpenChannel.getChannel(
          'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211');
      final params = UserMessageParams(message: text);
      // ..message = text; // Set the message here
      await channel.sendUserMessage(params);
      _messageController.clear();
      fetchMessages(channel);
      print('Message sent: $text');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void openChannel() async {
    try {
      const String channelUrl =
          'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
      final channel = await OpenChannel.getChannel(channelUrl);
      await channel.enter();
      print('Opened channel: ${channel.name}');
    } catch (e) {
      print('Error opening channel: $e');
    }
  }

  Future<void> fetchMessages(OpenChannel channel) async {
    try {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch; // Current timestamp
      final params = MessageListParams();
      final messages = await channel.getMessagesByTimestamp(timestamp, params);
      print(messages);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B202D),
      appBar: AppBar(
        backgroundColor: Color(0xff1B202D),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // Handle back button press
            // Example: Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              // Handle menu button press
              // Example: OpenDrawer();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.sender!.userId == '1';
                  final timestamp = message.createdAt;
                  final formattedTime = DateFormat.Hm()
                      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
                  // Customize message display based on sender
                  return Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isCurrentUser) ...[
                            // Display avatar for other users
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              width: MediaQuery.of(context).size.width *
                                  0.1, // Half of screen width
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Center(
                                  child: Text(
                                    message.sender?.userId.substring(0, 1) ??
                                        '',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // Display message text
                          Flexible(
                            flex: 1,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width *
                                      0.5), // Maximum width constraint
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isCurrentUser ? Colors.pink : Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 60.0), // Space for input container
            child: Center(
              child: Text('Main Content'),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Handle additional functionality
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              // Handle send message
                              sendMessage(_messageController.text);
                            },
                          ),
                        ],
                      ),
                    ),
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
