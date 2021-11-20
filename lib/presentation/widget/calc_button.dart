import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String text;
  final Color? fillColor;
  final double textSize;
  final Function callback;
  final bool disable;

  const CalcButton({
    Key? key,
    required this.text,
    this.fillColor,
    this.textSize = 28,
    required this.callback,
    this.disable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disable,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: SizedBox(
          width: 70,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              callback(text);
            },
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: textSize,
                    color: Colors.white,
                  ),
            ),
            style: ElevatedButton.styleFrom(
              primary: fillColor ?? Colors.blueGrey[300],
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
