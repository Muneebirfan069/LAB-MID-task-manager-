import 'packagefluttermaterial.dart';
import 'packageproviderprovider.dart';
import 'packageflutter_local_notificationsflutter_local_notifications.dart';
import 'providerstask_provider.dart';
import 'screenshome_screen.dart';
import 'servicesnotification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   Initialize notifications
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create (context) = TaskProvider(),
      child ConsumerTaskProvider(
        builder (context, taskProvider, child) {
          return MaterialApp(
            title 'Task Manager',
            debugShowCheckedModeBanner false,
            theme taskProvider.isDarkMode  ThemeData.dark()  ThemeData.light(),
            home const HomeScreen(),
          );
        },
      ),
    );
  }
}