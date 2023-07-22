import "package:flutter/material.dart";
import "package:synergyvisitorlog/extendeddetails.dart";
import "package:synergyvisitorlog/main.dart";
import "package:synergyvisitorlog/photo.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:synergyvisitorlog/mobile.dart";

// Name section of the enroll process
class Name extends StatefulWidget {
  const Name({
    Key? key,
  }) : super(key: key);

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Initalization for snackbar
  late SpeechToText speechToText =
      SpeechToText(); // Initalization for speech-to-text
  late List<int> stepsforenroll = []; // Steps left for enrollment to complete!
  final nameController = TextEditingController(); // Texteditingcontroller
  bool validate = false; // Variable to store the bool value
  bool speechEnabled = false; // Whether the speech is enabled or not

  // This runs only once when the widget is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    loadName();
  }

  // Loads the saved data from the local storage.
  void loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("name")) {
      setState(() {
        nameController.text = (prefs.getString("name"))!;
      });
    }
    if (prefs.containsKey("steps")) {
      List<String>? stepsString = prefs.getStringList("steps");
      if (stepsString != null) {
        List<int> steps = stepsString.map((step) => int.parse(step)).toList();
        setState(() {
          stepsforenroll = steps;
        });
      }
    }
  }

  // Data "name" is being pushed into the local storage.
  void setName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", nameController.text);
  }

  // Initialization od the speech-to-text process
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  // Runs each time to start a speech recognition session
  void startListening() async {
    try {
      await speechToText.listen(onResult: speechResult);
    } catch (e) {
      // Handle the error here, such as displaying an error message or fallback behavior
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: SizedBox(
                  width: 75 / 100 * MediaQuery.of(context).size.width,
                  child: Text(
                    'Error: $e!',
                    style: const TextStyle(
                      fontFamily: "ComicNeue",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFBD6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    setState(() {});
  }

  // To manually stop the active speech recognition session
  void stopListening() async {
    try {
      await speechToText.stop();
    } catch (e) {
      // Handle the error here, such as displaying an error message or fallback behavior
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: SizedBox(
                  width: 75 / 100 * MediaQuery.of(context).size.width,
                  child: Text(
                    'Error: $e!',
                    style: const TextStyle(
                      fontFamily: "ComicNeue",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFFFBD6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void speechResult(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalizeName(recognizedWords);

    setState(() {
      nameController.text = capitalizedWords;
      nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: nameController.text.length));
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

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
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
                    stops: [0.1, 0.45, 0.9],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  color: const Color.fromARGB(120, 255, 255, 255),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 254, 227, 227),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Text(
                          "Enroll!",
                          style: TextStyle(
                            fontFamily: "MonomaniacOne",
                            fontSize: 36,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Text(
                          "Please enter visitor's name!",
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
                            const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 85 /
                                      100 *
                                      MediaQuery.of(context).size.width,
                                  child: const Divider(
                                    color: Color(0xFFFFFBD6),
                                    thickness: 2,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    for (var step in stepsforenroll)
                                      GestureDetector(
                                        onTap: () {
                                          // Define the navigation logic based on the step number
                                          if (step == 1) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const Name(),
                                              ),
                                            );
                                            setName();
                                          } else if (step == 2) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const Mobile(),
                                              ),
                                            );
                                            setName();
                                          } else if (step == 3) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const Photo(),
                                              ),
                                            );
                                            setName();
                                          } else if (step == 4) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ExtendedDetails(),
                                              ),
                                            );
                                            setName();
                                          }
                                        },
                                        child: Icon(
                                          Icons.circle,
                                          color: step == 1
                                              ? const Color(0xFF008B6A)
                                              : const Color(0xFFFFFBD6),
                                          size: step == 1 ? 40.0 : 25.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 10, 0, 15),
                              child: Text(
                                // If listening is active show the recognized words
                                speechToText.isListening
                                    ? "Listening..."
                                    // If listening isn"t active tell the user that speech recognition is not yet ready or not supported on the target device
                                    : speechEnabled
                                        ? "Tap the microphone to start listening..."
                                        : "Speech-to-text not available",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 65, 65, 65),
                                ),
                              ),
                            ),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                              cursorColor:
                                  const Color.fromARGB(255, 70, 70, 70),
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
                                errorText: validate
                                    ? "Please enter visitor's name!"
                                    : null,
                                errorStyle: const TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFFF0000),
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
                              onChanged: (value) {
                                setState(() {
                                  value.isEmpty
                                      ? validate = true
                                      : validate = false;
                                });
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    validate = true;
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Mobile(),
                                      ),
                                    );
                                    setName();
                                  }
                                });
                              },
                              keyboardType: TextInputType.text,
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 20, 0, 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                onPressed: () {
                                  if (nameController.text.isEmpty) {
                                    setState(() {
                                      nameController.text.isEmpty
                                          ? validate = true
                                          : validate = false;
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Mobile(),
                                      ),
                                    );
                                    setName();
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 15),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 0, 0),
                                          child: Text(
                                            "Next",
                                            style: TextStyle(
                                              fontFamily: "ComicNeue",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 65, 65, 65),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ),
            );
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
    );
  }
}
