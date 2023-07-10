import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";

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
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar
  String selectedOptionHost =
      'Select Host'; // Tracks the selected dropdown option
  List<String> staffList = ['Select Host']; // List of dropdown options

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
    });

    QuerySnapshot staff =
        await FirebaseFirestore.instance.collection("staff").limit(5).get();

    if (mounted) {
      List<String> checkList = []; // List of dropdown options
      checkList = staff.docs
          .map((doc) => doc.id)
          .where((id) => id != "Select Host")
          .toList();
      setState(() {
        if (checkList.isEmpty == false) {
          staffList = staff.docs.map((doc) => doc.id).toList();
          allDataStaff = staff.docs
              .map((doc) => {
                    "id": doc.id,
                    "number": (doc.data() as Map<String, dynamic>)["number"],
                    "position":
                        (doc.data() as Map<String, dynamic>)["position"],
                    "experience":
                        (doc.data() as Map<String, dynamic>)["experience"],
                    "url": (doc.data() as Map<String, dynamic>)["url"],
                  })
              .toList();
          allDataStaff = allDataStaff
              .where((data) => data["id"] != "Select Host")
              .toList();
        } else {
          // Set loading state to false when fetching users
          isLoading = false;
          isUser = false;
        }
      });
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .orderBy("createdAt",
            descending:
                true) // Assuming there's a "createdAt" field in the documents
        .limit(5) // Fetch only the latest 5 documents
        .get();
    if (mounted) {
      setState(() {
        if (snapshot.docs.isEmpty == false) {
          allDataVisitor = snapshot.docs
              .map((doc) => {
                    "id": doc.id,
                    "name": (doc.data() as Map<String, dynamic>)["name"],
                    "number": (doc.data() as Map<String, dynamic>)["phone"],
                    "cname":
                        (doc.data() as Map<String, dynamic>)["companyName"],
                    "cdress":
                        (doc.data() as Map<String, dynamic>)["companyAddress"],
                    "url": (doc.data() as Map<String, dynamic>)["url"],
                  })
              .toList();
          isLoading = false;
          isUser = true;
          // Update allData and photoUrls with fetched data
        } else {
          // Set loading state to false when fetching users
          isLoading = false;
          isUser = false;
        }
      });
    }
  }

  // Fetch a single user
  void fetchUserVisitor({required String number}) async {
    // Set loading state to true when fetching users
    setState(() {
      isLoading = true;
      isUser = false;
    });
    final docRef = FirebaseFirestore.instance.collection("users").doc(number);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      setState(() {
        isLoading = false;
        isUser = false;
      });
    } else {
      await docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          allDataVisitor.add({
            "id": doc.id,
            "name": data["name"],
            "number": data["phone"],
            "cname": data["companyName"],
            "cdress": data["companyAddress"],
            "url": data["photo"],
          });
          isLoading = false;
          isUser = true;
        });
      });
    }
  }

  // Fetch a single user
  void fetchUserStaff({required String name}) async {
    // Set loading state to true when fetching users
    setState(() {
      isLoading = true;
      isUser = false;
    });
    final docRef = FirebaseFirestore.instance.collection("staff").doc(name);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      setState(() {
        isLoading = false;
        isUser = false;
      });
    } else {
      await docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          allDataStaff.add({
            "id": doc.id,
            "number": data["number"],
            "position": data["position"],
            "experience": data["experience"],
            "url": data["url"],
          });
          isLoading = false;
          isUser = true;
        });
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
                                                      Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                                  .fromARGB(255,
                                                              254, 227, 227),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child:
                                                            data["url"] != null
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    child: Image
                                                                        .network(
                                                                      "${data["url"]}",
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  )
                                                                : null,
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
                                                "No user found!\n\nPlease enroll first to log in.",
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
                                    0, 20, 0, 0),
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
                                        value: selectedOptionHost,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedOptionHost = newValue!;
                                          });
                                          if (selectedOptionHost !=
                                              "Select Host") {
                                            allDataStaff.clear();
                                            fetchUserStaff(
                                                name: selectedOptionHost);
                                          }
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
                                                color: Color.fromARGB(
                                                    255, 65, 65, 65),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        icon: const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                          size: 36.0,
                                        ),
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
                                    : isUser
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
                                                      Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                                  .fromARGB(255,
                                                              254, 227, 227),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child:
                                                            data["url"] != null
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    child: Image
                                                                        .network(
                                                                      "${data["url"]}",
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  )
                                                                : null,
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
                                                "No user found!\n\nPlease enroll first to log in.",
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
