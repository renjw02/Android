import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/resources/auth_methods.dart';
import 'package:frontend/responsive/mobile_screen_layout.dart';
import 'package:frontend/responsive/responsive_layout.dart';
import 'package:frontend/responsive/web_screen_layout.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/colors.dart';
// import 'package:frontend/utils/dimensions.dart';
import 'package:frontend/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.height * 0.25,
              child: SvgPicture.asset(
                'assets/ic_instagram.svg',
                color: primaryColor,
                height: 64,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 370,
              height: 50,
              child: TextFieldInput(
                hintText: 'Enter Username',
                textEditingController: _usernameController,
                textInputType: TextInputType.text,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 370,
              height: 50,
              child: TextFieldInput(
                hintText: 'Enter Email',
                textEditingController: _emailController,
                textInputType: TextInputType.emailAddress,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 50,
              width: 370,
              child: TextFieldInput(
                hintText: 'Enter Password',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: signUpUser,
              child: !_isLoading
                  ? const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
                  : const Center(
                child: CircularProgressIndicator(),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(blueColor),
                minimumSize: MaterialStateProperty.all(
                  const Size(
                    370,
                    50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Already have an account?"),
                  Text(
                    " Login.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}