import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/models/antique_item_model.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Auth và Firestore)
  await Firebase.initializeApp();
  
  // Initialize Supabase (Storage)
  await Supabase.initialize(
    url: 'https://vfipvhltzaeospuvnire.supabase.co', // Sẽ lấy từ Supabase Dashboard
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmaXB2aGx0emFlb3NwdXZuaXJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNzYwMDEsImV4cCI6MjA3OTc1MjAwMX0.GZhe2SBGu5ifeGudOO1uxJpKT2teM9RB1P9rQOWNUqU', // Sẽ lấy từ Supabase Dashboard
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AntiqueItemModelAdapter());
  await Hive.openBox<AntiqueItemModel>('antique_items');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antique Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // Saddle Brown
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansTextTheme(),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const SplashScreen(),
    );
  }
}