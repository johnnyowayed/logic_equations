import 'package:flutter/material.dart';
import 'info_page.dart';
import 'move_state.dart';

class MathGridGame extends StatefulWidget {
  final int gridSize;
  final List<String> equations;

  const MathGridGame({
    Key? key,
    required this.gridSize,
    required this.equations,
  }) : super(key: key);

  @override
  _MathGridGameState createState() => _MathGridGameState();
}

class _MathGridGameState extends State<MathGridGame> {
  late List<List<String>> gridValues;
  Map<String, int> letterValues = {};

  List<MoveState> undoStack = [];
  List<MoveState> redoStack = [];

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void saveState() {
    redoStack.clear(); // Clear redo stack when new move is made
    undoStack.add(MoveState(
      List<List<String>>.from(
        gridValues.map((row) => List<String>.from(row)),
      ),
      Map<String, int>.from(letterValues),
    ));
  }

  void undo() {
    if (undoStack.isEmpty) return;

    // Save current state to redo stack
    redoStack.add(MoveState(
      List<List<String>>.from(
        gridValues.map((row) => List<String>.from(row)),
      ),
      Map<String, int>.from(letterValues),
    ));

    // Restore previous state
    final previousState = undoStack.removeLast();
    setState(() {
      gridValues = List<List<String>>.from(
        previousState.gridValues.map((row) => List<String>.from(row)),
      );
      letterValues = Map<String, int>.from(previousState.letterValues);
    });
  }

  void redo() {
    if (redoStack.isEmpty) return;

    // Save current state to undo stack
    undoStack.add(MoveState(
      List<List<String>>.from(
        gridValues.map((row) => List<String>.from(row)),
      ),
      Map<String, int>.from(letterValues),
    ));

    // Restore next state
    final nextState = redoStack.removeLast();
    setState(() {
      gridValues = List<List<String>>.from(
        nextState.gridValues.map((row) => List<String>.from(row)),
      );
      letterValues = Map<String, int>.from(nextState.letterValues);
    });
  }

  void initializeGrid() {
    gridValues = List.generate(
      widget.gridSize,
      (_) => List<String>.generate(widget.gridSize, (_) => ''),
    );
    letterValues.clear();
    undoStack.clear();
    redoStack.clear();
  }

  bool validateEquation(String equation) {
    // Remove all spaces
    equation = equation.replaceAll(' ', '');

    // If any letter in the equation doesn't have a value, return false
    RegExp letterRegex = RegExp(r'[A-Z]');
    for (Match match in letterRegex.allMatches(equation)) {
      String letter = match.group(0)!;
      if (!letterValues.containsKey(letter)) {
        return false;
      }
    }

    // Parse and validate each type of equation
    if (equation.contains('=')) {
      List<String> parts = equation.split('=');
      int leftSide = evaluateExpression(parts[0].trim())!;
      int rightSide = evaluateExpression(parts[1].trim())!;
      return leftSide == rightSide;
    } else if (equation.contains('<')) {
      List<String> parts = equation.split('<');
      int leftSide = evaluateExpression(parts[0].trim())!;
      int rightSide = evaluateExpression(parts[1].trim())!;
      return leftSide < rightSide;
    } else if (equation.contains('>')) {
      List<String> parts = equation.split('>');
      int leftSide = evaluateExpression(parts[0].trim())!;
      int rightSide = evaluateExpression(parts[1].trim())!;
      return leftSide > rightSide;
    }
    return false;
  }

  int? evaluateExpression(String expression) {
    // Remove any whitespace
    expression = expression.replaceAll(' ', '');

    // Handle single numbers
    if (int.tryParse(expression) != null) {
      return int.parse(expression);
    }

    // Handle single letters
    if (expression.length == 1 && letterValues.containsKey(expression)) {
      return letterValues[expression];
    }

    // Handle addition
    if (expression.contains('+')) {
      List<String> parts = expression.split('+');
      return evaluateExpression(parts[0])! + evaluateExpression(parts[1])!;
    }

    // Handle subtraction
    if (expression.contains('-')) {
      List<String> parts = expression.split('-');
      return evaluateExpression(parts[0])! - evaluateExpression(parts[1])!;
    }

    // Handle multiplication marked with *
    if (expression.contains('*')) {
      List<String> parts = expression.split('*');
      return evaluateExpression(parts[0])! * evaluateExpression(parts[1])!;
    }

    // Handle two-letter multiplication (like AB means A*B)
    if (expression.length == 2 && expression.contains(RegExp(r'^[A-Z]{2}$'))) {
      int val1 = letterValues[expression[0]]!;
      int val2 = letterValues[expression[1]]!;
      return val1 * val2;
    }

    // Handle number prefix (like 2A means 2*A)
    RegExp numLetterRegex = RegExp(r'(\d+)([A-Z])');
    Match? match = numLetterRegex.firstMatch(expression);
    if (match != null) {
      int number = int.parse(match.group(1)!);
      String letter = match.group(2)!;
      return number * letterValues[letter]!;
    }

    return null;
  }

  Color getEquationColor(String equation) {
    // Check if all letters in the equation have values
    bool hasAllValues = true;
    RegExp letterRegex = RegExp(r'[A-Z]');
    for (Match match in letterRegex.allMatches(equation)) {
      String letter = match.group(0)!;
      if (!letterValues.containsKey(letter)) {
        hasAllValues = false;
        break;
      }
    }

    if (!hasAllValues) {
      return Colors.blue.shade100; // Keep blue if not all values are present
    }

    return validateEquation(equation)
        ? Colors.green.shade100 // Green if equation is satisfied
        : Colors.red.shade100; // Red if equation is not satisfied
  }

  String getRowLabel(int index) {
    return String.fromCharCode(65 + index);
  }

  bool canPlaceTick(int row, int col) {
    for (int c = 0; c < widget.gridSize; c++) {
      if (c != col && gridValues[row][c] == '✓') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot place two ticks in the same row'),
            duration: Duration(seconds: 1),
          ),
        );
        return false;
      }
    }

    for (int r = 0; r < widget.gridSize; r++) {
      if (r != row && gridValues[r][col] == '✓') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot place two ticks in the same column'),
            duration: Duration(seconds: 1),
          ),
        );
        return false;
      }
    }

    return true;
  }

  void updateLetterValues() {
    letterValues.clear();
    for (int row = 0; row < widget.gridSize; row++) {
      for (int col = 0; col < widget.gridSize; col++) {
        if (gridValues[row][col] == '✓') {
          String letter = getRowLabel(row);
          letterValues[letter] = col + 1;
        }
      }
    }

    // Check if all equations are satisfied
    bool allSatisfied = true;
    // First check if we have all needed letters
    for (String equation in widget.equations) {
      RegExp letterRegex = RegExp(r'[A-Z]');
      for (Match match in letterRegex.allMatches(equation)) {
        String letter = match.group(0)!;
        if (!letterValues.containsKey(letter)) {
          allSatisfied = false;
          break;
        }
      }
      if (!allSatisfied) break;

      // Then check if equation is satisfied
      if (!validateEquation(equation)) {
        allSatisfied = false;
        break;
      }
    }

    // Show congratulations if all equations are satisfied
    if (allSatisfied) {
      showCongratulationsDialog();
    }

    // Force rebuild to update equation colors
    setState(() {});
  }

  void showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.green.shade100,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You solved all equations correctly!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Solution:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: letterValues.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${entry.key} = ${entry.value}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          initializeGrid();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateCellAndRelated(int row, int col) {
    saveState(); // Save state before making changes

    if (gridValues[row][col] == '') {
      setState(() {
        gridValues[row][col] = '×';
      });
    } else if (gridValues[row][col] == '×') {
      if (canPlaceTick(row, col)) {
        setState(() {
          gridValues[row][col] = '✓';
          for (int c = 0; c < widget.gridSize; c++) {
            if (c != col && gridValues[row][c] == '') {
              gridValues[row][c] = '×';
            }
          }
          for (int r = 0; r < widget.gridSize; r++) {
            if (r != row && gridValues[r][col] == '') {
              gridValues[r][col] = '×';
            }
          }
          updateLetterValues();
        });
      }
    } else {
      setState(() {
        gridValues[row][col] = '';
        clearUnneededXMarks();
        updateLetterValues();
      });
    }
  }

  void clearUnneededXMarks() {
    Set<String> cellsToKeepX = {};

    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (gridValues[r][c] == '✓') {
          for (int col = 0; col < widget.gridSize; col++) {
            cellsToKeepX.add('$r,$col');
          }
          for (int row = 0; row < widget.gridSize; row++) {
            cellsToKeepX.add('$row,$c');
          }
        }
      }
    }

    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        if (gridValues[r][c] == '×' && !cellsToKeepX.contains('$r,$c')) {
          gridValues[r][c] = '';
        }
      }
    }
  }

  Widget buildEquations() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: widget.equations.map((equation) {
          Color bgColor = getEquationColor(equation);
          Color borderColor = bgColor == Colors.blue.shade100
              ? Colors.blue.shade300
              : bgColor == Colors.green.shade100
                  ? Colors.green.shade300
                  : Colors.red.shade300;

          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              equation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildLetterValues() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: letterValues.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(
              '${entry.key} = ${entry.value}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildGridCell(int row, int col) {
    return GestureDetector(
      onTap: () => updateCellAndRelated(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            gridValues[row][col],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gridValues[row][col] == '✓' ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  // In your MathGridGame class, update the buildGameGrid method:

  Widget buildGameGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Numbers row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 30), // Space for letters column
              ...List.generate(
                widget.gridSize,
                (index) => SizedBox(
                  width: 45, // Slightly reduced cell size
                  height: 30,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 16, // Slightly reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Grid with letters
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Letters column
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    widget.gridSize,
                    (index) => SizedBox(
                      width: 30,
                      height: 45, // Slightly reduced cell size
                      child: Center(
                        child: Text(
                          getRowLabel(index),
                          style: const TextStyle(
                            fontSize: 16, // Slightly reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Main grid
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade300, width: 2.0),
                  ),
                  child: Column(
                    children: List.generate(
                      widget.gridSize,
                      (row) => Row(
                        children: List.generate(
                          widget.gridSize,
                          (col) => SizedBox(
                            width: 45, // Slightly reduced cell size
                            height: 45, // Slightly reduced cell size
                            child: buildGridCell(row, col),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gridSize}x${widget.gridSize} Math Grid'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How to Play',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildEquations(),
              const SizedBox(height: 20),
              // Center the game grid and make it scrollable
              Center(
                child: buildGameGrid(),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          initializeGrid();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: undoStack.isEmpty ? null : undo,
                      icon: const Icon(Icons.undo),
                      tooltip: 'Undo',
                      color: undoStack.isEmpty ? Colors.grey : Colors.blue,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: redoStack.isEmpty ? null : redo,
                      icon: const Icon(Icons.redo),
                      tooltip: 'Redo',
                      color: redoStack.isEmpty ? Colors.grey : Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
