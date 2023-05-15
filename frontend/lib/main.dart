import 'package:flutter/material.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/responsive/mobile_screen_layout.dart';
import 'package:frontend/responsive/responsive_layout.dart';
import 'package:frontend/responsive/web_screen_layout.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:provider/provider.dart';

import 'Auth/customAuth.dart';

void main() async {
  final CustomAuth _auth = CustomAuth();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(auth: _auth,));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.auth});
  final CustomAuth auth;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider(),),//作用是将UserProvider的实例传递给子树中的所有子孙widget
        ],
        child:MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'INS Style forum',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: mobileBackgroundColor,
          ),
          // home: LoginScreen(),
          home: StreamBuilder(
            stream: auth.authStateChanges,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                // Checking if the snapshot has any data or not
                if (snapshot.hasData) {
                  // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                  return const ResponsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }
              }

              // means connection to future hasnt been made yet
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }

              return const LoginScreen();
            },
          ),
        ),
    );

  }
}
