import "dart:io";
import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:synergyvisitorlog/detailconfirm.dart';
import "package:synergyvisitorlog/extendeddetails.dart";
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
  dynamic imageFile; // image file
  dynamic imagePicker; // image picker
  String? myName; // user name
  String? myNumber; // user number
  bool visible = false; // visible
  late List<int> stepsforenroll = []; // steps to enroll!

  // This runs only once when the screen is being displayed.
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadData();
  }

  // Click image
  void imageClickCamera() async {
    XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front);
    if (image != null) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
      if (croppedImage != null) {
        setState(() {
          imageFile = File(croppedImage.path);
          visible = true;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString("imagePath", croppedImage.path);
        });
      }
    }
  }

  // Click image
  void imageClickGallery() async {
    XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
      if (croppedImage != null) {
        setState(() {
          imageFile = File(croppedImage.path);
          visible = true;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString("imagePath", croppedImage.path);
        });
      }
    }
  }

  // Loads the saved data from the local storage.
  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("imagePath") == true) {
      setState(() {
        imageFile = File(prefs.getString("imagePath")!);
        visible = true;
      });
    }
    if (prefs.containsKey("name") == true) {
      setState(() {
        myName = prefs.getString("name")!;
      });
    }
    if (prefs.containsKey("number") == true) {
      setState(() {
        myNumber = prefs.getString("number")!;
      });
    }
    if (prefs.containsKey("steps")) {
      List<String>? stepsString = prefs.getStringList("steps");
      if (stepsString != null) {
        List<int> steps = stepsString.map((step) => int.parse(step)).toList();
        setState(() {
          stepsforenroll = steps;
        });
      }
    }
  }

  // Widget
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                      child: Container(
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
                    ),
                    Padding(
                      padding: imageFile != null
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
                      padding: imageFile != null
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
                      padding: imageFile != null
                          ? const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0)
                          : const EdgeInsetsDirectional.fromSTEB(
                              20, 20, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: imageFile != null
                                ? const EdgeInsetsDirectional.fromSTEB(
                                    0, 5, 0, 10)
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
                                    for (var step in stepsforenroll)
                                      GestureDetector(
                                        onTap: () {
                                          // Define the navigation logic based on the step number
                                          if (step == 1) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const Name(),
                                              ),
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
                                          } else if (step == 4) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ExtendedDetails(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.circle,
                                          color: step == 1 ||
                                                  step == 2 ||
                                                  step == 3
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
                          Visibility(
                            visible: visible,
                            child: Card(
                              color: const Color(0xFFFFFBD6),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    15, 1, 15, 1),
                                child: Center(
                                  child: imageFile != null
                                      ? Image.file(
                                          imageFile,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 86.5 /
                                              100 *
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.contain,
                                        )
                                      : const CircularProgressIndicator(
                                          backgroundColor:
                                              Color.fromARGB(255, 65, 65, 65),
                                          color: Color(0xFFFFFBD6),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 20, 0, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {
                                imageClickCamera();
                              },
                              child: const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 7.5, 0, 7.5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color.fromARGB(255, 70, 70, 70),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          5, 5, 0, 5),
                                      child: Text(
                                        "Upload from Camera!",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 20, 0, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {
                                imageClickGallery();
                              },
                              child: const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 7.5, 0, 7.5),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.photo_library_rounded,
                                        color: Color.fromARGB(255, 70, 70, 70),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5, 5, 0, 5),
                                        child: Text(
                                          "Upload from Gallery!",
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 65, 65, 65),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: imageFile != null
                                ? const EdgeInsetsDirectional.fromSTEB(
                                    0, 15, 0, 15)
                                : const EdgeInsetsDirectional.fromSTEB(
                                    0, 20, 0, 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBD6),
                              ),
                              onPressed: () {
                                if (imageFile != null) {
                                  if (myName!.isEmpty == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Name(),
                                      ),
                                    );
                                  } else {
                                    if (myNumber?.isEmpty == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const Mobile(),
                                        ),
                                      );
                                    } else {
                                      if (stepsforenroll.isNotEmpty &&
                                          stepsforenroll.last == 3) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DetailsConfirm(),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ExtendedDetails(),
                                          ),
                                        );
                                      }
                                    }
                                  }
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
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                        ),
                                      ),
                                      content: const Text(
                                        "Please submit a image of the visitor for security reasons",
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            imageClickGallery();
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
                                          onPressed: () {
                                            imageClickCamera();
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 10),
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
