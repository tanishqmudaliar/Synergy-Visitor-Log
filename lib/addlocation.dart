// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:sqflite/sqflite.dart";

// Screen to add a new meeting location, selectable later from the
// "Select Location" dropdown when checking a visitor in.
class AddLocation extends StatefulWidget {
  const AddLocation({super.key});

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final locationController = TextEditingController(); // texteditingcontroller
  bool validate = false; // variable to store the bool value
  bool isLoading = false; // is loading
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Show snackbar

  // Create the location table if needed, then insert the new location.
  Future<void> createLocation(String name) async {
    setState(() {
      isLoading = true;
    });
    try {
      final databasePath = await getDatabasesPath();
      final database = await openDatabase(
        path.join(databasePath, "database.db"),
      );
      await database.execute(
          """CREATE TABLE IF NOT EXISTS location(id TEXT PRIMARY KEY)""");

      final existing = await database.query(
        "location",
        where: "id = ?",
        whereArgs: [name],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        scaffoldKey.currentState?.showSnackBar(
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
                    width: 60 / 100 * MediaQuery.of(context).size.width,
                    child: const Text(
                      "This location already exists!",
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
          isLoading = false;
        });
        return;
      }

      await database.insert("location", {"id": name},
          conflictAlgorithm: ConflictAlgorithm.replace);

      scaffoldKey.currentState?.showSnackBar(
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
                  width: 60 / 100 * MediaQuery.of(context).size.width,
                  child: Text(
                    "New location added successfully!\n$name",
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

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Surface the real error instead of failing silently.
      scaffoldKey.currentState?.showSnackBar(
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
                  width: 60 / 100 * MediaQuery.of(context).size.width,
                  child: Text(
                    "Couldn't add location: $e",
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    locationController.dispose();
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
            "Add Location",
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
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  color: const Color.fromARGB(120, 255, 255, 255),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
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
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Text(
                          "Add Location!",
                          style: TextStyle(
                            fontFamily: "MonomaniacOne",
                            fontSize: 36,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Text(
                          "Please enter the location name!",
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 15, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              controller: locationController,
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
                                labelText: "Location",
                                labelStyle: const TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 65, 65, 65),
                                ),
                                hintText: "Eg: Conference Room A",
                                hintStyle: const TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 65, 65, 65),
                                ),
                                errorText: validate
                                    ? "Please enter a location name!"
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
                              ),
                              onChanged: (value) {
                                setState(() {
                                  validate = value.isEmpty;
                                });
                              },
                              keyboardType: TextInputType.text,
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 20, 0, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFBD6),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (locationController.text.isEmpty) {
                                          setState(() {
                                            validate = true;
                                          });
                                        } else {
                                          createLocation(
                                              locationController.text);
                                        }
                                      },
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 15, 0, 15),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color.fromARGB(
                                                  255, 65, 65, 65),
                                            ),
                                          )
                                        : const Row(
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
                                                padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(5, 0, 0, 0),
                                                child: Text(
                                                  "Submit",
                                                  style: TextStyle(
                                                    fontFamily: "ComicNeue",
                                                    fontWeight:
                                                        FontWeight.bold,
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
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
    );
  }
}
