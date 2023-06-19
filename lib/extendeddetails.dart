// import 'package:flutter/material.dart';
// import 'package:smartvisitorslog/photo.dart';

// class Details extends StatefulWidget {
//   final String datamobile;
//   const Details({super.key, required this.datamobile});

//   @override
//   State<Details> createState() => _DetailsState();
// }

// class _DetailsState extends State<Details> {
//   final companyName = TextEditingController(); //texteditingcontroller
//   final companyAddress = TextEditingController(); //texteditingcontroller
//   final hostPerson = TextEditingController(); //texteditingcontroller
//   bool validate = false; //variable to store the bool value
//   void _handleURLButtonPress(BuildContext context, var type) {
//     String? text =
//         "${widget.datamobile},${companyName.text},${companyAddress.text},${hostPerson.text}";
//     Navigator.push(context,
//         MaterialPageRoute(builder: (context) => Photo(datadetails: text)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Stack(
//           children: <Widget>[
//             Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF008B6A),
//                     Color(0xFFFF0000),
//                     Color(0xFFFFFBD6),
//                   ],
//                   stops: [0.1, 0.45, 5],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               color: Color.fromARGB(120, 255, 255, 255),
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       color: Color.fromARGB(255, 254, 227, 227),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Image.asset(
//                       'assets/images/logo.png',
//                       width: MediaQuery.of(context).size.width,
//                       height: 100,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsetsDirectional.fromSTEB(0, 44, 0, 0),
//                     child: Text(
//                       "Enroll!",
//                       style: TextStyle(
//                         fontFamily: 'BebasNeue',
//                         fontSize: 36,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
//                     child: Text(
//                       "Please enter the details!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontFamily: 'ComicNeue-Bold',
//                         fontSize: 18,
//                         color: Color.fromARGB(255, 70, 70, 70),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.max,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         TextField(
//                           controller: companyName,
//                           cursorColor: Color.fromARGB(255, 70, 70, 70),
//                           obscureText: false,
//                           textCapitalization: TextCapitalization.words,
//                           // controller: myController,
//                           decoration: InputDecoration(
//                             labelText: "Company Name",
//                             labelStyle: TextStyle(
//                               color: Color.fromARGB(255, 70, 70, 70),
//                             ),
//                             hintText: 'Eg: Synergy Intellution',
//                             hintStyle: TextStyle(
//                               color: Color.fromARGB(255, 70, 70, 70),
//                             ),
//                             errorText: validate
//                                 ? "Please enter your company name!"
//                                 : null,
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFFFBD6),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFF008B6A),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFF0000),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             focusedErrorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFF0000),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             contentPadding:
//                                 EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
//                           ),
//                           keyboardType: TextInputType.name,
//                         ),
//                         Padding(
//                           padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
//                           child: TextField(
//                             controller: companyAddress,
//                             cursorColor: Color.fromARGB(255, 70, 70, 70),
//                             obscureText: false,
//                             textCapitalization: TextCapitalization.words,
//                             // controller: myController,
//                             decoration: InputDecoration(
//                               labelText: "Company Address",
//                               labelStyle: TextStyle(
//                                 color: Color.fromARGB(255, 70, 70, 70),
//                               ),
//                               hintText:
//                                   "351-352, Edison, Raheja Tesla Industrial Estate, MIDC Industrial Area, Juinagar, Navi Mumbai,\nMaharashtra 400705",
//                               hintStyle: TextStyle(
//                                 color: Color.fromARGB(255, 70, 70, 70),
//                               ),
//                               errorText: validate
//                                   ? "Please enter your company address!"
//                                   : null,
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFFFFFBD6),
//                                   width: 2,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFF008B6A),
//                                   width: 2,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFFFF0000),
//                                   width: 2,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFFFF0000),
//                                   width: 2,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               contentPadding: EdgeInsetsDirectional.fromSTEB(
//                                   20, 20, 20, 20),
//                             ),
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                           ),
//                         ),
//                         TextField(
//                           controller: hostPerson,
//                           cursorColor: Color.fromARGB(255, 70, 70, 70),
//                           obscureText: false,
//                           // controller: myController,
//                           decoration: InputDecoration(
//                             labelText: "Host person",
//                             labelStyle: TextStyle(
//                               color: Color.fromARGB(255, 70, 70, 70),
//                             ),
//                             hintText: 'Eg: Manoj Sir',
//                             hintStyle: TextStyle(
//                               color: Color.fromARGB(255, 70, 70, 70),
//                             ),
//                             errorText: validate
//                                 ? "Please enter the host person's name!"
//                                 : null,
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFFFBD6),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFF008B6A),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFF0000),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             focusedErrorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color(0xFFFF0000),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             contentPadding:
//                                 EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
//                           ),
//                           keyboardType: TextInputType.name,
//                         ),
//                         Padding(
//                           padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.all(Radius.circular(5)),
//                             child: LinearProgressIndicator(
//                               value: 0.7,
//                               minHeight: 15,
//                               backgroundColor: Color(0xFFFFFBD6),
//                               valueColor: AlwaysStoppedAnimation(
//                                 Color(0xFF008B6A),
//                               ),
//                             ),
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFFFFFBD6),
//                           ),
//                           onPressed: () {
//                             if (companyName.text.isEmpty == true ||
//                                 companyAddress.text.isEmpty == true ||
//                                 hostPerson.text.isEmpty == true) {
//                               setState(() {
//                                 companyName.text.isEmpty ||
//                                         companyAddress.text.isEmpty ||
//                                         hostPerson.text.isEmpty
//                                     ? validate = true
//                                     : validate = false;
//                               });
//                             } else {
//                               _handleURLButtonPress(
//                                   context, ImageSourceType.camera);
//                             }
//                           },
//                           child: Padding(
//                             padding:
//                                 EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
//                             child: Center(
//                               child: Row(
//                                 children: <Widget>[
//                                   Icon(
//                                     Icons.arrow_forward_ios_rounded,
//                                     color: Color.fromARGB(255, 70, 70, 70),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsetsDirectional.fromSTEB(
//                                         5, 0, 0, 0),
//                                     child: Text(
//                                       "Next",
//                                       style: TextStyle(
//                                         color: Color.fromARGB(255, 70, 70, 70),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xFF008B6A),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//         child: Icon(Icons.arrow_back_ios_new_rounded),
//       ),
//     );
//   }
// }
