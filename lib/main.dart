import 'package:expance_manager/screen/home.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> transactions = [];
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Light ya dark mode system se
      // theme: ThemeData(
      //   brightness: Brightness.light,
      //   primarySwatch: Colors.teal,
      //   scaffoldBackgroundColor: Colors.white,
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: Colors.teal,
      //     foregroundColor: Colors.white,
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.teal,
      //       foregroundColor: Colors.white,
      //     ),
      //   ),
      //   checkboxTheme: CheckboxThemeData(
      //     checkColor: WidgetStatePropertyAll(Colors.white),
      //     fillColor: WidgetStatePropertyAll(Colors.teal),
      //   ),
      //   tabBarTheme: TabBarThemeData(
      //     labelColor: Colors.teal[800], // Selected tab icon/text
      //     unselectedLabelColor: Colors.teal[300], // Unselected tab icon/text
      //     labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      //     unselectedLabelStyle: TextStyle(fontSize: 13),
      //     indicator: UnderlineTabIndicator(
      //       borderSide: BorderSide(
      //         width: 3.0,
      //         color: Colors.teal,
      //       ), // or deepOrange if you want contrast
      //     ),
      //   ),
      // ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   primarySwatch: Colors.red,
      //   scaffoldBackgroundColor: Colors.black,
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: Colors.black,
      //     foregroundColor: Colors.white,
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.orange,
      //       foregroundColor: Colors.white,
      //     ),
      //   ),
      //   checkboxTheme: CheckboxThemeData(
      //     checkColor: WidgetStatePropertyAll(Colors.white),
      //     fillColor: WidgetStatePropertyAll(Colors.orange),
      //   ),

      //   tabBarTheme: TabBarThemeData(
      //     labelColor: Colors.deepOrange, // Selected icon/text color
      //     unselectedLabelColor: Colors.white70, // Unselected color
      //     labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      //     unselectedLabelStyle: TextStyle(fontSize: 13),
      //     indicator: UnderlineTabIndicator(
      //       borderSide: BorderSide(width: 3.0, color: Colors.deepOrange),
      //     ),
      //   ),
      // ),
 theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF1976D2), // Blue from logo
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.white),
          fillColor: WidgetStatePropertyAll(Color(0xFF1976D2)),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Color(0xFF0D47A1), // darker blue
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 13),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Color(0xFF1976D2)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent[700],
            foregroundColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.white),
          fillColor: WidgetStatePropertyAll(Colors.blueAccent),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 13),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Colors.blueAccent),
          ),
        ),
      ),
      title: 'LedgerMate',
      // home: ExpenseTrackerScreen(),
      home: DefaultTabController(
        length: 2, // Number of tabs (e.g. Overview + Add Entry)
        child: MainTabScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
