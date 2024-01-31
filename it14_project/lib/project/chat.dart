import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late OpenAI openAI;
  final List<ChatMessage> _conversations = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance
        .build(token: "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");
  }

  void send() async {
    var text = _controller.text;
    if (text.trim().isEmpty) {
      return;
    }
    _controller.clear();

    setState(() {
      _conversations.add(ChatMessage(text, true));
    });

    print('Sending request to OpenAI with prompt: $text');

    try {
      var resp = await openAI.onCompletion(
        request: CompleteText(
          prompt: text,
          model: TextBabbage001Model(),
        ),
      );

      print('Received response from OpenAI: $resp');

      if (resp != null && resp.choices.isNotEmpty) {
        setState(() {
          _conversations.add(ChatMessage(resp.choices.last.text, false));
        });
      } else {
        print('Response is empty or does not contain choices.');
      }
    } catch (e) {
      print('Error sending request to OpenAI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Task Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                var convo = _conversations[index];
                return Align(
                  alignment: convo.amSender
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: convo.amSender ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      convo.text,
                      style: TextStyle(
                        color: convo.amSender ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
              itemCount: _conversations.length,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(hintText: "Type here..."),
                    ),
                  ),
                  IconButton(onPressed: send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ChatMessage {
  String text;
  bool amSender;
  ChatMessage(this.text, this.amSender);
}
