import "dart:io";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:synergyvisitorlog/details.dart";
import "package:synergyvisitorlog/mobile.dart";
import "package:synergyvisitorlog/name.dart";

class Photo extends StatefulWidget {
  const Photo({
    super.key,
  });

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  dynamic _image;
  dynamic imagePicker;
  final List<int> steps = [1, 2, 3]; //steps to enroll!

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadImage();
  }

  void loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("imagePath") == true) {
      final path = prefs.getString("imagePath")!;
      setState(() {
        _image = File(path);
      });
    }
  }

  void setImage({required String path}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("imagePath", path);
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
              constraints: BoxConstraints(
                minHeight: 130 /
                    100 *
                    MediaQuery.of(context)
                        .size
                        .height, // Set the minimum height to 0
                maxHeight:
                    double.infinity, // Set the maximum height to infinity
              ),
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
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                minHeight: 130 /
                    100 *
                    MediaQuery.of(context)
                        .size
                        .height, // Set the minimum height to 0
                maxHeight:
                    double.infinity, // Set the maximum height to infinity
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
                  Padding(
                    padding: _image != null
                        ? const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0)
                        : const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: const Text(
                      "Enroll!",
                      style: TextStyle(
                        fontFamily: "MonomaniacOne",
                        fontSize: 36,
                      ),
                    ),
                  ),
                  Padding(
                    padding: _image != null
                        ? const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0)
                        : const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                    child: const Text(
                      "Please submit your photo!",
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
                    padding: _image != null
                        ? const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0)
                        : const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: _image != null
                              ? const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5)
                              : const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 85 /
                                    100 *
                                    MediaQuery.of(context).size.width,
                                child: const Divider(
                                  color: Color(0xFFFFFBD6),
                                  thickness: 2,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  for (var step in steps)
                                    GestureDetector(
                                      onTap: () {
                                        // Define the navigation logic based on the step number
                                        if (step == 1) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => const Name()),
                                          );
                                        } else if (step == 2) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const Mobile(),
                                            ),
                                          );
                                        } else if (step == 3) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const Photo(),
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.circle,
                                        color:
                                            step == 1 || step == 2 || step == 3
                                                ? const Color(0xFF008B6A)
                                                : const Color(0xFFFFFBD6),
                                        size: step == 3 ? 38.0 : 22.0,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFBD6),
                          ),
                          onPressed: () async {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                backgroundColor: const Color(0xFFFFFBD6),
                                title: const Text(
                                  "Choose your preffered method!",
                                  style: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 65, 65, 65),
                                  ),
                                ),
                                content: const Text(
                                  "Choose a preffered method for submitting your photo!",
                                  style: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 65, 65, 65),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      XFile? image =
                                          await imagePicker.pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 100,
                                              preferredCameraDevice:
                                                  CameraDevice.front);
                                      if (image != null) {
                                        setState(() {
                                          _image = File(image.path);
                                        });
                                        setImage(path: image.path);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        elevation: 2,
                                        backgroundColor:
                                            const Color(0xFF008B6A)),
                                    child: const Text(
                                      "Open gallery",
                                      style: TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFFFFBD6),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      XFile? image =
                                          await imagePicker.pickImage(
                                              source: ImageSource.camera,
                                              imageQuality: 100,
                                              preferredCameraDevice:
                                                  CameraDevice.front);
                                      if (image != null) {
                                        setState(() {
                                          _image = File(image.path);
                                        });
                                        setImage(path: image.path);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        elevation: 2,
                                        backgroundColor:
                                            const Color(0xFF008B6A)),
                                    child: const Text(
                                      "Open camera",
                                      style: TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFFFFBD6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: _image != null
                                ? const EdgeInsetsDirectional.fromSTEB(
                                    0, 15, 0, 15)
                                : const EdgeInsetsDirectional.fromSTEB(
                                    0, 7.5, 0, 7.5),
                            child: Center(
                              child: _image != null
                                  ? Image.file(
                                      _image,
                                      width: MediaQuery.of(context).size.width,
                                      height: 150 /
                                          100 *
                                          MediaQuery.of(context).size.width,
                                      fit: BoxFit.fill,
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.camera_alt_rounded,
                                          color:
                                              Color.fromARGB(255, 70, 70, 70),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  5, 5, 0, 5),
                                          child: Text(
                                            "Upload",
                                            style: TextStyle(
                                              fontFamily: "ComicNeue",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 65, 65, 65),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: _image != null
                              ? const EdgeInsetsDirectional.fromSTEB(
                                  0, 15, 0, 15)
                              : const EdgeInsetsDirectional.fromSTEB(
                                  0, 20, 0, 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFBD6),
                            ),
                            onPressed: () {
                              if (_image != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Details(),
                                  ),
                                );
                              } else {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    backgroundColor: const Color(0xFFFFFBD6),
                                    title: const Text(
                                      "Image not found!",
                                      style: TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Color.fromARGB(255, 65, 65, 65),
                                      ),
                                    ),
                                    content: const Text(
                                      "Please submit a image of the visitor for security reasons",
                                      style: TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 65, 65, 65),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          XFile? image =
                                              await imagePicker.pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 100,
                                                  preferredCameraDevice:
                                                      CameraDevice.front);
                                          if (image != null) {
                                            setState(() {
                                              _image = File(image.path);
                                            });
                                            setImage(path: image.path);
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                            elevation: 2,
                                            backgroundColor:
                                                const Color(0xFF008B6A)),
                                        child: const Text(
                                          "Open gallery",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFFFFFBD6),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          XFile? image =
                                              await imagePicker.pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 100,
                                                  preferredCameraDevice:
                                                      CameraDevice.front);
                                          if (image != null) {
                                            setState(() {
                                              _image = File(image.path);
                                            });
                                            setImage(path: image.path);
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                            elevation: 2,
                                            backgroundColor:
                                                const Color(0xFF008B6A)),
                                        child: const Text(
                                          "Open camera",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFFFFFBD6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
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
                                        "Next",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
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
