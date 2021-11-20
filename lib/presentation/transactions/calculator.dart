import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:money_tracker/presentation/widget/calc_button.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';

class Calculator extends StatefulWidget {
  const Calculator({Key? key, required this.callback}) : super(key: key);
  final Function(int) callback;

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = '';
  String _input = '';
  String _expressionDisplay = '0';

  void numClick(String text) {
    setState(() => _expressionDisplay = formatString(_input += text, unit: ''));
  }

  void signEvaluate(String text) {
    setState(() {
      _expression += _input + text;
      _expressionDisplay = '0';
    });
    _input = '';
  }

  void allClear(String text) {
    _input = '';
    setState(() {
      _expression = '';
      _expressionDisplay = '0';
    });
  }

  void clear(String text) {
    _input = _input.isNotEmpty ? _input.substring(0, _input.length - 1) : '';
    setState(() => _expressionDisplay =
        _input.isNotEmpty ? formatString(_input, unit: '') : '0');
  }

  void evaluate(String text) {
    if (_input.isEmpty) {
      widget.callback(0);
      return;
    }
    _expression += _input;
    _input = '';
    Parser p = Parser();
    Expression exp = p.parse(_expression);
    ContextModel cm = ContextModel();

    final result = exp.evaluate(EvaluationType.REAL, cm).toInt();
    // setState(() {
    //   _expressionDisplay = formatString(result.toString(), unit: '');
    // });
    // _expression = '';
    widget.callback(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _expression,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            alignment: const Alignment(1.0, 1.0),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _expressionDisplay,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            alignment: const Alignment(1.0, 1.0),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                text: '7',
                callback: numClick,
              ),
              CalcButton(
                text: '8',
                callback: numClick,
              ),
              CalcButton(
                text: '9',
                callback: numClick,
              ),
              CalcButton(
                text: '⌫',
                fillColor: Theme.of(context).primaryColor,
                callback: clear,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                text: '4',
                callback: numClick,
              ),
              CalcButton(
                text: '5',
                callback: numClick,
              ),
              CalcButton(
                text: '6',
                callback: numClick,
              ),
              CalcButton(
                text: '*',
                fillColor: Theme.of(context).primaryColor,
                textSize: 30,
                callback: signEvaluate,
                disable: _input.isEmpty,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                text: '1',
                callback: numClick,
              ),
              CalcButton(
                text: '2',
                callback: numClick,
              ),
              CalcButton(
                text: '3',
                callback: numClick,
              ),
              CalcButton(
                text: '+',
                fillColor: Theme.of(context).primaryColor,
                textSize: 30,
                callback: signEvaluate,
                disable: _input.isEmpty,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CalcButton(
                text: 'AC',
                fillColor: Theme.of(context).primaryColor,
                textSize: 20,
                callback: allClear,
              ),
              CalcButton(
                text: '0',
                callback: numClick,
                disable: _input.isEmpty,
              ),
              CalcButton(
                text: '000',
                callback: numClick,
                textSize: 26,
                fillColor: Theme.of(context).primaryColor,
                disable: _input.isEmpty,
              ),
              CalcButton(
                text: '=',
                fillColor: Theme.of(context).primaryColor,
                callback: evaluate,
              ),
            ],
          )
        ],
      ),
    );
  }
}
