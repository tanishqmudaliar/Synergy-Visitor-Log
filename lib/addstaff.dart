import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:image/image.dart" as img;
import 'package:sqflite/sqflite.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff>
    with SingleTickerProviderStateMixin {
  final myName = TextEditingController(); // texteditingcontroller
  final myNumber = TextEditingController(); // texteditingcontroller
  final myExperience = TextEditingController(); // texteditingcontroller
  final myPosition = TextEditingController(); // texteditingcontroller
  bool validateName = false; // variable to store the bool value
  bool validateNumber = false; // variable to store the bool value
  bool validateExperience = false; // variable to store the bool value
  bool validatePosition = false; // variable to store the bool value
  bool validatePhoto = false; // variable to store the bool value
  bool visible = false; // visible
  bool isLoading = false; // is loading
  dynamic imageFile;
  String imagePath = "null";
  final ImagePicker imagePicker = ImagePicker(); // image picker
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool speechEnabled = false; // Whether the speech is enabled or not
  late AnimationController _animationController; // AnimationController

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
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
  }

  // Input image through camera
  Future<void> imageClickCamera() async {
    XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image != null) {
      setState(() {
        visible = true;
        isLoading = true;
      });
      final inputImage = InputImage.fromFilePath(image.path);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        // Accessing the first face directly from the "faces" list
        Face firstFace = faces.first;

        int x = firstFace.boundingBox.left.toInt() - 150;
        int y = firstFace.boundingBox.top.toInt() - 100;
        int width = 300 + firstFace.boundingBox.width.toInt();
        int height = 300 + firstFace.boundingBox.height.toInt();
        img.Image? originalImage =
            img.decodeImage(File(image.path).readAsBytesSync());
        img.Image faceCrop = img.copyCrop(originalImage!,
            x: x, y: y, width: width, height: height);

        setState(() {
          File(image.path).writeAsBytesSync(img.encodeJpg(faceCrop));
          imageFile = File(image.path);
          imagePath = image.path;
          isLoading = false;
        });
      } else {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );
        if (croppedImage != null) {
          setState(() {
            imageFile = File(croppedImage.path);
            imagePath = image.path;
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        visible = false;
      });
      return;
    }
  }

  // Input image through gallery
  Future<void> imageClickGallery() async {
    XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      setState(() {
        visible = true;
        isLoading = true;
      });
      final inputImage = InputImage.fromFilePath(image.path);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        // Accessing the first face directly from the "faces" list
        Face firstFace = faces.first;

        int x = firstFace.boundingBox.left.toInt() - 150;
        int y = firstFace.boundingBox.top.toInt() - 100;
        int width = 300 + firstFace.boundingBox.width.toInt();
        int height = 300 + firstFace.boundingBox.height.toInt();
        img.Image? originalImage =
            img.decodeImage(File(image.path).readAsBytesSync());
        img.Image faceCrop = img.copyCrop(originalImage!,
            x: x, y: y, width: width, height: height);

        setState(() {
          File(image.path).writeAsBytesSync(img.encodeJpg(faceCrop));
          imageFile = File(image.path);
          imagePath = image.path;
          isLoading = false;
        });
      } else {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );
        if (croppedImage != null) {
          setState(() {
            imageFile = File(croppedImage.path);
            imagePath = image.path;
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        visible = false;
      });
      return;
    }
  }

  // Each time to start a speech recognition session
  void startListeningName() async {
    await speechToText.listen(onResult: onSpeechResultName);
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultName(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalize(recognizedWords);
    setState(() {
      myName.text = capitalizedWords;
      myName.selection =
          TextSelection.fromPosition(TextPosition(offset: myName.text.length));
    });
  }

  // Each time to start a speech recognition session
  void startListeningNumber() async {
    await speechToText.listen(onResult: onSpeechResultNumber);
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultNumber(SpeechRecognitionResult result) {
    String sanitizedResult =
        result.recognizedWords.replaceAll(RegExp(r"[^0-9 +-]"), "");
    sanitizedResult = sanitizedResult.replaceAll(" ", "-");
    setState(() {
      myNumber.text = sanitizedResult;
      myNumber.selection = TextSelection.fromPosition(
          TextPosition(offset: myNumber.text.length));
    });
  }

  // Each time to start a speech recognition session
  void startListeningExperience() async {
    await speechToText.listen(onResult: onSpeechResultExperience);
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultExperience(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalize(recognizedWords);
    setState(() {
      myExperience.text = capitalizedWords;
      myExperience.selection = TextSelection.fromPosition(
          TextPosition(offset: myExperience.text.length));
    });
  }

  // Each time to start a speech recognition session
  void startListeningPosition() async {
    await speechToText.listen(onResult: onSpeechResultPosition);
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void onSpeechResultPosition(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalize(recognizedWords);
    setState(() {
      myPosition.text = capitalizedWords;
      myPosition.selection = TextSelection.fromPosition(
          TextPosition(offset: myPosition.text.length));
    });
  }

  // Capitalization
  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.toLowerCase().split(" ");
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(" ");
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  //Create staff
  void createStaff({
    required String name,
    required String number,
    required String experience,
    required String position,
    required String imageUrl,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (mounted) {
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
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                    child: const Icon(
                      Icons.sync_rounded,
                      color: Color(0xFFFFFBD6),
                      size: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: SizedBox(
                  width: 60 / 100 * MediaQuery.of(this.context).size.width,
                  child: Text(
                    "Entering a new staff!\n$name",
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
    final staff = {
      "id": name,
      "number": number,
      "experience": experience,
      "position": position,
      "url": imageUrl,
    };
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '${DateTime.now().millisecondsSinceEpoch}',
      '${DateTime.now().microsecondsSinceEpoch}',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, "database.db"),
    );
    final List<Map<String, dynamic>> existingStaff = await database.query(
      "staff",
      where: "id = ?",
      whereArgs: [name],
      limit: 1,
    );
    if (existingStaff.isNotEmpty) {
      scaffoldMessenger.hideCurrentSnackBar();
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
                child: SizedBox(
                  // ignore: use_build_context_synchronously
                  width: 60 / 100 * MediaQuery.of(this.context).size.width,
                  child: const Text(
                    "This staff already exists!",
                    style: TextStyle(
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
      return;
    } else {
      await database.insert("staff", staff,
          conflictAlgorithm: ConflictAlgorithm.replace);
      await flutterLocalNotificationsPlugin.show(
        0, // Notification id (change as needed)
        "Staff created successfully!", // Notification title
        "Welcome to Syngery Intellutions $name", // Notification body
        platformChannelSpecifics,
        payload:
            "notification_payload", // Optional payload for handling notification taps
      );
      scaffoldMessenger.hideCurrentSnackBar();
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
                child: SizedBox(
                  // ignore: use_build_context_synchronously
                  width: 60 / 100 * MediaQuery.of(this.context).size.width,
                  child: Text(
                    "New staff entered successfully!\n$name",
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
      await Future.delayed(const Duration(seconds: 2)); // Wait for 4 seconds
      // ignore: use_build_context_synchronously
      if (mounted) {
        Navigator.pop(this.context);
      }
    }
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    _animationController.dispose();
    myName.dispose();
    myNumber.dispose();
    myExperience.dispose();
    myPosition.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFBD6),
          foregroundColor: const Color.fromARGB(255, 70, 70, 70),
          title: const Text(
            "Add Staff",
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
                    stops: [0.2, 0.55, 0.9],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    minHeight: 89.5 / 100 * MediaQuery.of(context).size.height,
                  ),
                  color: const Color.fromARGB(120, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 120,
                          height: 120,
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
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          child: Text(
                            "Enroll!",
                            style: TextStyle(
                              fontFamily: "MonomaniacOne",
                              fontSize: 36,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 10, 0, 20),
                          child: Text(
                            // If listening is active show the recognized words
                            speechToText.isListening
                                ? "Add new staff members of your company | Listening..."
                                // If listening isn"t active but could be tell the user
                                // how to start it, otherwise indicate that speech
                                // recognition is not yet ready or not supported on
                                // the target device
                                : "Add new staff members of your company!",
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
                                validateName ? "Please enter your name!" : null,
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
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateName = true;
                              } else {
                                // setData();
                              }
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateName = true;
                              } else {
                                validateName = false;
                              }
                            });
                          },
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
                            labelText: "Number",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText: "Eg: 9375638395",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            errorText: validateNumber
                                ? "Please enter your number!"
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
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateNumber = true;
                              } else {
                                // setData();
                              }
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateNumber = true;
                              } else {
                                validateNumber = false;
                              }
                            });
                          },
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: myExperience,
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
                            labelText: "Experience",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText: "Eg: 4 Years",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            errorText: validateExperience
                                ? "Please enter how experienced you are!"
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
                                      ? startListeningExperience
                                      : stopListening,
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateExperience = true;
                              } else {
                                // setData();
                              }
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validateExperience = true;
                              } else {
                                validateExperience = false;
                              }
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: myPosition,
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
                            labelText: "Position",
                            labelStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            hintText: "Eg: Owner/Manager",
                            hintStyle: const TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                            errorText: validatePosition
                                ? "Please enter your position\nin the company!"
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
                                      ? startListeningPosition
                                      : stopListening,
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validatePosition = true;
                              } else {
                                // setData();
                              }
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                validatePosition = true;
                              } else {
                                validatePosition = false;
                              }
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          visible: visible,
                          child: Column(
                            children: <Widget>[
                              Card(
                                color: const Color(0xFFFFFBD6),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 1, 15, 1),
                                  child: Center(
                                    child: imageFile != null
                                        ? isLoading
                                            ? const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 15, 0, 15),
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 65, 65, 65),
                                                  color: Color(0xFFFFFBD6),
                                                ),
                                              )
                                            : Image.file(
                                                imageFile,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 86.5 /
                                                    100 *
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                fit: BoxFit.contain,
                                              )
                                        : const Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 15, 0, 15),
                                            child: CircularProgressIndicator(
                                              backgroundColor: Color.fromARGB(
                                                  255, 65, 65, 65),
                                              color: Color(0xFFFFFBD6),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                  side: validatePhoto
                                      ? const BorderSide(
                                          width: 2,
                                          color: Colors.red,
                                        )
                                      : null,
                                ),
                                onPressed: () {
                                  imageClickCamera();
                                },
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5, 5, 0, 5),
                                        child: Text(
                                          "Upload from Camera!",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 65, 65, 65),
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
                                  0, 20, 0, 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                  side: validatePhoto
                                      ? const BorderSide(
                                          width: 2,
                                          color: Colors.red,
                                        )
                                      : null,
                                ),
                                onPressed: () {
                                  imageClickGallery();
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
                                          Icons.photo_library_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 5, 0, 5),
                                          child: Text(
                                            "Upload from Gallery!",
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
                            ),
                          ],
                        ),
                        Visibility(
                          visible: validatePhoto,
                          child: const Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                            child: Text(
                              "Please submit the new staff's photo for security purposes",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFFFF0000),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 10, 0, 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFBD6),
                            ),
                            onPressed: () {
                              if (!validateName &&
                                  !validateNumber &&
                                  !validateExperience &&
                                  !validatePosition &&
                                  imagePath != "null") {
                                createStaff(
                                  name: myName.text,
                                  number: myNumber.text,
                                  experience: myExperience.text,
                                  position: myPosition.text,
                                  imageUrl: imagePath,
                                  scaffoldMessenger: scaffoldKey.currentState!,
                                );
                              } else {
                                if (myName.text.isEmpty) {
                                  setState(() {
                                    validateName = true;
                                  });
                                }
                                if (myNumber.text.isEmpty) {
                                  setState(() {
                                    validateNumber = true;
                                  });
                                }
                                if (myExperience.text.isEmpty) {
                                  setState(() {
                                    validateExperience = true;
                                  });
                                }
                                if (myPosition.text.isEmpty) {
                                  setState(() {
                                    validatePosition = true;
                                  });
                                }
                                if (imagePath == "null") {
                                  setState(() {
                                    validatePhoto = true;
                                  });
                                }
                              }
                            },
                            child: const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
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
      ),
    );
  }
}
