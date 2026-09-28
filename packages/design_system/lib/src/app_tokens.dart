import 'package:flutter/cupertino.dart';

abstract final class AppColors {
  static const brand = Color(0xFF087E83);
  static const brandPressed = Color(0xFF06676B);
  static const coral = Color(0xFFE47761);
  static const amber = Color(0xFFB77516);
  static const success = Color(0xFF287A56);
  static const danger = Color(0xFFB43D45);

  static const lightCanvas = Color(0xFFF5F7F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFFBFCFC);
  static const lightInk = Color(0xFF202B33);
  static const lightMuted = Color(0xFF637179);
  static const lightBorder = Color(0xFFDCE4E2);
  static const lightPrimaryText = Color(0xFFFFFFFF);

  static const darkCanvas = Color(0xFF11191D);
  static const darkSurface = Color(0xFF1B262B);
  static const darkElevated = Color(0xFF243238);
  static const darkInk = Color(0xFFF2F6F5);
  static const darkMuted = Color(0xFFA9B7BA);
  static const darkBorder = Color(0xFF3A4A4F);
  static const darkPrimaryText = Color(0xFF071719);

  static const lightSuccessSurface = Color(0xFFE5F3EA);
  static const darkSuccessSurface = Color(0xFF1D3B2C);
  static const darkSuccessText = Color(0xFF91D6AA);
  static const lightWarningSurface = Color(0xFFFFF1D9);
  static const darkWarningSurface = Color(0xFF49371D);
  static const darkWarningText = Color(0xFFFFD080);
  static const lightDangerSurface = Color(0xFFFBE8E7);
  static const darkDangerSurface = Color(0xFF482528);
  static const darkDangerText = Color(0xFFFFA3A6);
}

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
  );
  static const title = TextStyle(
    fontSize: 26,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const headline = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const subhead = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );
  static const bodySmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
}

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const section = 40.0;
  static const page = 48.0;
}

abstract final class AppRadius {
  static const small = 8.0;
  static const card = 8.0;
  static const medium = 12.0;
  static const large = 18.0;
  static const pill = 999.0;
}

abstract final class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x100E3438), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const darkCard = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

abstract final class AppIcons {
  static const add = CupertinoIcons.add;
  static const arrowRight = CupertinoIcons.arrow_right;
  static const back = CupertinoIcons.back;
  static const calendar = CupertinoIcons.calendar;
  static const check = CupertinoIcons.check_mark;
  static const close = CupertinoIcons.clear;
  static const error = CupertinoIcons.exclamationmark_circle;
  static const help = CupertinoIcons.question_circle;
  static const info = CupertinoIcons.info;
  static const lock = CupertinoIcons.lock;
  static const more = CupertinoIcons.ellipsis;
  static const notification = CupertinoIcons.bell;
  static const search = CupertinoIcons.search;
  static const success = CupertinoIcons.check_mark_circled_solid;
  static const warning = CupertinoIcons.exclamationmark_triangle;
}
