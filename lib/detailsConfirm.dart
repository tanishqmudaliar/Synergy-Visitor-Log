import "dart:io";
import 'dart:ui' as ui;
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:synergyvisitorlog/main.dart";
import "package:synergyvisitorlog/mobile.dart";
import "package:synergyvisitorlog/name.dart";
import "package:synergyvisitorlog/photo.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import 'package:firebase_storage/firebase_storage.dart';

class DetailsConfirm extends StatefulWidget {
  const DetailsConfirm({super.key});
  @override
  State<DetailsConfirm> createState() => _DetailsConfirmState();
}

class _DetailsConfirmState extends State<DetailsConfirm>
    with SingleTickerProviderStateMixin {
  final myName = TextEditingController(); // texteditingcontroller
  final myNumber = TextEditingController(); // texteditingcontroller
  String? imagePath;
  dynamic imageFile; // image file
  final List<int> steps = [1, 2, 3]; // steps to enroll!
  bool validate = false; // variable to store the bool value
  bool speechEnabled = false; // Whether the speech is enabled or not
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  dynamic imagePicker; // image picker
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar
  late AnimationController _animationController; // AnimationController

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    imagePicker = ImagePicker();
    loadDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 1), // Adjust the duration as per your preference
    )..repeat();
  }

  // This has to happen only once per app
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
    myName.selection =
        TextSelection.fromPosition(TextPosition(offset: myName.text.length));
    myNumber.selection =
        TextSelection.fromPosition(TextPosition(offset: myNumber.text.length));
  }

  // Resets the saved data.
  void resetApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("name");
    prefs.remove("number");
    prefs.remove("imagePath");
  }

  // Loads the saved data from the local storage.
  void loadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("name") == true) {
      setState(() {
        myName.text = (prefs.getString("name"))!;
      });
    }
    if (prefs.containsKey("number") == true) {
      setState(() {
        myNumber.text = (prefs.getString("number"))!;
      });
    }
    if (prefs.containsKey("imagePath") == true) {
      final path = prefs.getString("imagePath")!;
      setState(() {
        imageFile = File(path);
        imagePath = path;
      });
    }
  }

  // Data is being pushed into the local storage.
  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("name", myName.text);
      prefs.setString("number", myNumber.text);
      prefs.setString("imagePath", imagePath!);
    });
  }

  // Each time to start a speech recognition session
  void startListeningName() async {
    await speechToText.listen(onResult: onSpeechResultName);
    setState(() {});
  }

  // Each time to start a speech recognition session
  void startListeningNumber() async {
    await speechToText.listen(onResult: onSpeechResultNumber);
    setState(() {});
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultName(SpeechRecognitionResult result) {
    setState(() {
      myName.text = result.recognizedWords;
      myName.selection =
          TextSelection.fromPosition(TextPosition(offset: myName.text.length));
    });
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultNumber(SpeechRecognitionResult result) {
    String sanitizedResult =
        result.recognizedWords.replaceAll(RegExp(r'[^0-9 +-]'), '');
    sanitizedResult = sanitizedResult.replaceAll(' ', '-');
    setState(() {
      myNumber.text = sanitizedResult;
      myNumber.selection = TextSelection.fromPosition(
          TextPosition(offset: myNumber.text.length));
    });
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    _animationController.dispose();
    myName.dispose();
    myNumber.dispose();
    super.dispose();
  }

  // Create a new user in the database.
  void createUser({
    required String name,
    required String number,
    required dynamic image,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    final database = FirebaseFirestore.instance.collection("users").doc(name);
    final storage = FirebaseStorage.instance.ref("users/$name.png");

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
              child: RotationTransition(
                turns: _animationController,
                child: const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
              child: Text(
                "Creating a new user\n$name!",
                style: const TextStyle(
                  fontFamily: "ComicNeue",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFFFBD6),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      await storage.putFile(image);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Text(
                  'Error uploading the image file\n$e!',
                  style: const TextStyle(
                    fontFamily: "ComicNeue",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFFFBD6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final user = {
      "name": name,
      "phone": number,
    };

    try {
      await database.set(user);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Icon(
                  Icons.done_all_rounded,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Text(
                  "New user created successfully\n$name!",
                  style: const TextStyle(
                    fontFamily: "ComicNeue",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFFFBD6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 4)); // Wait for 4 seconds
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyApp(),
        ),
      );
      resetApp();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Color(0xFFFFFBD6),
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: Text(
                  'Error creating a new user: $e!',
                  style: const TextStyle(
                    fontFamily: "ComicNeue",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFFFBD6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
                constraints: BoxConstraints(
                  minHeight: 180 /
                      100 *
                      MediaQuery.of(context)
                          .size
                          .height, // Set the minimum height to 0
                  maxHeight:
                      double.infinity, // Set the maximum height to infinity
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF008B6A),
                      Color(0xFFFF0000),
                      Color(0xFFFFFBD6),
                    ],
                    stops: [0.1, 0.45, 5],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  minHeight: 180 /
                      100 *
                      MediaQuery.of(context)
                          .size
                          .height, // Set the minimum height to 0
                  maxHeight:
                      double.infinity, // Set the maximum height to infinity
                ),
                color: const Color.fromARGB(120, 255, 255, 255),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
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
                        "Please confirm your details and submit\nor continue!",
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
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
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
                                        }
                                      },
                                      child: const Icon(
                                        Icons.circle,
                                        color: Color(0xFF008B6A),
                                        size: 22.0,
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
                                      ? "Tap the microphone and start speaking..."
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
                              errorText:
                                  validate ? "Please enter your name!" : null,
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
                                onPressed:
                                    // If not yet listening for speech start, otherwise stop
                                    speechToText.isNotListening
                                        ? startListeningName
                                        : stopListening,
                              ),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
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
                              hintText: "Eg: +91-2220875021",
                              hintStyle: const TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                              errorText: validate
                                  ? "Please enter your phone number!"
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
                                onPressed:
                                    // If not yet listening for speech start, otherwise stop
                                    speechToText.isNotListening
                                        ? startListeningNumber
                                        : stopListening,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFBD6),
                            ),
                            onPressed: () async {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                  title: const Text(
                                    "Choose your preffered method!",
                                    style: TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Color.fromARGB(255, 65, 65, 65),
                                    ),
                                  ),
                                  content: const Text(
                                    "Choose a preffered method for submitting your photo!",
                                    style: TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 65, 65, 65),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        XFile? image =
                                            await imagePicker.pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 100,
                                                preferredCameraDevice:
                                                    CameraDevice.front);
                                        if (image != null) {
                                          setState(() {
                                            imageFile = File(image.path);
                                            imagePath = image.path;
                                          });
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                          elevation: 2,
                                          backgroundColor:
                                              const Color(0xFF008B6A)),
                                      child: const Text(
                                        "Open gallery",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFFFFBD6),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        XFile? image =
                                            await imagePicker.pickImage(
                                                source: ImageSource.camera,
                                                imageQuality: 100,
                                                preferredCameraDevice:
                                                    CameraDevice.front);
                                        if (image != null) {
                                          setState(() {
                                            imageFile = File(image.path);
                                            imagePath = image.path;
                                          });
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                          elevation: 2,
                                          backgroundColor:
                                              const Color(0xFF008B6A)),
                                      child: const Text(
                                        "Open camera",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFFFFBD6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Padding(
                              padding: imageFile != null
                                  ? const EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 15)
                                  : const EdgeInsetsDirectional.fromSTEB(
                                      0, 7.5, 0, 7.5),
                              child: Center(
                                child: imageFile != null
                                    ? FutureBuilder<ui.Image>(
                                        future: decodeImageFromList(
                                            File(imageFile.path)
                                                .readAsBytesSync()),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<ui.Image> snapshot) {
                                          if (snapshot.hasData) {
                                            final image = snapshot.data!;
                                            final aspectRatio =
                                                image.width.toDouble() /
                                                    image.height.toDouble();
                                            final height =
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    aspectRatio;
                                            return Image.file(
                                              imageFile,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 80 / 100 * height,
                                              fit: BoxFit.contain,
                                            );
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.camera_alt_rounded,
                                            color:
                                                Color.fromARGB(255, 70, 70, 70),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    5, 5, 0, 5),
                                            child: Text(
                                              "Upload",
                                              style: TextStyle(
                                                fontFamily: "ComicNeue",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color.fromARGB(
                                                    255, 65, 65, 65),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 20, 0, 5),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {
                                createUser(
                                  name: myName.text,
                                  number: myNumber.text,
                                  image: imageFile,
                                  scaffoldMessenger: scaffoldKey.currentState!,
                                );
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
                                        Icons.done_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5, 0, 0, 0),
                                        child: Text(
                                          "Submit",
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
                          const Row(
                            children: <Widget>[
                              Expanded(child: Divider()),
                              Text(
                                "OR",
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 65, 65, 65),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 5, 0, 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {},
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
                                          "Continue",
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
      ),
    );
  }
}
