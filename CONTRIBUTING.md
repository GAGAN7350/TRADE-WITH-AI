# Contributing to Trade With AI

Thank you for your interest in contributing to Trade With AI! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/TRADE-WITH-AI.git
   cd TRADE-WITH-AI
   ```
3. **Set up Firebase** by following the instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## Development Workflow

### 1. Create a Branch

Create a new branch for your feature or bug fix:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Your Changes

- Write clean, readable code
- Follow the existing code style
- Add comments where necessary
- Update documentation if needed

### 3. Test Your Changes

Before submitting your changes:

```bash
# Run the analyzer
flutter analyze

# Run tests
flutter test

# Test on different platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

### 4. Commit Your Changes

Write clear, concise commit messages:
```bash
git add .
git commit -m "Add feature: description of your changes"
```

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Submit a Pull Request

- Go to the original repository on GitHub
- Click "New Pull Request"
- Select your branch
- Fill in the PR template with details about your changes
- Submit the PR

## Code Style Guidelines

### Dart/Flutter Code

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Keep functions small and focused
- Use meaningful variable and function names
- Add documentation comments for public APIs

### File Organization

```
lib/
├── models/          # Data models
├── screens/         # UI screens/pages
├── services/        # Business logic and API calls
├── widgets/         # Reusable widgets
└── utils/           # Utility functions
```

### Naming Conventions

- **Files**: Use snake_case (e.g., `user_profile.dart`)
- **Classes**: Use PascalCase (e.g., `UserProfile`)
- **Variables/Functions**: Use camelCase (e.g., `userName`, `getUserData()`)
- **Constants**: Use lowerCamelCase (e.g., `defaultTimeout`)

## Firebase Integration

### Security Rules

When adding new Firestore collections or Storage paths:

1. Update security rules in Firebase Console
2. Document the rules in a comment in your PR
3. Test the rules before submitting

### API Keys

- **Never commit** API keys or sensitive credentials
- Use environment variables or Firebase configuration files
- Ensure all sensitive files are listed in `.gitignore`

## Testing

### Unit Tests

Add unit tests for:
- Data models
- Service classes
- Utility functions

Example:
```dart
test('TradePosition calculates profit correctly', () {
  final position = TradePosition(
    id: '1',
    userId: 'user1',
    symbol: 'AAPL',
    type: 'buy',
    quantity: 10,
    entryPrice: 100,
    exitPrice: 110,
    status: 'closed',
    createdAt: DateTime.now(),
  );
  
  expect(position.profitLoss, equals(100.0));
});
```

### Widget Tests

Add widget tests for UI components:
```dart
testWidgets('HomeScreen displays welcome message', (tester) async {
  await tester.pumpWidget(MaterialApp(home: HomeScreen()));
  expect(find.text('Welcome to Trade With AI'), findsOneWidget);
});
```

## Pull Request Guidelines

### PR Title

Use descriptive titles with prefixes:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for code style changes
- `refactor:` for code refactoring
- `test:` for adding tests
- `chore:` for maintenance tasks

Examples:
- `feat: Add real-time stock price updates`
- `fix: Resolve authentication timeout issue`
- `docs: Update Firebase setup instructions`

### PR Description

Include:
1. **Summary** of changes
2. **Motivation** - why is this change needed?
3. **Changes Made** - bullet points of key changes
4. **Testing** - how you tested the changes
5. **Screenshots** (if UI changes)

### Code Review

- Respond to review comments promptly
- Make requested changes in new commits
- Don't force-push after reviews (makes it hard to track changes)
- Once approved, maintainers will merge your PR

## Reporting Issues

When reporting bugs:

1. **Check existing issues** to avoid duplicates
2. **Use the issue template** if available
3. **Include details**:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots (if applicable)
   - Device/platform information
   - Flutter version (`flutter --version`)

## Feature Requests

For feature requests:

1. **Check existing issues** first
2. **Describe the feature** clearly
3. **Explain the use case** - why is it needed?
4. **Suggest implementation** (optional)

## Community Guidelines

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Provide constructive feedback
- Stay on topic in discussions
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md) (if available)

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Firebase Setup Guide](FIREBASE_SETUP.md)

## Questions?

If you have questions about contributing:

1. Check the [README](README.md) and [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
2. Search existing issues
3. Open a new issue with your question

Thank you for contributing to Trade With AI! 🚀
