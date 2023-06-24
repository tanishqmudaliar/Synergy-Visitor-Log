import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart" as firebase_storage;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import 'package:intl/intl.dart';
import "main.dart";

class In extends StatefulWidget {
  const In({super.key});

  @override
  State<In> createState() => _InState();
}

class _InState extends State<In> with SingleTickerProviderStateMixin {
  String enteredId = ''; // id of the entered state
  final myNumber = TextEditingController(); // texteditingcontroller
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not
  List<Map<String, dynamic>> allData = []; // List of all users data
  List<String> photoUrls = []; // List of all users images
  bool isLoading = true; // Variable to track loading state
  bool isUser = false; // Variable to whether the users are logged in or not
  String selectedOption = 'Select Host'; // Tracks the selected dropdown option
  List<String> staffList = ['Select Host']; // List of dropdown options
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar
  String date = DateFormat('dd-MM-yyyy|kk:mm').format(DateTime.now());
  late AnimationController _animationController; // AnimationController

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    initSpeech();
    fetchUsers();
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
    String sanitizedResult =
        result.recognizedWords.replaceAll(RegExp(r"[^0-9 ]"), "");
    sanitizedResult = sanitizedResult.replaceAll(" ", "");
    setState(() {
      myNumber.text = sanitizedResult;
      myNumber.selection = TextSelection.fromPosition(
          TextPosition(offset: myNumber.text.length));
    });
  }

  // fetch data from the database about all the users
  void fetchUsers() async {
    // Set loading state to true when fetching users
    setState(() {
      isLoading = true;
    });

    QuerySnapshot staff =
        await FirebaseFirestore.instance.collection("staff").get();

    setState(() {
      staffList = staff.docs.map((doc) => doc.id).toList();
    });

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").get();

    firebase_storage.ListResult result = await firebase_storage
        .FirebaseStorage.instance
        .ref(
            'users') // Replace 'users' with the actual folder name in Firebase Storage
        .listAll();

    List<String> photoUrls = [];
    for (var photoRef in result.items) {
      String url = await photoRef.getDownloadURL();
      photoUrls.add(url);
    }
    // Update loading state to false after fetching users
    isLoading = false;
    if (mounted) {
      setState(() {
        if (snapshot.docs.isEmpty == false) {
          isUser = true;
          // Update allData and photoUrls with fetched data
          allData = snapshot.docs
              .map((doc) => {
                    "id": doc.id,
                    "name": (doc.data() as Map<String, dynamic>)["name"],
                    "number": (doc.data() as Map<String, dynamic>)["phone"],
                    "cname":
                        (doc.data() as Map<String, dynamic>)["companyName"],
                    "cdress":
                        (doc.data() as Map<String, dynamic>)["companyAddress"],
                    "url": photoUrls.isNotEmpty ? photoUrls.removeAt(0) : null,
                  })
              .toList();
          // Sort the allData list based on the relevance of enteredId
          allData.sort((a, b) {
            if (a['id'] == enteredId) {
              return -1; // a is more relevant
            } else if (b['id'] == enteredId) {
              return 1; // b is more relevant
            } else {
              return 0; // a and b have equal relevance
            }
          });
        }
      });
    }
  }

  // Push data into the database
  void checkNPush({
    required String id,
    required String name,
    required String number,
    required String url,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (selectedOption == 'Select Host') {
      // Show a pop-up dialog if selectedOption is true
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFBD6),
            title: const Text(
              "Choose the person whom you want to meet!",
              style: TextStyle(
                fontFamily: "ComicNeue",
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color.fromARGB(255, 65, 65, 65),
              ),
            ),
            content: const Text(
              "Please choose the person whom you are going to meet for security purposes!",
              style: TextStyle(
                fontFamily: "ComicNeue",
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 65, 65, 65),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    elevation: 2, backgroundColor: const Color(0xFF008B6A)),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontFamily: "ComicNeue",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFFFBD6),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFBD6),
            title: const Text(
              "Please Confirm!",
              style: TextStyle(
                fontFamily: "ComicNeue",
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color.fromARGB(255, 65, 65, 65),
              ),
            ),
            content: const Text(
              "Are you sure you want to log in?",
              style: TextStyle(
                fontFamily: "ComicNeue",
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 65, 65, 65),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    elevation: 2, backgroundColor: const Color(0xFF008B6A)),
                child: const Text(
                  "Cancel",
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
                  runPush(
                    id: id,
                    name: name,
                    number: number,
                    url: url,
                    scaffoldMessenger: scaffoldMessenger,
                  );
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    elevation: 2, backgroundColor: const Color(0xFF008B6A)),
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    fontFamily: "ComicNeue",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFFFFBD6),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void runPush({
    required String id,
    required String name,
    required String number,
    required String url,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
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
              child: SizedBox(
                width: 60 / 100 * MediaQuery.of(context).size.width,
                child: Text(
                  "Entering you in!\n$name",
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

    final userDB = FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("inAndOut")
        .doc("$date-in");

    final inDB = FirebaseFirestore.instance.collection("in").doc(id);

    final data = {
      "inDateAndTime": DateTime.now(),
      "personMet": selectedOption,
    };

    final inData = {
      "inDateAndTime": DateTime.now(),
      "name": name,
      "number": number,
      "url": url,
    };

    inDB.get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                  child: Icon(
                    Icons.error_rounded,
                    color: Color(0xFFFFFBD6),
                    size: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                  child: SizedBox(
                    // ignore: use_build_context_synchronously
                    width: 60 / 100 * MediaQuery.of(context).size.width,
                    child: const Text(
                      "You're already logged in please log out before logging in again!",
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
      } else {
        try {
          await userDB.set(data);
          await inDB.set(inData);
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
                      width: 60 /
                          100 *
                          // ignore: use_build_context_synchronously
                          MediaQuery.of(context).size.width,
                      child: const Text(
                        "You're in",
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
          await Future.delayed(const Duration(seconds: 2));
          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MyApp()),
            (route) => false,
          );
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
                    child: SizedBox(
                      // ignore: use_build_context_synchronously
                      width: 60 / 100 * MediaQuery.of(context).size.width,
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
      }
    });
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    _animationController.dispose();
    myNumber.dispose();
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
                    minHeight: 89.5 / 100 * MediaQuery.of(context).size.height,
                  ),
                  color: const Color.fromARGB(120, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Text(
                            "Log In!",
                            style: TextStyle(
                              fontFamily: "MonomaniacOne",
                              fontSize: 36,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 12.5, 0, 5),
                          child: Text(
                            // If listening is active show the recognized words
                            speechToText.isListening
                                ? "Please enter your registered mobile number | Listening..."
                                // If listening isn"t active but could be tell the user
                                // how to start it, otherwise indicate that speech
                                // recognition is not yet ready or not supported on
                                // the target device
                                : "Please enter your registered mobile number!",
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
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFFFBD6),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  dropdownColor: const Color(0xFFFFFBD6),
                                  value: selectedOption,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedOption = newValue!;
                                    });
                                  },
                                  items: staffList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  icon: const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: Color.fromARGB(255, 70, 70, 70),
                                    size: 36.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                enteredId = value;
                              });
                              fetchUsers();
                            },
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
                              labelText: "Number",
                              labelStyle: const TextStyle(
                                fontFamily: "ComicNeue",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                              hintText: "Eg: 7977188240",
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
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const Divider(
                          color: Color(0xFFFFFBD6),
                          thickness: 2,
                        ),
                        Column(
                          children: isLoading
                              ? [
                                  const SizedBox(
                                    height: 180,
                                  ),
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFFBD6),
                                      backgroundColor:
                                          Color.fromARGB(255, 100, 100, 100),
                                    ),
                                  ),
                                ]
                              : isUser
                                  ? allData
                                      .map(
                                        (data) => GestureDetector(
                                          onTap: () {
                                            checkNPush(
                                              id: "${data["number"]}",
                                              name: "${data["name"]}",
                                              number: "${data["number"]}",
                                              url: "${data["url"]}",
                                              scaffoldMessenger:
                                                  scaffoldKey.currentState!,
                                            );
                                          },
                                          child: Card(
                                            color: const Color(0xFFFFFBD6),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(20, 20, 20, 20),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 40 /
                                                        100 *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${data["name"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "ComicNeue",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 22,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    50,
                                                                    50,
                                                                    50),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                          thickness: 2,
                                                        ),
                                                        Text(
                                                          "${data["number"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "ComicNeue",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    50,
                                                                    50,
                                                                    50),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                          thickness: 2,
                                                        ),
                                                        Text(
                                                          "Company: ${data["cname"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "ComicNeue",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    50,
                                                                    50,
                                                                    50),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                          thickness: 2,
                                                        ),
                                                        Text(
                                                          "Company Address: ${data["cdress"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "ComicNeue",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    50,
                                                                    50,
                                                                    50),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 254, 227, 227),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.network(
                                                        "${data["url"]}",
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 100,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList()
                                  : [
                                      const SizedBox(
                                        height: 100,
                                      ),
                                      const Center(
                                        child: Text(
                                          "No user found!\n\nPlease enroll first to log in.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40,
                                            color:
                                                Color.fromARGB(255, 65, 65, 65),
                                          ),
                                        ),
                                      ),
                                    ],
                        ),
                        const SizedBox(
                          height: 20,
                        )
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
