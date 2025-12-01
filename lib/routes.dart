import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'privacy_page.dart';
import 'about_page.dart';
import 'schedule_appointment_page.dart';
import 'medical_tips_page.dart';
import 'dashboard_page.dart'; 
import 'graphics_page.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String scheduleAppointment = '/schedule-appointment';
  static const String medicalTips = '/medical-tips';
  static const String dashboard = '/dashboard';
  static const String graphics = '/graphics';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPage());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case scheduleAppointment:
        return MaterialPageRoute(builder: (_) => const ScheduleAppointmentPage());
      case medicalTips:
        return MaterialPageRoute(builder: (_) => const MedicalTipsPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case graphics:
        return MaterialPageRoute(builder: (_) => const GraphicsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${routeSettings.name}')),
          ),
        );
    }
  }
}