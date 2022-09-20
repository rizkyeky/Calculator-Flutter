import 'dart:async';
import 'package:flutter/material.dart';

extension StringExtension on String {
  bool get isNumber => isNotEmpty && contains(RegExp(r'[0-9]'));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final StreamController<String> inputDisplayController = StreamController();
  final StreamController<String> resultDisplayController = StreamController();

  final List<String> tempInputs = [];

  void clearAllInputs() {
    if (tempInputs.isNotEmpty) {
      tempInputs.clear();
      inputDisplayController.sink.add('0');
      resultDisplayController.sink.add('');
    }
  }

  void delInputs() {
    if (tempInputs.isNotEmpty) {
      tempInputs.removeLast();
      if (tempInputs.isEmpty) {
        inputDisplayController.sink.add('0');
      } else {
        inputDisplayController.sink.add(tempInputs.join());
      }
    }
  }

  num calculate(String oper, num number1, num number2) {
    switch (oper) {
      case '+': return number1 + number2;
      case '-': return number1 - number2;
      case '×': return number1 * number2;
      case '÷': 
        try {
          return number1 / number2;
        } catch (e) {
          return 0;
        }
      default: return 0;
    }
  }

  void calculateInputs() {
    if (tempInputs.isNotEmpty) {
      
      final tempNumbers = tempInputs.join().split(RegExp(r'[+-]|[÷×]'));
      final tempOpers = tempInputs.join().split(RegExp(r'[0-9]|[.]'));
      tempOpers.removeWhere((e) => e.isEmpty);

      final mainNumbers = tempNumbers.map((e) => e.contains('.') ? double.parse(e) : int.parse(e)).toList();
      final mainOpers = List<String>.from(tempOpers);

      num result = 0;
      int countCalc = 0;

      if (mainOpers.isNotEmpty) {
        do {

          final oper = mainOpers.removeAt(0);

          if (countCalc == 0) {
            final number1 = mainNumbers.removeAt(0);
            final number2 = mainNumbers.removeAt(0);

            result = calculate(oper, number1, number2);
            countCalc++;
          } else {
            final number = mainNumbers.removeAt(0);
            result = calculate(oper, result, number);
            countCalc++;
          }

        } while (mainOpers.isNotEmpty);

        resultDisplayController.sink.add(result.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<List<String>> listLayoutNumbers = [
      ['AC', 'Del', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '-'],
      ['0', '.', '=']
    ];

    final Map<String, Color> charColors = {
      'AC': Colors.grey.shade200,
      'Del': Colors.grey.shade200,
      '÷': Colors.orange,
      '×': Colors.orange,
      '+': Colors.orange,
      '-': Colors.orange,
      '=': Colors.orange,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreamBuilder<String>(
                    stream: inputDisplayController.stream,
                    builder: (context, snasphot) {
                      final str = snasphot.data ?? '0';
                      return Text(str,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 8,),
                  StreamBuilder<String>(
                    stream: resultDisplayController.stream,
                    builder: (context, snapshot) {
                      final str = snapshot.data ?? '';
                      return Text(str,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.grey
                        ),
                      );
                    }
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  for (final row in listLayoutNumbers) Expanded(
                    child: Row(
                      children: [
                        for (final char in row) Expanded(
                          flex: ['AC', '0'].contains(char) ? 2 : 1,
                          child: Material(
                            color: charColors.containsKey(char) ? charColors[char] : Colors.grey.shade100,
                            child: InkWell(
                              onTap: () {
                                if (char.isNumber) { // Untuk number
                                  tempInputs.add(char);
                                  inputDisplayController.sink.add(tempInputs.join());
                                } else if (char == '.') {
                                  int startSub = tempInputs.lastIndexWhere((e) => ['÷', '×', '-', '+'].contains(e));
                                  int endSub = tempInputs.length-1;
                                  
                                  var subTempInput = List<String>.from(tempInputs);
                                  if (startSub != -1) {
                                    subTempInput = tempInputs.sublist(startSub+1, endSub+1);
                                  }

                                  if (!subTempInput.contains('.')) {
                                    if (subTempInput.isNotEmpty && subTempInput.last.isNumber) {
                                      tempInputs.add(char);
                                    }
                                  }
                                }
                                 else if  (['÷', '×', '-', '+'].contains(char)) { // Untuk operator
                                  if (tempInputs.isNotEmpty) {
                                    if (tempInputs.last.isNumber) {
                                      tempInputs.add(char);
                                    } else {
                                      tempInputs.removeLast();
                                      tempInputs.add(char);
                                    }
                                  }
                                  inputDisplayController.sink.add(tempInputs.join());
                                } else if (char == 'AC') { // Untuk AC
                                  clearAllInputs();
                                } else if (char == 'Del') { // Untuk Del
                                  delInputs();
                                } else if (char == '=') { // Untuk Del
                                  calculateInputs();
                                }
                              },
                              child: Center(
                                child: Text(char,
                                  style: const TextStyle(
                                    fontSize: 24
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
