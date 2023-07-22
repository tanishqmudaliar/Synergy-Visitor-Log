import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:google_mlkit_face_detection/google_mlkit_face_detection.dart";
import "package:image/image.dart" as img;
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:sqflite/sqflite.dart";
import "package:synergyvisitorlog/extendeddetails.dart";
import "package:synergyvisitorlog/inconfirm.dart";
import "package:synergyvisitorlog/main.dart";
import "package:synergyvisitorlog/mobile.dart";
import "package:synergyvisitorlog/name.dart";
import "package:synergyvisitorlog/photo.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";

class DetailsConfirm extends StatefulWidget {
  const DetailsConfirm({super.key});
  @override
  State<DetailsConfirm> createState() => _DetailsConfirmState();
}

class _DetailsConfirmState extends State<DetailsConfirm>
    with SingleTickerProviderStateMixin {
  final myName = TextEditingController(); // texteditingcontroller
  final myNumber = TextEditingController(); // texteditingcontroller
  final myCompanyName = TextEditingController(); // texteditingcontroller
  final myCompanyAddress = TextEditingController(); // texteditingcontroller
  dynamic imageFile; // image file
  late String imagePath;
  late List<int> stepsforenroll = []; // steps to enroll!
  bool exists = false;
  bool visible = true; // visible
  bool isLoading = false; // is loading
  bool validateName = false; // variable to store the bool value
  bool validateNumber = false; // variable to store the bool value
  bool validateCompanyName = false; // variable to store the bool value
  bool validateAddress = false; // variable to store the bool value
  bool extended = false; // variable to store the bool value
  bool speechEnabled = false; // Whether the speech is enabled or not
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  final ImagePicker imagePicker = ImagePicker(); // image picker
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  late AnimationController _animationController; // AnimationController

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initializeNotifications();
    initSpeech();
    loadDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 1), // Adjust the duration as per your preference
    )..repeat();
  }

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("mipmap/ic_launcher");
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (faces.isNotEmpty) {
        int x = faces.first.boundingBox.left.toInt() - 150;
        int y = faces.first.boundingBox.top.toInt() - 150;
        int width = 300 + faces.first.boundingBox.width.toInt();
        int height = 300 + faces.first.boundingBox.height.toInt();
        img.Image? originalImage =
            img.decodeImage(File(image.path).readAsBytesSync());
        img.Image faceCrop = img.copyCrop(originalImage!,
            x: x, y: y, width: width, height: height);
        setState(() {
          File(image.path).writeAsBytesSync(img.encodeJpg(faceCrop));
          imageFile = File(image.path);
          prefs.setString("imagePath", image.path);
          isLoading = false;
        });
      } else {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
        if (croppedImage != null) {
          setState(() {
            imageFile = File(croppedImage.path);
            prefs.setString("imagePath", croppedImage.path);
            isLoading = false;
          });
        }
      }
    } else {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (faces.isNotEmpty) {
        int x = faces.first.boundingBox.left.toInt() - 150;
        int y = faces.first.boundingBox.top.toInt() - 100;
        int width = 300 + faces.first.boundingBox.width.toInt();
        int height = 300 + faces.first.boundingBox.height.toInt();
        img.Image? originalImage =
            img.decodeImage(File(image.path).readAsBytesSync());
        img.Image faceCrop = img.copyCrop(originalImage!,
            x: x, y: y, width: width, height: height);
        setState(() {
          File(image.path).writeAsBytesSync(img.encodeJpg(faceCrop));
          imageFile = File(image.path);
          prefs.setString("imagePath", image.path);
          isLoading = false;
        });
      } else {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
        if (croppedImage != null) {
          setState(() {
            imageFile = File(croppedImage.path);
            prefs.setString("imagePath", croppedImage.path);
            isLoading = false;
          });
        }
      }
    } else {
      return;
    }
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
    if (prefs.containsKey("steps")) {
      List<String>? stepsString = prefs.getStringList("steps");
      if (stepsString != null) {
        List<int> steps = stepsString.map((step) => int.parse(step)).toList();
        setState(() {
          stepsforenroll = steps;
        });
      }
    }
    if (prefs.containsKey("extended") == true) {
      setState(() {
        extended = (prefs.getBool("extended"))!;
      });
    }
    if (prefs.containsKey("companyName") == true) {
      setState(() {
        myCompanyName.text = (prefs.getString("companyName"))!;
      });
    }
    if (prefs.containsKey("companyAddress") == true) {
      setState(() {
        myCompanyAddress.text = (prefs.getString("companyAddress"))!;
      });
    }
  }

  // Data is being pushed into the local storage.
  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("name", myName.text);
      prefs.setString("number", myNumber.text);
      if (myCompanyName.text.isNotEmpty) {
        prefs.setString("companyName", myCompanyName.text);
      }
      if (myCompanyAddress.text.isNotEmpty) {
        prefs.setString("companyAddress", myCompanyAddress.text);
      }
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
  void onSpeechResultName(SpeechRecognitionResult result) {
    String recognizedWords = result.recognizedWords;
    String capitalizedWords = capitalizeName(recognizedWords);

    setState(() {
      myName.text = capitalizedWords;
      myName.selection =
          TextSelection.fromPosition(TextPosition(offset: myName.text.length));
    });
  }

  // Sets the steps of the application
  Future<void> setSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> steps = [1, 2, 3, 4];
    List<String> stepsString = steps.map((step) => step.toString()).toList();
    setState(() {
      prefs.setStringList("steps", stepsString);
    });
  }

  String capitalizeName(String input) {
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

    List<String> words = input.toLowerCase().split(" ");

    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(" ");
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

    List<String> words = input.toLowerCase().split(" ");

    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(" ");
  }

  // Create a new user in the database.
  void createUser({
    required String name,
    required String number,
    required String companyName,
    required String companyAddress,
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
                    "Creating a new user!\n$name",
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
    final user = {
      "id": number,
      "name": name,
      "phone": number,
      "companyName": companyName,
      "companyAddress": companyAddress,
      "url": imageUrl,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    };
    await saveUserToDatabase(user, scaffoldMessenger: scaffoldMessenger);
    scaffoldMessenger.hideCurrentSnackBar();
    if (!exists) {
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
                    "New user created successfully!\n$name",
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
        Navigator.pushAndRemoveUntil(
          this.context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  // Create a new user in the database.
  void createUserIn({
    required String name,
    required String number,
    required String companyName,
    required String companyAddress,
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
                    "Creating a new user!\n$name",
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
    final user = {
      "id": number,
      "name": name,
      "phone": number,
      "companyName": companyName,
      "companyAddress": companyAddress,
      "url": imageUrl,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    };
    await saveUserToDatabase(user, scaffoldMessenger: scaffoldMessenger);
    scaffoldMessenger.hideCurrentSnackBar();
    if (!exists) {
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
                    "New user created successfully!\n$name",
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
        Navigator.pushAndRemoveUntil(
          this.context,
          MaterialPageRoute(
              builder: (_) => InConfirm(
                    name: name,
                    number: number,
                    cname: companyName,
                    caddress: companyAddress,
                    url: imageUrl,
                  )),
          (route) => false,
        );
      }
    }
  }

  // Save data locally
  Future<void> saveUserToDatabase(Map<String, dynamic> user,
      {required ScaffoldMessengerState scaffoldMessenger}) async {
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

    final isUserExists = await database.rawQuery(
        "SELECT * FROM sqlite_master WHERE type='table' AND name='users'");
    if (isUserExists.isNotEmpty) {
      final List<Map<String, dynamic>> existingUsers = await database.query(
        "users",
        where: "id = ?",
        whereArgs: [user["id"]],
        limit: 1,
      );
      if (existingUsers.isNotEmpty) {
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
                      "This user already exists!",
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
        setState(() {
          exists = true;
        });
        return;
      } else {
        await database.insert("users", user,
            conflictAlgorithm: ConflictAlgorithm.replace);
        await flutterLocalNotificationsPlugin.show(
          0, // Notification id (change as needed)
          "User created successfully!", // Notification title
          "Welcome to Syngery Intellutions ${user["name"]}", // Notification body
          platformChannelSpecifics,
          payload:
              "notification_payload", // Optional payload for handling notification taps
        );
      }
    } else {
      await database.execute("""CREATE TABLE IF NOT EXISTS users(
          id TEXT PRIMARY KEY,
          name TEXT,
          phone TEXT,
          companyName TEXT,
          companyAddress TEXT,
          url TEXT,
          createdAt INTEGER)""");
      await database.insert("users", user,
          conflictAlgorithm: ConflictAlgorithm.replace);
      await flutterLocalNotificationsPlugin.show(
        0, // Notification id (change as needed)
        "User created successfully!", // Notification title
        "Welcome to Syngery Intellutions ${user["name"]}", // Notification body
        platformChannelSpecifics,
        payload:
            "notification_payload", // Optional payload for handling notification taps
      );
    }
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    _animationController.dispose();
    myName.dispose();
    myNumber.dispose();
    myCompanyName.dispose();
    myCompanyAddress.dispose();
    faceDetector.close();
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
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
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
                                        child: const Icon(
                                          Icons.circle,
                                          color: Color(0xFF008B6A),
                                          size: 25.0,
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
                              controller: myName,
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
                                errorText: validateName
                                    ? "Please enter your name!"
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
                                          ? startListeningName
                                          : stopListening,
                                ),
                              ),
                              onSubmitted: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    validateName = true;
                                  } else {
                                    setData();
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
                              cursorColor:
                                  const Color.fromARGB(255, 70, 70, 70),
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
                                errorText: validateNumber
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
                              onSubmitted: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    validateNumber = true;
                                  } else {
                                    setData();
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
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: extended,
                              child: Column(
                                children: <Widget>[
                                  TextField(
                                    controller: myCompanyName,
                                    style: const TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 65, 65, 65),
                                    ),
                                    cursorColor:
                                        const Color.fromARGB(255, 70, 70, 70),
                                    obscureText: false,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      labelText: "Company Name",
                                      labelStyle: const TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 65, 65, 65),
                                      ),
                                      hintText:
                                          "Eg: Synergy Intellution Pvt Ltd",
                                      hintStyle: const TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 65, 65, 65),
                                      ),
                                      errorText: validateCompanyName
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
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        onPressed: // If not yet listening for speech start, otherwise stop
                                            speechToText.isNotListening
                                                ? startListeningCompanyName
                                                : stopListening,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          validateCompanyName = true;
                                        } else {
                                          setData();
                                        }
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          validateCompanyName = true;
                                        } else {
                                          validateCompanyName = false;
                                        }
                                      });
                                    },
                                    keyboardType: TextInputType.name,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: myCompanyAddress,
                                    maxLines:
                                        null, // Allows for an unlimited number of lines
                                    style: const TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 65, 65, 65),
                                    ),
                                    cursorColor:
                                        const Color.fromARGB(255, 70, 70, 70),
                                    obscureText: false,
                                    textCapitalization:
                                        TextCapitalization.words,
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
                                      errorText: validateAddress
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
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        onPressed: // If not yet listening for speech start, otherwise stop
                                            speechToText.isNotListening
                                                ? startListeningCompanyAddress
                                                : stopListening,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          validateAddress = true;
                                        } else {
                                          setData();
                                        }
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          validateAddress = true;
                                        } else {
                                          validateAddress = false;
                                        }
                                      });
                                    },
                                    keyboardType: TextInputType.multiline,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () async {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
                                        onPressed: () {
                                          imageClickGallery();
                                          Navigator.pop(context);
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
                                        onPressed: () {
                                          imageClickCamera();
                                          Navigator.pop(context);
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
                                        0, 5, 0, 5)
                                    : const EdgeInsetsDirectional.fromSTEB(
                                        0, 7.5, 0, 7.5),
                                child: Center(
                                  child: imageFile != null
                                      ? Center(
                                          child: imageFile != null
                                              ? Image.file(
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
                                              : const CircularProgressIndicator(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 65, 65, 65),
                                                  color: Color(0xFFFFFBD6),
                                                ),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(5, 5, 0, 5),
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
                                  0, 10, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(2, 2, 10, 2),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!validateName &&
                                                !validateNumber) {
                                              createUser(
                                                name: myName.text,
                                                number: myNumber.text,
                                                imageUrl: imagePath,
                                                scaffoldMessenger:
                                                    scaffoldKey.currentState!,
                                                companyName: extended
                                                    ? myCompanyName.text
                                                    : "Not defined",
                                                companyAddress: extended
                                                    ? myCompanyAddress.text
                                                    : "Not defined",
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFFFBD6),
                                          ),
                                          child: const Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10, 20, 10, 20),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.done_rounded,
                                                  color: Color.fromARGB(
                                                      255, 70, 70, 70),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 70, 70, 70),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(10, 2, 2, 2),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!validateName &&
                                                !validateNumber) {
                                              createUserIn(
                                                name: myName.text,
                                                number: myNumber.text,
                                                imageUrl: imagePath,
                                                scaffoldMessenger:
                                                    scaffoldKey.currentState!,
                                                companyName: extended
                                                    ? myCompanyName.text
                                                    : "Not defined",
                                                companyAddress: extended
                                                    ? myCompanyAddress.text
                                                    : "Not defined",
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFFFBD6),
                                          ),
                                          child: const Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10, 20, 10, 20),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.done_all_rounded,
                                                  color: Color.fromARGB(
                                                      255, 70, 70, 70),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Text(
                                                    "Submit & In",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 70, 70, 70),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: !extended,
                              child: Column(
                                children: <Widget>[
                                  const Row(
                                    children: <Widget>[
                                      Expanded(child: Divider()),
                                      Text(
                                        "OR",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 5, 0, 20),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFBD6),
                                      ),
                                      onPressed: () {
                                        setSteps();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ExtendedDetails(),
                                          ),
                                        );
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
                                                color: Color.fromARGB(
                                                    255, 70, 70, 70),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(5, 0, 0, 0),
                                                child: Text(
                                                  "Continue",
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
                                  const SizedBox(
                                    height: 20,
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
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF008B6A),
          onPressed: () {
            extended
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExtendedDetails(),
                    ),
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Photo(),
                    ),
                  );
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
    );
  }
}
