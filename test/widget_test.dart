import 'package:flutter_test/flutter_test.dart';
import 'package:planner/core/utils/speech_parser.dart';

void main() {
  test('SpeechParser extracts task name and subtasks', () {
    final parsed = SpeechParser.parse(
      'create a task named Design website with subtasks mockup, layout and coding',
    );
    expect(parsed['taskName'], 'Design website');
    expect(parsed['subtasks'], ['mockup', 'layout', 'coding']);
  });
}
