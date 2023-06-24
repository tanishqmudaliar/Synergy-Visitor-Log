import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:synergyvisitorlog/extendeddetails.dart";
import 'package:synergyvisitorlog/name.dart';
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import "package:synergyvisitorlog/photo.dart";

class Mobile extends StatefulWidget {
  const Mobile({
    super.key,
  });

  @override
  State<Mobile> createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  final myNumber = TextEditingController(); //  texteditingcontroller
  bool validate = false; // variable to store the bool value
  late List<int> stepsforenroll = []; // steps to enroll!
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    loadNumber();
  }

  // This has to happen only once per app
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  // Loads the saved data from the local storage.
  void loadNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("number") == true) {
      setState(() {
        myNumber.text = (prefs.getString("number"))!;
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

  // Data "number" is being pushed into the local storage.
  void setNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("number", myNumber.text);
    });
  }

  // Each time to start a speech recognition session
  void startListening() async {
    await speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {});
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    String sanitizedResult =
        result.recognizedWords.replaceAll(RegExp(r'[^0-9 ]'), '');
    sanitizedResult = sanitizedResult.replaceAll(' ', '');
    setState(() {
      myNumber.text = sanitizedResult;
      myNumber.selection = TextSelection.fromPosition(
          TextPosition(offset: myNumber.text.length));
    });
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    myNumber.dispose();
    super.dispose();
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                      child: Text(
                        "Enroll!",
                        style: TextStyle(
                          fontFamily: "MonomaniacOne",
                          fontSize: 36,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        "Please enter your phone number!",
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
                          const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 20),
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
                                          setNumber();
                                        } else if (step == 2) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const Mobile(),
                                            ),
                                          );
                                          setNumber();
                                        } else if (step == 3) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const Photo(),
                                            ),
                                          );
                                          setNumber();
                                        } else if (step == 4) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ExtendedDetails(),
                                            ),
                                          );
                                          setNumber();
                                        }
                                      },
                                      child: Icon(
                                        Icons.circle,
                                        color: step == 1 || step == 2
                                            ? const Color(0xFF008B6A)
                                            : const Color(0xFFFFFBD6),
                                        size: step == 2 ? 38.0 : 22.0,
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
                          TextField(
                            maxLength: 10,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            controller: myNumber,
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
                              labelText: "Phone number",
                              labelStyle: const TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                              hintText: "Eg: 2220875021",
                              hintStyle: const TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                              errorText:
                                  validate ? "Please enter your Number!" : null,
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
                            onSubmitted: (value) {
                              if (value.isEmpty == true) {
                                setState(() {
                                  value.isEmpty
                                      ? validate = true
                                      : validate = false;
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Photo(),
                                  ),
                                );
                                setNumber();
                              }
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9+-]"))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 20, 0, 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {
                                if (myNumber.text.isEmpty == true) {
                                  setState(() {
                                    myNumber.text.isEmpty
                                        ? validate = true
                                        : validate = false;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Photo(),
                                    ),
                                  );
                                  setNumber();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 10),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5, 0, 0, 0),
                                        child: Text(
                                          "Next",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 65, 65, 65),
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
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
