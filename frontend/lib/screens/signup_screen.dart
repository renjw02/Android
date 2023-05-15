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

import '../Auth/customAuth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await CustomAuth().register(
      _usernameController.text, _passwordController.text,_nicknameController.text
    );
    if (res == "Success") {
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
                'logo.svg',
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
                hintText: '输入用户名',
                textEditingController: _usernameController,
                textInputType: TextInputType.text,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 50,
              width: 370,
              child: TextFieldInput(
                hintText: '输入密码',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 370,
              height: 50,
              child: TextFieldInput(
                hintText: '输入昵称',
                textEditingController: _nicknameController,
                textInputType: TextInputType.text,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: signUpUser,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(blueColor),
                minimumSize: MaterialStateProperty.all(
                  const Size(
                    370,
                    50,
                  ),
                ),
              ),
              child: !_isLoading
                  ? const Text(
                '注册',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
                  : const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("已有账号?"),
                  Text(
                    "登陆",
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