// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:synergyvisitorlog/detailconfirm.dart';
import 'package:synergyvisitorlog/mobile.dart';
import 'package:synergyvisitorlog/name.dart';
import 'package:synergyvisitorlog/photo.dart';

class ExtendedDetails extends StatefulWidget {
  const ExtendedDetails({super.key});

  @override
  State<ExtendedDetails> createState() => _ExtendedDetailsState();
}

class _ExtendedDetailsState extends State<ExtendedDetails> {
  final myCompanyName = TextEditingController(); // texteditingcontroller
  final myCompanyAddress = TextEditingController(); // texteditingcontroller
  bool validateCN = false; // variable to store the bool value
  bool validateCA = false; // variable to store the bool value
  String? myName; // user name
  String? myNumber; // user number
  String? myImage; // user image
  final List<int> steps = [1, 2, 3, 4]; // steps to enroll!
  bool speechEnabled = false; // Whether the speech is enabled or not
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  FocusNode focusNodeCA = FocusNode(); // Defining the focus node

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    loadDetails();
  }

  // This has to happen only once per app
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  // Loads the saved data from the local storage.
  void loadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("imagePath") == true) {
      setState(() {
        myImage = prefs.getString("imagePath")!;
      });
    }
    if (prefs.containsKey("name") == true) {
      setState(() {
        myName = prefs.getString("name")!;
      });
    }
    if (prefs.containsKey("number") == true) {
      setState(() {
        myNumber = prefs.getString("number")!;
      });
    }
    if (prefs.containsKey("companyName") == true) {
      setState(() {
        myCompanyName.text = prefs.getString("companyName")!;
      });
    }
    if (prefs.containsKey("companyAddress") == true) {
      setState(() {
        myCompanyAddress.text = prefs.getString("companyAddress")!;
      });
    }
  }

  // Data "company name & company address" is being pushed into the local storage.
  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("companyName", myCompanyName.text);
    });
    setState(() {
      prefs.setString("companyAddress", myCompanyAddress.text);
    });
    setState(() {
      prefs.setBool("extended", true);
    });
  }

  // Each time to start a speech recognition session
  void startListeningCompanyName() async {
    await speechToText.listen(onResult: speechResultCompanyName);
    setState(() {});
  }

  // Each time to start a speech recognition session
  void startListeningCompanyAddress() async {
    await speechToText.listen(onResult: speechResultCompanyAddress);
    setState(() {});
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void speechResultCompanyName(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalizeCompanyName(recognizedWords);

    setState(() {
      myCompanyName.text = capitalizedWords;
      myCompanyName.selection = TextSelection.fromPosition(
          TextPosition(offset: myCompanyName.text.length));
    });
  }

  String capitalizeCompanyName(String input) {
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

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void speechResultCompanyAddress(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalizeCompanyAddress(recognizedWords);

    setState(() {
      myCompanyAddress.text = capitalizedWords;
      myCompanyAddress.selection = TextSelection.fromPosition(
          TextPosition(offset: myCompanyAddress.text.length));
    });
  }

  String capitalizeCompanyAddress(String input) {
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
    myCompanyName.dispose();
    myCompanyAddress.dispose();
    focusNodeCA.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                  child: Container(
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
                ),
                const Text(
                  "Enroll!",
                  style: TextStyle(
                    fontFamily: "MonomaniacOne",
                    fontSize: 36,
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text(
                    "Please enter your company details!",
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 85 / 100 * MediaQuery.of(context).size.width,
                            child: const Divider(
                              color: Color(0xFFFFFBD6),
                              thickness: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              for (var step in steps)
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
                                      setData();
                                    } else if (step == 2) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const Mobile(),
                                        ),
                                      );
                                      setData();
                                    } else if (step == 3) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const Photo(),
                                        ),
                                      );
                                      setData();
                                    } else if (step == 4) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ExtendedDetails(),
                                        ),
                                      );
                                      setData();
                                    }
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    color: const Color(0xFF008B6A),
                                    size: step == 4 ? 38.0 : 22.0,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 10),
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
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                        child: TextField(
                          controller: myCompanyName,
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
                            labelText: "Company Name",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText: "Eg: Synergy Intellution Pvt Ltd",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            errorText: validateCN
                                ? "Please enter your company name!"
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
                                      ? startListeningCompanyName
                                      : stopListening,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isEmpty == true) {
                              setState(() {
                                value.isEmpty
                                    ? validateCN = true
                                    : validateCN = false;
                              });
                            } else {
                              focusNodeCA.requestFocus();
                            }
                          },
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
                        child: TextField(
                          focusNode: focusNodeCA,
                          controller: myCompanyAddress,
                          maxLines:
                              null, // Allows for an unlimited number of lines
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
                            labelText: "Company Address",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText:
                                "Eg: 351-352, Edison, Raheja Tesla Industrial Estate, MIDC Industrial Area, Juinagar, Navi Mumbai, Maharashtra 400705",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            errorText: validateCA
                                ? "Please enter your company address!"
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
                                      ? startListeningCompanyAddress
                                      : stopListening,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (myCompanyName.text.isEmpty == true) {
                              setState(() {
                                myCompanyName.text.isEmpty
                                    ? validateCN = true
                                    : validateCN = false;
                              });
                            } else {
                              if (value.isEmpty == true) {
                                setState(() {
                                  value.isEmpty
                                      ? validateCA = true
                                      : validateCA = false;
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DetailsConfirm(),
                                  ),
                                );
                                setData();
                              }
                            }
                          },
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFBD6),
                          ),
                          onPressed: () {
                            if (myCompanyName.text.isEmpty == true) {
                              setState(() {
                                myCompanyName.text.isEmpty
                                    ? validateCN = true
                                    : validateCN = false;
                              });
                            } else {
                              if (myCompanyAddress.text.isEmpty == true) {
                                setState(() {
                                  myCompanyAddress.text.isEmpty
                                      ? validateCA = true
                                      : validateCA = false;
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DetailsConfirm(),
                                  ),
                                );
                                setData();
                              }
                            }
                          },
                          child: const Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
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
                                        color: Color.fromARGB(255, 65, 65, 65),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
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
