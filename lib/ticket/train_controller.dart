// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'station_fare.dart'; // Import the StationFareDatabase class
//
// class TrainTicketSearch extends StatefulWidget {
//   const TrainTicketSearch({super.key});
//
//   @override
//   State<TrainTicketSearch> createState() => _TrainTicketSearchState();
// }
//
// class _TrainTicketSearchState extends State<TrainTicketSearch> {
//   List<String> _stations = [
//     'Uttara South',
//     'Pallabi',
//     'Mirpur 11',
//     'Mirpur 10',
//     'Kazipara',
//     'Shewrapara',
//     'Agargaon',
//     'Bijoy Sarani',
//     'Farmgate',
//     'Karwan Bazar',
//     'Shahbag',
//     'Dhaka University',
//     'Bangladesh Secretariat',
//     'Motijheel',
//     'Kamalapur',
//   ];
//
//   String? _selectedFromStation;
//   String? _selectedToStation;
//   DateTime? _selectedDate;
//   bool _showTickets = false; // Flag to control display of tickets
//   List<Ticket> _tickets = []; // List to hold generated tickets
//
//   final outlineInputBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5.0),
//     borderSide: BorderSide(color: Colors.grey, width: 1.0),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green[50],
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 30,
//             ),
//             Container(
//               width: double.infinity,
//               height: 300,
//               padding: EdgeInsets.all(20.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     spreadRadius: 5,
//                     blurRadius: 7,
//                     offset: Offset(0, 3),
//                   )
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Search Result',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   _buildDropdown('From Station', _selectedFromStation, (value) {
//                     setState(() {
//                       _selectedFromStation = value;
//                     });
//                   }),
//                   SizedBox(height: 10),
//                   _buildDropdown('To Station', _selectedToStation, (value) {
//                     setState(() {
//                       _selectedToStation = value;
//                     });
//                   }),
//                   SizedBox(height: 10),
//                   _buildDateField(),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       _calculateFareAndGenerateTickets();
//                     },
//                     child: Text('Confirm'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 30.0, vertical: 15.0),
//                       textStyle: TextStyle(fontSize: 16.0),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 return Container(
//                   width: constraints.maxWidth * 0.8,
//                   child: Divider(
//                     color: Colors.green,
//                     thickness: 2.0,
//                   ),
//                 );
//               },
//             ),
//             if (_showTickets) ..._buildTicketsUI(),
//             // Show tickets UI conditionally
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown(
//       String label, String? value, ValueChanged<String?> onChanged) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       hint: Text(label),
//       icon: Icon(Icons.keyboard_arrow_down),
//       items: _stations
//           .map((station) => DropdownMenuItem(
//         value: station,
//         child: Text(station),
//       ))
//           .toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 7.0),
//         fillColor: Colors.green[50],
//         filled: true,
//         border: outlineInputBorder,
//         enabledBorder: outlineInputBorder,
//         focusedBorder: outlineInputBorder,
//       ),
//     );
//   }
//
//   Widget _buildDateField() {
//     return Container(
//       child: TextFormField(
//         readOnly: true,
//         decoration: InputDecoration(
//           labelText: 'Journey Date',
//           hintText: _selectedDate != null
//               ? '${_selectedDate!.day} ${_selectedDate!.month}, ${_selectedDate!.year}'
//               : 'Select a date',
//           suffixIcon: Icon(Icons.calendar_today),
//           contentPadding: EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 7.0),
//           fillColor: Colors.green[50],
//           filled: true,
//           border: outlineInputBorder,
//           enabledBorder: outlineInputBorder,
//           focusedBorder: outlineInputBorder,
//         ),
//         onTap: () {
//           _selectDate(context);
//         },
//       ),
//     );
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _calculateFareAndGenerateTickets() {
//     if (_selectedFromStation != null &&
//         _selectedToStation != null &&
//         _selectedDate != null) {
//       // Calculate fare using StationFareDatabase
//       int fare = StationFareDatabase()
//           .getFare(_selectedFromStation!, _selectedToStation!);
//
//       // Generate sample tickets (for demonstration purposes)
//       _tickets = _generateSampleTickets(fare);
//
//       setState(() {
//         _showTickets = true; // Show ticket UI
//       });
//     } else {
//       // Handle if any field is not selected
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select From Station, To Station, and Date.'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   List<Ticket> _generateSampleTickets(int fare) {
//     // Generate 8-10 sample tickets with random train numbers and timings
//     Random random = Random();
//     List<Ticket> tickets = [];
//     for (int i = 1; i <= random.nextInt(3) + 8; i++) {
//       tickets.add(Ticket(
//           trainNumber: 'DMR-${random.nextInt(100)}',
//           timing:
//           '${random.nextInt(24).toString().padLeft(2, '0')}:${random.nextInt(60).toString().padLeft(2, '0')}',
//           fare: fare,
//           fromStation: _selectedFromStation!,
//           toStation: _selectedToStation!,
//           duration: '${random.nextInt(2)}h ${random.nextInt(60)}m'
//       ));
//     }
//     return tickets;
//   }
//
//   List<Widget> _buildTicketsUI() {
//     return _tickets.map((ticket) => _buildTicketCard(ticket)).toList();
//   }
//
//   Widget _buildTicketCard(Ticket ticket) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//       padding: EdgeInsets.all(15.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.0),
//         border: Border.all(color: Colors.green, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ClipPath(
//                     clipper: CurveClipper(),
//                     child: Container(
//                       color: Colors.green,
//                       width: 50,
//                       height: 50,
//                     ),
//                   ),
//                   Image.asset(
//                     'asset/tic.png', // Placeholder for the logo
//                     width: 50,
//                     height: 50,
//                   ),
//                   Text(
//                     'BDT ${ticket.fare}',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 left: 0,
//                 top: 10,
//                 child: ClipPath(
//                   clipper: CurveClipper(),
//                   child: Container(
//                     color: Colors.green,
//                     width: 30,
//                     height: 30,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStationInfo(ticket.fromStation),
//               Icon(Icons.arrow_forward),
//               _buildStationInfo(ticket.toStation),
//               Text(
//                 'Train No\n${ticket.trainNumber}',
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildIconText(Icons.calendar_today, '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
//               _buildIconText(Icons.access_time, ticket.timing),
//               _buildIconText(Icons.timer, ticket.duration),
//             ],
//           ),
//           SizedBox(height: 10),
//           SizedBox(
//             width: 100,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Implement your booking logic here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Booking feature will be implemented soon!'),
//                     duration: Duration(seconds: 3),
//                   ),
//                 );
//               },
//               child: Text('Book Now'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.green,
//                 padding: EdgeInsets.symmetric(vertical: 10.0),
//                 textStyle: TextStyle(fontSize: 14.0),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStationInfo(String station) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           station,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         // Optional: You can add more station-related information here if needed
//       ],
//     );
//   }
//
//   Widget _buildIconText(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.green), // Updated icon color to green
//         SizedBox(width: 5),
//         Text(text),
//       ],
//     );
//   }
// }
//
// class CurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width * 0.5, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CurveClipper oldClipper) => false;
// }
//
// class Ticket {
//   final String trainNumber;
//   final String timing;
//   final int fare;
//   final String fromStation;
//   final String toStation;
//   final String duration;
//
//   Ticket({
//     required this.trainNumber,
//     required this.timing,
//     required this.fare,
//     required this.fromStation,
//     required this.toStation,
//     required this.duration,
//   });
// }
