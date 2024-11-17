import 'dart:math';

import 'main_menu.dart';

class EquationGenerator {
  final Random random = Random();
  late List<int> solution;  // Stores each letter's value (A=solution[0], B=solution[1], etc.)

  // Generate a random unique permutation of numbers 1 to size
  List<int> generateSolution(int size) {
    List<int> numbers = List.generate(size, (index) => index + 1);
    numbers.shuffle(random);
    return numbers;
  }

  // Get the value for a letter based on solution
  int getValueForLetter(String letter) {
    return solution[letter.codeUnitAt(0) - 'A'.codeUnitAt(0)];
  }

  // Evaluate an expression with two letters
  int evaluateExpression(String letter1, String letter2) {
    int val1 = getValueForLetter(letter1);
    int val2 = getValueForLetter(letter2);
    return val1 * val2;
  }

  // Generate equation based on difficulty level
  String generateEquation(String letter1, String letter2, GameDifficulty difficulty) {
    int value1 = getValueForLetter(letter1);
    int value2 = getValueForLetter(letter2);
    int result = value1 * value2;

    switch (difficulty) {
      case GameDifficulty.easy:  // This is now like the old medium
        int randomType = random.nextInt(4);
        switch (randomType) {
          case 0:
            return '$letter1$letter2 = $result';
          case 1:
            return '$letter1$letter2 > ${result - 1}';
          case 2:
            return '$letter1$letter2 < ${result + 1}';
          case 3:
            int multiplier = random.nextInt(2) + 2;
            return '$letter1 * $multiplier = ${value1 * multiplier}';
        }
        break;

      case GameDifficulty.medium:  // This is now like the old hard
        int randomType = random.nextInt(4);
        switch (randomType) {
          case 0:
            int addend = random.nextInt(5) + 1;
            return '$letter1$letter2 + $addend = ${result + addend}';
          case 1:
            int subtrahend = random.nextInt(5) + 1;
            return '$letter1$letter2 - $subtrahend = ${result - subtrahend}';
          case 2:
            return '$letter1$letter2 + ${value1} > ${result + value1 - 1}';
          case 3:
            int multiplier = random.nextInt(2) + 2;
            return '$letter1$letter2 * $multiplier = ${result * multiplier}';
        }
        break;

      case GameDifficulty.hard:  // New harder equations
        int randomType = random.nextInt(5);
        switch (randomType) {
          case 0:
          // Multiple operations
            int addend = random.nextInt(3) + 1;
            int multiplier = random.nextInt(2) + 2;
            return '$letter1$letter2 * $multiplier + $addend = ${result * multiplier + addend}';

          case 1:
          // Complex inequality with multiple operations
            int subtrahend = random.nextInt(3) + 1;
            return '$letter1$letter2 - $letter1 > ${result - value1 - subtrahend}';

          case 2:
          // Three-part operation
            int addend = random.nextInt(3) + 1;
            return '$letter1$letter2 + $letter1 + $addend = ${result + value1 + addend}';

          case 3:
          // Double multiplication
            int multiplier1 = random.nextInt(2) + 2;
            int multiplier2 = random.nextInt(2) + 2;
            return '$letter1 * $multiplier1 + $letter2 * $multiplier2 = ${value1 * multiplier1 + value2 * multiplier2}';

          case 4:
          // Complex comparison with operations
            int addend = random.nextInt(3) + 1;
            return '$letter1$letter2 + $addend > ${result + random.nextInt(addend)}';
        }
        break;
    }
    return '$letter1$letter2 = $result';
  }

  int getEquationCount(int size, GameDifficulty difficulty) {
    // Base number of equations needed for solvability
    int baseCount = (size / 2).ceil() + 1;

    // Add difficulty modifier
    int difficultyModifier = switch (difficulty) {
      GameDifficulty.easy => 0,
      GameDifficulty.medium => 1,
      GameDifficulty.hard => 2,
    };

    // Calculate total equations, but cap at 8
    int totalEquations = baseCount + difficultyModifier;
    return totalEquations > 8 ? 8 : totalEquations;
  }

  List<String> generateEquations(int size, GameDifficulty difficulty) {
    solution = generateSolution(size);
    List<String> equations = [];
    Set<String> usedLetters = {};

    int targetEquations = getEquationCount(size, difficulty);

    // Keep track of letter pairs to avoid duplicates
    Set<String> usedPairs = {};

    while (equations.length < targetEquations) {
      int idx1 = random.nextInt(size);
      int idx2 = random.nextInt(size);
      String letter1 = String.fromCharCode('A'.codeUnitAt(0) + idx1);
      String letter2 = String.fromCharCode('A'.codeUnitAt(0) + idx2);

      // Avoid same letter combinations
      String pair = '$letter1$letter2';
      String reversePair = '$letter2$letter1';

      if (idx1 != idx2 && !usedPairs.contains(pair) && !usedPairs.contains(reversePair)) {
        String equation;
        switch (difficulty) {
          case GameDifficulty.easy:
            equation = generateEquation(letter1, letter2, GameDifficulty.easy);
            break;
          case GameDifficulty.medium:
            equation = generateEquation(letter1, letter2, GameDifficulty.medium);
            break;
          case GameDifficulty.hard:
            equation = generateEquation(letter1, letter2, GameDifficulty.hard);
            break;
        }

        equations.add(equation);
        usedPairs.add(pair);
        usedLetters.addAll([letter1, letter2]);

        // If we're not using enough letters, add single-letter equations
        if (equations.length == targetEquations - 1 &&
            usedLetters.length < size - 1) {
          // Find unused letter
          for (int i = 0; i < size; i++) {
            String letter = String.fromCharCode('A'.codeUnitAt(0) + i);
            if (!usedLetters.contains(letter)) {
              String singleEquation = generateSingleLetterEquation(letter, difficulty);
              equations.add(singleEquation);
              usedLetters.add(letter);
              break;
            }
          }
        }
      }
    }

    return equations;
  }

  String generateSingleLetterEquation(String letter, GameDifficulty difficulty) {
    int value = getValueForLetter(letter);
    switch (difficulty) {
      case GameDifficulty.easy:
        return '$letter < ${value + 1}';
      case GameDifficulty.medium:
        return '2 * $letter = ${2 * value}';
      case GameDifficulty.hard:
        int addend = random.nextInt(3) + 1;
        return '$letter + $addend = ${value + addend}';
    }
  }

  // Verify that equations lead to a unique solution
  bool verifyEquationsHaveUniqueSolution(List<String> equations, int size) {
    // Here you would implement logic to verify the equations have a unique solution
    // This is a complex task that would involve solving the system of equations
    // For now, we'll assume the equations are valid if they:
    // 1. Use all letters at least once
    // 2. Have enough constraints based on difficulty
    Set<String> usedLetters = {};
    for (String eq in equations) {
      for (int i = 0; i < eq.length; i++) {
        if (eq[i].codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            eq[i].codeUnitAt(0) <= ('A'.codeUnitAt(0) + size - 1)) {
          usedLetters.add(eq[i]);
        }
      }
    }
    return usedLetters.length == size;
  }

  // Verify a solution attempt
  bool verifySolution(Map<String, int> attempt) {
    for (int i = 0; i < solution.length; i++) {
      String letter = String.fromCharCode('A'.codeUnitAt(0) + i);
      if (attempt[letter] != solution[i]) {
        return false;
      }
    }
    return true;
  }

  // Helper method to print current solution for debugging
  void printSolution() {
    for (int i = 0; i < solution.length; i++) {
      String letter = String.fromCharCode('A'.codeUnitAt(0) + i);
      print('$letter = ${solution[i]}');
    }
  }
}

// Example usage:
void main() {
  final generator = EquationGenerator();

  print('\nEasy 4x4:');
  var easyEqs = generator.generateEquations(4, GameDifficulty.easy);
  print(easyEqs);
  generator.printSolution();

  print('\nMedium 4x4:');
  var mediumEqs = generator.generateEquations(4, GameDifficulty.medium);
  print(mediumEqs);
  generator.printSolution();

  print('\nHard 4x4:');
  var hardEqs = generator.generateEquations(4, GameDifficulty.hard);
  print(hardEqs);
  generator.printSolution();
}