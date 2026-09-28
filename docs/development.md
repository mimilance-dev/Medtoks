# Development

## Prerequisites

Use Flutter 3.32.8 (Dart 3.8.x), Git, and Melos 7.1.0. Android builds require Android SDK tooling. iOS and macOS builds require macOS and Xcode; Windows desktop builds require Windows. Linux/cloud development containers can run Dart tooling and Flutter web builds but cannot produce Apple or Windows platform builds.

## Bootstrap and Checks

From the repository root:

```sh
dart pub global activate melos 7.1.0
melos bootstrap
melos run format
melos run analyze
melos run test
```

The Dart pub workspace is declared in root `pubspec.yaml`; Melos discovers apps and packages from `melos.yaml`. Shared package dependencies are local path dependencies. Run commands for one app from its own directory, for example:

```sh
cd apps/mentor
flutter run -d chrome
flutter test
flutter build web --release
```

Mentee's Dart application source is ready, but generated Android/iOS host projects are not checked in. CI creates temporary hosts with Flutter 3.32.8 and builds Android and iOS; it does not commit that generated boilerplate. On a machine with Flutter installed, add native host scaffolding with `cd apps/mentee && flutter create --platforms=android,ios --project-name medtoks_mentee .` and review generated changes before committing. This operation should be done once with the pinned SDK. Mentor's web host is included; generate Windows/macOS hosts on their respective operating systems when those targets are needed.

## Conventions

Keep composition, routing, and app configuration in their app. Put reusable domain contracts and models in their owning `medtoks_*` package. Keep provider clients in infrastructure packages and inject abstractions into features. Do not commit generated code until a package deliberately adopts code generation. Do not commit `.env`, privileged credentials, build output, or machine-specific configuration.

The devcontainer installs the pinned Flutter SDK and Melos and bootstraps the workspace. The container does not include Android Studio, Xcode, or Windows build tooling.
