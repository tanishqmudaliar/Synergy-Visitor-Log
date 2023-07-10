import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart";
import "package:synergyvisitorlog/inconfirm.dart";

class In extends StatefulWidget {
  const In({
    Key? key,
  }) : super(key: key);

  @override
  State<In> createState() => _InState();
}

class _InState extends State<In> {
  final myNumber = TextEditingController(); // texteditingcontroller
  SpeechToText speechToText = SpeechToText(); // Initialize the speech-to-text
  bool speechEnabled = false; // Whether the speech is enabled or not
  List<Map<String, dynamic>> allData = []; // List of all users data
  bool isLoading = true; // Variable to track loading state
  bool isUser = false; // Variable to whether the users are logged in or not

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
      isUser = false;
    });

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
          isLoading = false;
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
                    "url": (doc.data() as Map<String, dynamic>)["photo"],
                  })
              .toList();
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
          allData.add({
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

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    myNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 12.5, 0, 5),
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
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 7),
                        child: Divider(
                          color: Color(0xFFFFFBD6),
                          thickness: 2,
                        ),
                      ),
                      Column(
                        key: UniqueKey(),
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => InConfirm(
                                                name: "${data["name"]}",
                                                number: "${data["number"]}",
                                                url: "${data["url"]}",
                                                cname: "${data["cname"]}",
                                                caddress: "${data["cdress"]}",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: const Color(0xFFFFFBD6),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
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
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "ComicNeue",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 22,
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                        ),
                                                      ),
                                                      const Divider(
                                                        color: Color.fromARGB(
                                                            255, 50, 50, 50),
                                                        thickness: 2,
                                                      ),
                                                      Text(
                                                        "${data["number"]}",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "ComicNeue",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                        ),
                                                      ),
                                                      const Divider(
                                                        color: Color.fromARGB(
                                                            255, 50, 50, 50),
                                                        thickness: 2,
                                                      ),
                                                      Text(
                                                        "Company: ${data["cname"]}",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "ComicNeue",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
                                                        ),
                                                      ),
                                                      const Divider(
                                                        color: Color.fromARGB(
                                                            255, 50, 50, 50),
                                                        thickness: 2,
                                                      ),
                                                      Text(
                                                        "Company Address: ${data["cdress"]}",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "ComicNeue",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color.fromARGB(
                                                              255, 50, 50, 50),
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
                                                          color: Color.fromARGB(
                                                              255,
                                                              254,
                                                              227,
                                                              227),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255,
                                                              254,
                                                              227,
                                                              227),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.network(
                                                            "${data["url"]}",
                                                            width:
                                                                MediaQuery.of(
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
    );
  }
}
