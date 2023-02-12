import 'dart:convert';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chatgpt/pages/landingPage/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'model.dart';

const backgroundColor = Colors.white;
const botBackgroundColor = Color(0xff2f3fef);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = apiScretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}

class _LandingPageState extends State<LandingPage> {
  late bool isLoading;
  TextEditingController _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  DateTime now = DateTime.now();
  String time = DateFormat('hh:mm a').format(DateTime.now()).toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeae8f4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Real Assist Ai",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            Text(
              'This is a private message between you and the assistant',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            )
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: const Color(0xffdddaf2),
                      border: Border.all(
                        color: const Color(0xffdddaf2),
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: const Text(
                    'This chat is end to end encrypted',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff5548a5),
                    ),
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            BubbleNormal(
              text: 'Hey, this is Real Assit AI, How i can help you?',
              isSender: false,
              color: Colors.white,
              tail: true,
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(child: _buildList()),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Color(0xff5548a5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInout(),
                  RawMaterialButton(
                    onPressed: () {},
                    elevation: 0,
                    fillColor: botBackgroundColor,
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                    child: const Icon(
                      Icons.mic_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded _buildInout() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.black),
        controller: _textEditingController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.send_rounded),
            onPressed: () async {
              setState(
                () {
                  _messages.add(
                    ChatMessage(
                      text: _textEditingController.text,
                      chatMessageType: ChatMessageType.user,
                    ),
                  );
                  isLoading = true;
                },
              );
              var input = _textEditingController.text;
              _textEditingController.clear();
              Future.delayed(const Duration(milliseconds: 50))
                  .then((_) => _scrollDown());
              generateResponse(input).then((value) {
                setState(() {
                  isLoading = false;
                  _messages.add(
                    ChatMessage(
                      text: value,
                      chatMessageType: ChatMessageType.bot,
                    ),
                  );
                });
              });
              _textEditingController.clear();
              Future.delayed(const Duration(milliseconds: 50))
                  .then((_) => _scrollDown());
            },
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          hintText: 'Message',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          // focusedBorder: InputBorder.none,
          // enabledBorder: InputBorder.none,
          // errorBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return Column(
          children: [
            ChatMessageWidget(
              text: message.text,
              chatMessageType: message.chatMessageType,
            ),
            // ignore: prefer_const_constructors
            SizedBox(
              height: 30,
            )
          ],
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return BubbleNormal(
      text: text,
      isSender: chatMessageType == ChatMessageType.bot ? false : true,
      color: chatMessageType == ChatMessageType.bot
          ? backgroundColor
          : botBackgroundColor,
      tail: true,
      textStyle: TextStyle(
        fontSize: 14,
        color: chatMessageType == ChatMessageType.bot
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}
