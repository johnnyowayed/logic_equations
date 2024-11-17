import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  Widget _buildSection(String title, List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...bullets.map((bullet) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  bullet,
                  style: const TextStyle(fontSize: 16),
                  softWrap: true,
                ),
              ),
            ],
          ),
        )).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'How to Play',
                [
                  'The variables represents unique integers ranging from 1 to the number of variables',
                  'Multiplication is implicit: AB means A times B, or A * B',
                  'Based on the clues (equations and inequations), use the grid to create relations between variables and values:\n'
                      '   • Click once on a square to mark that value as false\n'
                      '   • Click twice to assign the chosen value to the variable\n'
                      '   • Click three times to clear the square',
                  'The color of a clue changes after you assign values to all of its variables:\n'
                      '   • GREEN means that the statement is true\n'
                      '   • RED means that the statement is false',
                  'Click on a clue to mark it as used',
                  'The game ends when all values are correctly assigned to the variables',
                ],
              ),
              _buildSection(
                'Tips',
                [
                  'Figuring out which variables can\'t have the lowest or the highest values is a good starting point, e.g, A > B shows that A ≠ 1',
                  'Analyzing the hypothetical equation C + D = 4, we can make the following statements:\n'
                      '   • C = 1 and D = 3 OR C = 3 and D = 1\n'
                      '   • No other variable can be 1 or 3 (see Naked Pairs in our Sudoku Guide)',
                  'Another quick tip: A = 2B means that A is even',
                  'Don\'t be afraid of using pen and paper. Some puzzles might require it',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}