import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:synergyvisitorlog/in.dart";
import "package:synergyvisitorlog/members.dart";
import "package:synergyvisitorlog/name.dart";
import "package:synergyvisitorlog/out.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Synergy Visitor Log",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    resetApp();
  }

  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("number");
    await prefs.remove("imagePath");
    await prefs.remove("extended");
    await prefs.remove("companyName");
    await prefs.remove("companyAddress");
    final steps = <String>["1", "2", "3"];
    await prefs.setStringList("steps", steps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const SizedBox(height: 40),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  2, 2, 10, 2),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const In()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 20, 10, 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.login_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "In",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10, 2, 2, 2),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Out()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 20, 10, 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.logout_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Out",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                          fontSize: 17,
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
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  2, 2, 10, 2),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Name()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 20, 10, 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.fiber_new_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Enroll",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10, 2, 2, 2),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Members()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 20, 10, 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.people_alt_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Members",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                          fontSize: 17,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
