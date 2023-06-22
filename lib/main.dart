import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:synergyvisitorlog/in.dart";
import "package:synergyvisitorlog/name.dart";
import "package:firebase_core/firebase_core.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

void resetApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("name");
  prefs.remove("number");
  prefs.remove("imagePath");
  prefs.remove("extended");
  prefs.remove("companyName");
  prefs.remove("companyAddress");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    resetApp();
  }

  // Sets the steps of the application
  Future<void> setSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> steps = [1, 2, 3];
    List<String> stepsString = steps.map((step) => step.toString()).toList();
    setState(() {
      prefs.setStringList("steps", stepsString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Visitor's Log",
      home: Builder(
        builder: (context) => Scaffold(
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
                      stops: [0.1, 0.45, 5],
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
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
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Text(
                            "Welcome!",
                            style: TextStyle(
                              fontFamily: "MonomaniacOne",
                              fontSize: 36,
                              color: Color.fromARGB(255, 50, 50, 50),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
                          child: Text(
                            "Thanks for visiting! Enroll yourself if this is your first visit, else log-in or log-out yourself!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 65, 65, 65),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 0, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Align(
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 10, 2),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const In(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFBD6),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 0, 0),
                                              child: Icon(
                                                Icons.login_rounded,
                                                color: Color.fromARGB(
                                                    255, 70, 70, 70),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(5, 0, 0, 0),
                                              child: Text(
                                                "In",
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
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            10, 2, 2, 2),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFBD6),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.logout_rounded,
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(5, 0, 0, 0),
                                              child: Text(
                                                "Out",
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 10, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Align(
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 10, 2),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setSteps();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const Name(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFBD6),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.fiber_new_rounded,
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(5, 0, 0, 0),
                                              child: Text(
                                                "Enroll",
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
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            10, 2, 2, 2),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFBD6),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.accessibility_new_rounded,
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(5, 0, 0, 0),
                                              child: Text(
                                                "Member's",
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
