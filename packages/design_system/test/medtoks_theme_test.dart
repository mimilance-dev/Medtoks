import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtoks_design_system/medtoks_design_system.dart';

void main() {
  test('exposes shared spacing and theme tokens', () {
    expect(MedtoksSpacing.md, 16);
    expect(MedtoksTheme.cupertino.primaryColor, MedtoksColors.teal);
    expect(MedtoksTheme.material.scaffoldBackgroundColor, MedtoksColors.canvas);
    expect(AppSpacing.lg, 16);
    expect(AppTheme.cupertinoLight.brightness, Brightness.light);
    expect(AppTheme.cupertinoDark.brightness, Brightness.dark);
    expect(AppTheme.materialLight.brightness, Brightness.light);
    expect(AppTheme.materialDark.brightness, Brightness.dark);
  });
}
