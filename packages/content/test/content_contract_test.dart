import 'package:medtoks_content/medtoks_content.dart';
import 'package:test/test.dart';

void main() {
  test('exports an educational resource contract', () {
    const resource = LearningResource(id: 'resource-id', title: 'Placeholder', kind: 'article');
    expect(resource.id, 'resource-id');
  });
}
