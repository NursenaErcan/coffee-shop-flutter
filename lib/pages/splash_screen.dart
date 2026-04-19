import 'package:flutter/material.dart';
import 'package:flutterproject/Widgets/common_button.dart';
import 'package:flutterproject/pages/app_main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            SizedBox(
              child: Image.asset(
                "assets/coffee-shop/bg.png",
                height: size.height / 1.3,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 45,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Kahveye aşık ol, her yudumun tadını çıkar!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sıcacık kahveler, keyifli ortam ve hızlı sipariş deneyimi seni bekliyor.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CommonButton(
                      title: "Başla",
                      onTab: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoffeeAppMainScreen(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}