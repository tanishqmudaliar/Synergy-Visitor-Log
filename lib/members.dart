import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path/path.dart" as path;
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import "package:sqflite/sqflite.dart";
import "package:synergyvisitorlog/addlocation.dart";
import "package:synergyvisitorlog/addstaff.dart";

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final myNumber = TextEditingController(); // texteditingcontroller
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not
  List<Map<String, dynamic>> allDataVisitor = []; // List of all users data
  List<Map<String, dynamic>> allDataStaff = []; // List of all users data
  bool isLoading = true; // Variable to track loading state
  bool isUser = false; // Variable to whether the users are logged in or not
  bool isStaff = false; // Variable to whether the users are logged in or not
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar

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
  void startListeningNumber() async {
    await speechToText.listen(onResult: speechResultNumber);
    setState(() {});
  }

  // This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
  void speechResultNumber(SpeechRecognitionResult result) {
    String sanitizedResult =
        result.recognizedWords.replaceAll(RegExp(r"[^0-9 ]"), "");
    sanitizedResult = sanitizedResult.replaceAll(" ", "");
    setState(() {
      myNumber.text = sanitizedResult;
      myNumber.selection = TextSelection.fromPosition(
          TextPosition(offset: myNumber.text.length));
    });
  }

  // Manually stop the active speech recognition session
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // fetch data from the database about all the users
  void fetchUsers() async {
    // Set loading state to true when fetching users
    setState(() {
      isLoading = true;
      isUser = false;
      isStaff = false;
      allDataVisitor.clear();
      allDataStaff.clear();
    });
    final databasePath = await getDatabasesPath();

    final database = await openDatabase(
      path.join(databasePath, "database.db"),
    );
    final staffTableExists = await database.rawQuery(
      "SELECT * FROM sqlite_master WHERE type='table' AND name='staff'",
    );
    if (staffTableExists.isNotEmpty) {
      final List<Map<String, dynamic>> queryResultStaff = await database.query(
        'staff',
      );
      if (mounted) {
        setState(() {
          allDataStaff = queryResultStaff.map((staff) {
            return {
              "id": staff['id'],
              "number": staff['number'],
              "position": staff['position'],
              "experience": staff['experience'],
              "url": staff['url'],
            };
          }).toList();
          isStaff = allDataStaff.isNotEmpty;
        });
      }
    }

    final usersTableExists = await database.rawQuery(
      "SELECT * FROM sqlite_master WHERE type='table' AND name='users'",
    );
    if (usersTableExists.isNotEmpty) {
      final List<Map<String, dynamic>> queryResult = await database.query(
        'users',
        orderBy: "createdAt DESC",
        limit: 15,
      );
      if (mounted) {
        setState(() {
          allDataVisitor = queryResult.map((user) {
            return {
              "id": user['id'],
              "name": user['name'],
              "number": user['phone'],
              "cname": user['companyName'],
              "cdress": user['companyAddress'],
              "url": user['url'],
            };
          }).toList();
          isUser = allDataVisitor.isNotEmpty;
          isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() {
        isUser = false;
        isLoading = false;
      });
    }
  }

  // Fetch a single visitor by mobile number.
  void fetchUserVisitor({required String number}) async {
    setState(() {
      isLoading = true;
      isUser = false;
      allDataVisitor.clear();
    });

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(databasePath, 'database.db'),
    );

    final usersTableExists = await database.rawQuery(
      "SELECT * FROM sqlite_master WHERE type='table' AND name='users'",
    );
    if (usersTableExists.isNotEmpty) {
      final List<Map<String, dynamic>> queryResult = await database.query(
        'users',
        where: 'phone = ?',
        whereArgs: [number],
        limit: 1,
      );

      if (mounted) {
        setState(() {
          if (queryResult.isNotEmpty) {
            final user = queryResult[0];
            allDataVisitor.add({
              'id': user['id'],
              'name': user['name'],
              'number': user['phone'],
              'cname': user['companyName'],
              'cdress': user['companyAddress'],
              'url': user['url'],
            });
            isUser = true;
          } else {
            isUser = false;
          }
          isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() {
        isLoading = false;
        isUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFFBD6),
            foregroundColor: const Color.fromARGB(255, 70, 70, 70),
            title: const Text(
              "Members",
              style: TextStyle(
                color: Color.fromARGB(255, 70, 70, 70),
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 50, 50, 50),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Visitors",
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: Color.fromARGB(255, 70, 70, 70),
                        ),
                      )
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Staff",
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: Color.fromARGB(255, 70, 70, 70),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
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
                          minHeight:
                              83.5 / 100 * MediaQuery.of(context).size.height,
                        ),
                        color: const Color.fromARGB(120, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 0, 20, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Text(
                                  "Visitors!",
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
                                      ? "List of all the visitors, who have enrolled in our database so far! | Listening..."
                                      // If listening isn"t active but could be tell the user
                                      // how to start it, otherwise indicate that speech
                                      // recognition is not yet ready or not supported on
                                      // the target device
                                      : "List of all the visitors, who have enrolled in our database so far!",
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 20, 0, 0),
                                child: TextField(
                                  onSubmitted: (value) {
                                    allDataVisitor.clear();
                                    if (value.isNotEmpty) {
                                      fetchUserVisitor(number: value);
                                    }
                                  },
                                  maxLength: 10,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
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
                                              ? startListeningNumber
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
                                            backgroundColor: Color.fromARGB(
                                                255, 100, 100, 100),
                                          ),
                                        ),
                                      ]
                                    : isUser
                                        ? allDataVisitor
                                            .map(
                                              (data) => Card(
                                                color: const Color(0xFFFFFBD6),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 20, 20, 20),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 40 /
                                                            100 *
                                                            MediaQuery.of(
                                                                    context)
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
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 22,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "${data["number"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "Company: ${data["cname"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "Company Address: ${data["cdress"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      data["url"] == null
                                                          ? Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        254,
                                                                        227,
                                                                        227),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            )
                                                          : Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        254,
                                                                        227,
                                                                        227),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    Image.file(
                                                                  File(
                                                                      "${data["url"]}"),
                                                                  width: 100,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                    ],
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
                                                "No user found!\n\nPlease enroll first to view",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "ComicNeue",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40,
                                                  color: Color.fromARGB(
                                                      255, 65, 65, 65),
                                                ),
                                              ),
                                            ),
                                          ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
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
                          minHeight:
                              83.5 / 100 * MediaQuery.of(context).size.height,
                        ),
                        color: const Color.fromARGB(120, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 0, 20, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Text(
                                  "Staff!",
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
                                      ? "List of all the staff who work for us! | Listening..."
                                      // If listening isn"t active but could be tell the user
                                      // how to start it, otherwise indicate that speech
                                      // recognition is not yet ready or not supported on
                                      // the target device
                                      : "List of all the staff who work for us!",
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 5, 0, 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AddStaff(),
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
                                            Icons.add_rounded,
                                            color:
                                                Color.fromARGB(255, 70, 70, 70),
                                            size: 25,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    3, 2, 0, 0),
                                            child: Text(
                                              "Staff",
                                              style: TextStyle(
                                                fontFamily: "ComicNeue",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
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
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AddLocation(),
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
                                            Icons.add_rounded,
                                            color:
                                                Color.fromARGB(255, 70, 70, 70),
                                            size: 25,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    3, 2, 0, 0),
                                            child: Text(
                                              "Location",
                                              style: TextStyle(
                                                fontFamily: "ComicNeue",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
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
                                            backgroundColor: Color.fromARGB(
                                                255, 100, 100, 100),
                                          ),
                                        ),
                                      ]
                                    : isStaff
                                        ? allDataStaff
                                            .map(
                                              (data) => Card(
                                                color: const Color(0xFFFFFBD6),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          20, 20, 20, 20),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 40 /
                                                            100 *
                                                            MediaQuery.of(
                                                                    context)
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
                                                              "${data["id"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 22,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "${data["number"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "Position: ${data["position"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      50,
                                                                      50,
                                                                      50),
                                                              thickness: 2,
                                                            ),
                                                            Text(
                                                              "Experience: ${data["experience"]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "ComicNeue",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        50,
                                                                        50,
                                                                        50),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      data["url"] == null
                                                          ? Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        254,
                                                                        227,
                                                                        227),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            )
                                                          : Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        254,
                                                                        227,
                                                                        227),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    Image.file(
                                                                  File(
                                                                      "${data["url"]}"),
                                                                  width: 100,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                    ],
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
                                                "No staff found!\n\nPlease enroll first to view.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "ComicNeue",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40,
                                                  color: Color.fromARGB(
                                                      255, 65, 65, 65),
                                                ),
                                              ),
                                            ),
                                          ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      ),
    );
  }
}
