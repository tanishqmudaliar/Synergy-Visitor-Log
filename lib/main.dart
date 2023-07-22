import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:http/http.dart" as http;
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:sqflite/sqflite.dart";
import "package:synergyvisitorlog/in.dart";
import "package:synergyvisitorlog/members.dart";
import "package:synergyvisitorlog/name.dart";
import "package:firebase_core/firebase_core.dart";
import "package:synergyvisitorlog/out.dart";
import "package:workmanager/workmanager.dart";

// Background tasks
@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Workmanager().executeTask((task, inputData) async {
    try {
      final databasePath = await getDatabasesPath();
      final database = await openDatabase(
        join(databasePath, "database.db"),
      );

      final isUsersExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='users'");
      if (isUsersExists.isNotEmpty) {
        final List<Map<String, dynamic>> users = await database.query("users");
        for (var user in users) {
          final String id = user["id"];
          final String imagePath = user["url"];

          // Upload image to Firebase Storage
          final dynamic imageFile = File(imagePath);
          final storage = FirebaseStorage.instance.ref("users/$id.png");
          await storage.putFile(imageFile);
          String url = await storage.getDownloadURL();

          final userData = {
            "name": user["name"],
            "phone": user["phone"],
            "companyName": user["companyName"],
            "companyAddress": user["companyAddress"],
            "url": url,
            "createdAt": user["createdAt"],
          };

          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .set(userData);
        }
      }
      final isUsersInExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='users_in'");
      if (isUsersInExists.isNotEmpty) {
        final List<Map<String, dynamic>> usersIn =
            await database.query("users_in");
        for (var data in usersIn) {
          final String id = data["id"];

          final userInData = {
            "id": data["id"],
            "date": data["date"],
            "inDateAndTime": data["inDateAndTime"],
            "personMet": data["personMet"],
            "location": data["location"],
          };

          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .collection("inAndOut")
              .doc("${data["date"]}-in")
              .set(userInData);
        }
      }
      final isUsersOutExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='users_out'");
      if (isUsersOutExists.isNotEmpty) {
        final List<Map<String, dynamic>> usersOut =
            await database.query("users_out");
        for (var data in usersOut) {
          final String id = data["id"];

          final userOutData = {
            "id": data["id"],
            "date": data["date"],
            "outDateAndTime": data["outDateAndTime"],
            "duration": data["duration"],
          };

          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .collection("inAndOut")
              .doc("${data["date"]}-out")
              .set(userOutData);
        }
      }
      final isEntriesInExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='entries_in'");
      if (isEntriesInExists.isNotEmpty) {
        final List<Map<String, dynamic>> entries =
            await database.query("entries_in");
        for (var inData in entries) {
          final String id = inData["id"];
          final storage = FirebaseStorage.instance.ref("users/$id.png");
          String url = await storage.getDownloadURL();

          final entriesData = {
            "id": inData["id"],
            'createdAt': inData["createdAt"],
            "name": inData["name"],
            "number": inData["number"],
            "url": url,
            "personMet": inData["personMet"],
            "location": inData["location"],
          };

          await FirebaseFirestore.instance
              .collection("in")
              .doc(id)
              .set(entriesData);
        }
      }
      final isEntriesOutExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='entries_out'");
      if (isEntriesOutExists.isNotEmpty) {
        final List<Map<String, dynamic>> entries =
            await database.query("entries_out");
        for (var outData in entries) {
          final String id = outData["id"];
          await FirebaseFirestore.instance.collection("in").doc(id).delete();
        }
      }

      final isStaffExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='staff'");
      if (isStaffExists.isNotEmpty) {
        final List<Map<String, dynamic>> staff = await database.query("staff");
        for (var staff in staff) {
          final String id = staff["number"];
          final String name = staff["id"];
          final String imagePath = staff["url"];

          // Upload image to Firebase Storage
          final dynamic imageFile = File(imagePath);
          final storage = FirebaseStorage.instance.ref("staff/$id.png");
          await storage.putFile(imageFile);
          String url = await storage.getDownloadURL();

          final staffData = {
            "number": staff["number"],
            "experience": staff["experience"],
            "position": staff["position"],
            "url": url,
          };

          await FirebaseFirestore.instance
              .collection("staff")
              .doc(name)
              .set(staffData);
        }
      }

      final isLocationExists = await database.rawQuery(
          "SELECT * FROM sqlite_master WHERE type='table' AND name='location'");

      QuerySnapshot firebaseUsers =
          await FirebaseFirestore.instance.collection("users").get();

      QuerySnapshot firebaseStaff =
          await FirebaseFirestore.instance.collection("staff").get();

      QuerySnapshot firebaseLocation =
          await FirebaseFirestore.instance.collection("location").get();

      QuerySnapshot firebaseEntries =
          await FirebaseFirestore.instance.collection("in").get();

      for (final doc in firebaseUsers.docs) {
        final response = await http.get(Uri.parse(doc.get("url")));

        final directory = await getTemporaryDirectory();
        final imagePath = "${directory.path}/${doc.id}.png";
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        final user = {
          "id": doc.id,
          "name": doc.get("name"),
          "phone": doc.get("phone"),
          "companyName": doc.get("companyName"),
          "companyAddress": doc.get("companyAddress"),
          "url": imagePath,
          "createdAt": doc.get("createdAt"),
        };

        if (isUsersExists.isEmpty) {
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
        } else {
          await database.insert("users", user,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      for (final doc in firebaseStaff.docs) {
        final staff = {
          "id": doc.id,
          "experience": doc.get("experience"),
          "number": doc.get("number"),
          "position": doc.get("position"),
        };
        if (isStaffExists.isEmpty) {
          await database.execute("""CREATE TABLE IF NOT EXISTS staff(
          id TEXT PRIMARY KEY,
          number TEXT,
          position TEXT,
          experience TEXT,
          url TEXT
          )""");
          await database.insert("staff", staff,
              conflictAlgorithm: ConflictAlgorithm.replace);
        } else {
          await database.insert("staff", staff,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      for (final doc in firebaseLocation.docs) {
        final location = {
          "id": doc.id,
        };
        if (isLocationExists.isEmpty) {
          await database.execute("""CREATE TABLE IF NOT EXISTS location(
          id TEXT PRIMARY KEY
          )""");
          await database.insert("location", location,
              conflictAlgorithm: ConflictAlgorithm.replace);
        } else {
          await database.insert("location", location,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      for (final doc in firebaseEntries.docs) {
        final response = await http.get(Uri.parse(doc.get("url")));

        final directory = await getTemporaryDirectory();
        final imagePath = "${directory.path}/${doc.id}.png";
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);
        final inData = {
          "id": doc.id,
          'createdAt': doc.get("createdAt"),
          "name": doc.get("name"),
          "number": doc.get("number"),
          "url": imagePath,
          "personMet": doc.get("personMet"),
          "location": doc.get("location"),
        };
        if (isEntriesInExists.isEmpty) {
          await database.execute(
            """CREATE TABLE IF NOT EXISTS entries_in(
          id TEXT PRIMARY KEY,
          createdAt TEXT,
          name TEXT,
          number TEXT,
          url TEXT,
          personMet TEXT,
          location TEXT
          )""",
          );
          await database.insert("entries_in", inData,
              conflictAlgorithm: ConflictAlgorithm.replace);
        } else {
          await database.insert("entries_in", inData,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

// Main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true, // Only for debugging
  );
  runApp(const MyApp());
}

// Main Application
class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Workmanager().registerPeriodicTask("task", "syncData");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Visitor's Log",
      home: Builder(
        builder: (context) => const HomePage(),
      ),
    );
  }
}

// Home page
class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This runs only once when the widget is being displayed.
  @override
  void initState() {
    super.initState();
    resetApp();
  }

  // Resets the stored local data which we don"t need anymore
  void resetApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("name");
    prefs.remove("number");
    prefs.remove("imagePath");
    prefs.remove("extended");
    prefs.remove("companyName");
    prefs.remove("companyAddress");
    List<int> steps = [1, 2, 3];
    List<String> stepsString = steps.map((step) => step.toString()).toList();
    setState(() {
      prefs.setStringList("steps", stepsString);
    });
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
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: const AlignmentDirectional(0, 0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
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
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 20, 10, 20),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 0, 0),
                                          child: Icon(
                                            Icons.login_rounded,
                                            color:
                                                Color.fromARGB(255, 70, 70, 70),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 0, 0),
                                          child: Text(
                                            "In",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                              fontSize: 17,
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10, 2, 2, 2),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Out(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 20, 10, 20),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.logout_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 0, 0),
                                          child: Text(
                                            "Out",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                              fontSize: 17,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: const AlignmentDirectional(0, 0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    2, 2, 10, 2),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Name(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 20, 10, 20),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.fiber_new_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 0, 0),
                                          child: Text(
                                            "Enroll",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                              fontSize: 17,
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10, 2, 2, 2),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Members(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 20, 10, 20),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.people_alt_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 0, 0, 0),
                                          child: Text(
                                            "Members",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                              fontSize: 17,
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
    );
  }
}
