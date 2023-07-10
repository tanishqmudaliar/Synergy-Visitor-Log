import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synergyvisitorlog/main.dart';

class InConfirm extends StatefulWidget {
  const InConfirm({
    Key? key,
    required this.name,
    required this.number,
    required this.cname,
    required this.caddress,
    required this.url,
  }) : super(key: key);

  final String name;
  final String number;
  final String cname;
  final String caddress;
  final String url;

  @override
  State<InConfirm> createState() => _InConfirmState();
}

class _InConfirmState extends State<InConfirm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // AnimationController
  String selectedOptionHost =
      'Select Host'; // Tracks the selected dropdown option
  List<String> staffList = ['Select Host']; // List of dropdown options
  String selectedOptionLocation =
      'Select Location'; // Tracks the selected dropdown option
  List<String> locationList = ['Select Location']; // List of dropdown options
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 1), // Adjust the duration as per your preference
    )..repeat();
    fetchData();
  }

  // fetch data from the database
  void fetchData() async {
    QuerySnapshot staff =
        await FirebaseFirestore.instance.collection("staff").get();

    setState(() {
      staffList = staff.docs.map((doc) => doc.id).toList();
    });

    QuerySnapshot location =
        await FirebaseFirestore.instance.collection("location").get();

    setState(() {
      locationList = location.docs.map((doc) => doc.id).toList();
    });
  }

  // Push data into the database
  void checkNPush({
    required String id,
    required String name,
    required String number,
    required String url,
    required ScaffoldMessengerState scaffoldMessenger,
  }) async {
    if (selectedOptionHost == 'Select Host') {
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
      if (selectedOptionLocation == "Select Location") {
        // Show a pop-up dialog if selectedOption is true
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFBD6),
              title: const Text(
                "Choose the location!",
                style: TextStyle(
                  fontFamily: "ComicNeue",
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color.fromARGB(255, 65, 65, 65),
                ),
              ),
              content: const Text(
                "Please choose the location where you are meeting the host!",
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
        String date = DateFormat('dd-MM-yyyy|kk:mm').format(DateTime.now());

        final userDB = FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .collection("inAndOut")
            .doc("$date-in");

        final inDB = FirebaseFirestore.instance.collection("in").doc(id);

        final data = {
          "inDateAndTime": DateTime.now(),
          "personMet": selectedOptionHost,
          "location": selectedOptionLocation,
        };

        final inData = {
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          "name": name,
          "number": number,
          "url": url,
          "personMet": selectedOptionHost,
          "location": selectedOptionLocation,
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
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
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
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
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
    }
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    _animationController.dispose();
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
                    stops: [0.1, 0.45, 0.9],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Text(
                        "In!",
                        style: TextStyle(
                          fontFamily: "MonomaniacOne",
                          fontSize: 36,
                          color: Color.fromARGB(255, 50, 50, 50),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
                        child: Text(
                          "Please select whom the visitor wants to meet and where?",
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
                            const EdgeInsetsDirectional.fromSTEB(17, 20, 17, 0),
                        child: Card(
                          color: const Color(0xFFFFFBD6),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 20, 20, 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 40 /
                                      100 *
                                      MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.name,
                                        style: const TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color:
                                              Color.fromARGB(255, 50, 50, 50),
                                        ),
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 50, 50, 50),
                                        thickness: 2,
                                      ),
                                      Text(
                                        widget.number,
                                        style: const TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 50, 50, 50),
                                        ),
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 50, 50, 50),
                                        thickness: 2,
                                      ),
                                      Text(
                                        widget.cname,
                                        style: const TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color:
                                              Color.fromARGB(255, 50, 50, 50),
                                        ),
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 50, 50, 50),
                                        thickness: 2,
                                      ),
                                      Text(
                                        widget.caddress,
                                        style: const TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color:
                                              Color.fromARGB(255, 50, 50, 50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 254, 227, 227),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.url,
                                      width: MediaQuery.of(context).size.width,
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
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
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
                                },
                                items: staffList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 65, 65, 65),
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
                            const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
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
                                value: selectedOptionLocation,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedOptionLocation = newValue!;
                                  });
                                },
                                items: locationList
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
                                        color: Color.fromARGB(255, 65, 65, 65),
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 20, 20, 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFBD6),
                          ),
                          onPressed: () {
                            checkNPush(
                              id: widget.number,
                              name: widget.name,
                              number: widget.number,
                              url: widget.url,
                              scaffoldMessenger: scaffoldKey.currentState!,
                            );
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
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color.fromARGB(255, 70, 70, 70),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5, 0, 0, 0),
                                    child: Text(
                                      "In",
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
      ),
    );
  }
}
