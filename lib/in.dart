import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class In extends StatefulWidget {
  const In({super.key});

  @override
  State<In> createState() => _InState();
}

class _InState extends State<In> {
  final myName = TextEditingController(); // texteditingcontroller
  bool validate = false; // variable to store the bool value
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not
  List<DocumentSnapshot>? myUsers; // Nullable list

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    fetchUsers();
  }

  // This has to happen only once per app
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  // Each time to start a speech recognition session
  void startListening() async {
    await speechToText.listen(onResult: speechResult);
    setState(() {});
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void speechResult(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalizeName(recognizedWords);

    setState(() {
      myName.text = capitalizedWords;
      myName.selection =
          TextSelection.fromPosition(TextPosition(offset: myName.text.length));
    });
  }

  String capitalizeName(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.toLowerCase().split(' ');

    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(' ');
  }

  // fetch data from the database about all the users
  void fetchUsers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").get();
    setState(() {
      myUsers = snapshot.docs;
    });
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    myName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBD6),
        foregroundColor: const Color.fromARGB(255, 70, 70, 70),
        title: const Text(
          "In",
          style: TextStyle(
            color: Color.fromARGB(255, 70, 70, 70),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF008B6A),
                    Color(0xFFFF0000),
                    Color(0xFFFFFBD6),
                  ],
                  stops: [0.17, 0.45, 0.725],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(120, 255, 255, 255),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                        child: Text(
                          "Get In!",
                          style: TextStyle(
                            fontFamily: "MonomaniacOne",
                            fontSize: 36,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Text(
                          "Please enter your name!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "ComicNeue",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 65, 65, 65),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: TextField(
                          controller: myName,
                          style: const TextStyle(
                            fontFamily: "ComicNeue",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 65, 65, 65),
                          ),
                          cursorColor: const Color.fromARGB(255, 70, 70, 70),
                          obscureText: false,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText: "Eg: Virat Kohli",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFFFBD6),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF008B6A),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFF0000),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFF0000),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    20, 20, 20, 20),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.mic_rounded,
                                color: Color.fromARGB(255, 70, 70, 70),
                              ),
                              onPressed: // If not yet listening for speech start, otherwise stop
                                  speechToText.isNotListening
                                      ? startListening
                                      : stopListening,
                            ),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 12.5, 0, 5),
                        child: Text(
                          // If listening is active show the recognized words
                          speechToText.isListening
                              ? "Listening..."
                              // If listening isn"t active but could be tell the user
                              // how to start it, otherwise indicate that speech
                              // recognition is not yet ready or not supported on
                              // the target device
                              : speechEnabled
                                  ? "Tap the microphone to start listening..."
                                  : "Speech not available",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "ComicNeue",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color.fromARGB(255, 65, 65, 65),
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFFFFFBD6),
                        thickness: 2,
                      ),
                      // ListView.builder(
                      //   itemCount: 10,
                      //   itemBuilder: (context, index) {
                      //     return ListTile(
                      //       title: Text('Item $index'),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF008B6A),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
