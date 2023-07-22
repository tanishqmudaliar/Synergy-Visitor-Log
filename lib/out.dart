import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:path/path.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import "package:sqflite/sqflite.dart";
import "package:synergyvisitorlog/main.dart";

class Out extends StatefulWidget {
  const Out({super.key});

  @override
  State<Out> createState() => _OutState();
}

class _OutState extends State<Out> with SingleTickerProviderStateMixin {
  final myNumber = TextEditingController(); // texteditingcontroller
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not
  bool isUser = false; // Variable to whether the users are logged in or not
  bool isLoading = true; // Variable to track loading state
  List<Map<String, dynamic>> allData = []; // List of all users data
  late AnimationController _animationController; // AnimationController
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar

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

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, "database.db"),
    );
    final List<Map<String, dynamic>> queryResult = await database.query(
      'entries_in',
      orderBy: "createdAt DESC",
    );
    if (mounted) {
      setState(() {
        if (queryResult.isNotEmpty) {
          isLoading = false;
          isUser = true;
          // Update allData with fetched data
          allData = queryResult.map((user) {
            int millisecondsEpoch = int.parse(user["createdAt"]);
            DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(millisecondsEpoch);
            String formattedDateTime =
                DateFormat('dd MMMM, yyyy | HH:mm').format(dateTime);
            return {
              "id": user['id'],
              "name": user['name'],
              "number": user['number'],
              "timestamp": millisecondsEpoch,
              "in": formattedDateTime,
              "url": user['url'],
            };
          }).toList();
        } else {
          // Set loading state to false when fetching users
          isLoading = false;
          isUser = false;
        }
      });
    }
  }

  // Fetch a single user
  void fetchUser({required String number}) async {
    // Set loading state to true when fetching users
    setState(() {
      isLoading = true;
    });
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'database.db'),
    );

    final List<Map<String, dynamic>> queryResult = await database.query(
      'entries_in',
      where: 'number = ?',
      whereArgs: [number],
      limit: 1,
    );

    if (mounted) {
      setState(() {
        if (queryResult.isNotEmpty) {
          isLoading = false;
          isUser = true;
          final user = queryResult[0];
          int millisecondsEpoch = int.parse(user["createdAt"]);
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(millisecondsEpoch);
          String formattedDateTime =
              DateFormat('dd MMMM, yyyy | HH:mm').format(dateTime);
          allData.add({
            "id": user['id'],
            "name": user['name'],
            "number": user['number'],
            "timestamp": millisecondsEpoch,
            "in": formattedDateTime,
            "url": user['url'],
          });
        } else {
          // Set loading state to false when user is not found
          isLoading = false;
          isUser = false;
        }
      });
    }
  }

  // Push data into the database
  void runPull({
    required String id,
    required String name,
    required String duration,
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
                  "Logging you out!\n$name",
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
    String date = DateFormat('dd-MM-yyyy|kk:mm').format(DateTime.now());

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, "database.db"),
    );

    final data = {
      "key": UniqueKey().toString(),
      "id": id,
      "date": date,
      "outDateAndTime": DateTime.now().toString(),
      "duration": duration,
    };

    final outData = {
      "id": id,
    };
    if (mounted) {
      final isEntriesOutExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='entries_out'");
      if (isEntriesOutExists.isEmpty) {
        await database.execute("""CREATE TABLE IF NOT EXISTS entries_out(
          id TEXT PRIMARY KEY
          )""");
        await database.insert("entries_out", outData);
      } else {
        await database.insert("entries_out", outData);
      }
      await database.delete(
        'entries_in',
        where:
            'id = ?', // Delete the row where "id" column matches the given id
        whereArgs: [id], // Provide the value of id as the argument
      );
      final isTableExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='users_out'");
      if (isTableExists.isEmpty) {
        await database.execute("""CREATE TABLE IF NOT EXISTS users_out(
          key TEXT PRIMARY KEY,
          id TEXT,
          date TEXT,
          outDateAndTime TEXT,
          duration TEXT
          )""");
        await database.insert("users_out", data,
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        await database.insert("users_out", data,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
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
                  child: const Text(
                    "You're out!\nThanks for visiting, hope to see you again.",
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
      await Future.delayed(const Duration(seconds: 2)); // Wait for 4 seconds
      // ignore: use_build_context_synchronously
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          this.context,
          MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
        );
      }
    }
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
            "Out",
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
                            "Log Out!",
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
                              const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: TextField(
                            onSubmitted: (value) {
                              allData.clear();
                              if (value.isNotEmpty) {
                                fetchUser(number: value);
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
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
                                        (data) => Card(
                                          color: const Color(0xFFFFFBD6),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(20, 20, 20, 20),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                            color:
                                                                Color.fromARGB(
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
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    50,
                                                                    50,
                                                                    50),
                                                            thickness: 2,
                                                          ),
                                                          Text(
                                                            "In Date & Time: ${data["in"]}",
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
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              child: Image.file(
                                                                File(
                                                                    "${data["url"]}"),
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: 100,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                          0, 15, 0, 0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF008B6A),
                                                    ),
                                                    onPressed: () {
                                                      int millisecondsEpoch =
                                                          data["timestamp"];
                                                      DateTime inDateTime = DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              millisecondsEpoch);
                                                      DateTime currentDateTime =
                                                          DateTime.now();
                                                      Duration difference =
                                                          currentDateTime
                                                              .difference(
                                                                  inDateTime);

                                                      int days =
                                                          difference.inDays;
                                                      int hours = difference
                                                          .inHours
                                                          .remainder(24);
                                                      int minutes = difference
                                                          .inMinutes
                                                          .remainder(60);
                                                      int seconds = difference
                                                          .inSeconds
                                                          .remainder(60);

                                                      String formattedTime =
                                                          '$days day $hours hours $minutes minutes $seconds seconds';

                                                      runPull(
                                                        id: "${data["number"]}",
                                                        name: "${data["name"]}",
                                                        duration: formattedTime,
                                                        scaffoldMessenger:
                                                            scaffoldKey
                                                                .currentState!,
                                                      );
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 15, 0, 15),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              color: Color(
                                                                  0xFFFFFBD6),
                                                              size: 20,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          3,
                                                                          1,
                                                                          0,
                                                                          0),
                                                              child: Text(
                                                                "Out",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "ComicNeue",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 17,
                                                                  color: Color(
                                                                      0xFFFFFBD6),
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
                                      )
                                      .toList()
                                  : [
                                      const SizedBox(
                                        height: 100,
                                      ),
                                      const Center(
                                        child: Text(
                                          "No user found!\n\nPlease log in first to log out.",
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
