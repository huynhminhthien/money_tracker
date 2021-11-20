import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker/logic/cubit/authentication_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/presentation/widget/notify.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff572cd8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Background(),
            Align(
              alignment: const FractionalOffset(0.2, 0.1),
              child: Text(
                'Money\n       Tracker',
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.headline2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            BlocListener<AuthenticationCubit, AuthenticationState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  Navigator.pushReplacementNamed(context, AppRouter.bottomNav);
                } else if (state is Unauthenticated &&
                    state.message.isNotEmpty) {
                  showNotify(context, state.message);
                }
              },
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 70),
                child: IconButton(
                  iconSize: 50,
                  icon: const Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthenticationCubit>(context)
                        .authenticateWithBiometrics();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.only(right: 350),
        height: MediaQuery.of(context).size.height * 0.75,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: SvgPicture.asset(
              'assets/images/start_screen.svg',
              allowDrawingOutsideViewBox: true,
            ),
          ),
        ),
      ),
    );
  }
}
