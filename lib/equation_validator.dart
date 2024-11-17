class EquationValidator {
  // Evaluate an equation with given values
  static bool evaluateEquation(String equation, Map<String, int> values) {
    // Remove all spaces
    equation = equation.replaceAll(' ', '');

    // Split for different operators
    if (equation.contains('=')) {
      List<String> parts = equation.split('=');
      int leftSide = evaluateExpression(parts[0], values);
      int rightSide = evaluateExpression(parts[1], values);
      return leftSide == rightSide;
    }
    else if (equation.contains('>')) {
      List<String> parts = equation.split('>');
      int leftSide = evaluateExpression(parts[0], values);
      int rightSide = evaluateExpression(parts[1], values);
      return leftSide > rightSide;
    }
    else if (equation.contains('<')) {
      List<String> parts = equation.split('<');
      int leftSide = evaluateExpression(parts[0], values);
      int rightSide = evaluateExpression(parts[1], values);
      return leftSide < rightSide;
    }
    return false;
  }

  // Evaluate an expression (like "AB", "A+B", "2*A", etc.)
  static int evaluateExpression(String expr, Map<String, int> values) {
    // Handle numeric values
    if (int.tryParse(expr) != null) {
      return int.parse(expr);
    }

    // Handle single letters
    if (expr.length == 1 && expr.contains(RegExp(r'[A-Z]'))) {
      return values[expr] ?? 0;
    }

    // Handle addition
    if (expr.contains('+')) {
      List<String> parts = expr.split('+');
      return evaluateExpression(parts[0], values) + evaluateExpression(parts[1], values);
    }

    // Handle multiplication marked with *
    if (expr.contains('*')) {
      List<String> parts = expr.split('*');
      return evaluateExpression(parts[0], values) * evaluateExpression(parts[1], values);
    }

    // Handle subtraction
    if (expr.contains('-')) {
      List<String> parts = expr.split('-');
      return evaluateExpression(parts[0], values) - evaluateExpression(parts[1], values);
    }

    // Handle adjacent letters as multiplication (like "AB" means A*B)
    if (expr.length == 2 && expr.contains(RegExp(r'^[A-Z]{2}$'))) {
      return (values[expr[0]] ?? 0) * (values[expr[1]] ?? 0);
    }

    // Handle number prefix (like "2A" means 2*A)
    if (expr.contains(RegExp(r'^\d+[A-Z]$'))) {
      RegExp numRegex = RegExp(r'(\d+)([A-Z])');
      var match = numRegex.firstMatch(expr);
      if (match != null) {
        int number = int.parse(match.group(1)!);
        String letter = match.group(2)!;
        return number * (values[letter] ?? 0);
      }
    }

    return 0;
  }
}