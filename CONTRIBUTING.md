# Contributing to Finpin

First off, thank you for considering contributing to Finpin! It's people like you that make Finpin such a great tool for travelers and students.

## Code of Conduct

By participating in this project, you are expected to uphold our values of respect, inclusivity, and collaboration.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Device and iOS version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use case** - Why is this enhancement important?
- **Proposed solution** - How should it work?
- **Alternatives considered** - What other solutions did you consider?

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Follow the existing code style
3. Add tests if applicable
4. Update documentation as needed
5. Ensure the app builds without errors
6. Issue that pull request!

## Development Setup

1. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/finpin.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Set up API keys** (optional)
   - Copy `APIConfig.swift.template` to `APIConfig.swift`
   - Add your API keys (never commit this file!)

4. **Make your changes**
   - Write clean, readable code
   - Follow SwiftUI best practices
   - Add comments for complex logic

5. **Test thoroughly**
   - Test on different screen sizes
   - Test with and without API keys
   - Check for memory leaks

## Style Guide

### Swift Style

- Use descriptive variable names
- Follow Swift naming conventions
- Keep functions small and focused
- Use `// MARK: -` comments to organize code
- Prefer `let` over `var` when possible

### Git Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Keep first line under 50 characters
- Reference issues and pull requests

Examples:
- `Add AI budget advisor feature`
- `Fix map tap gesture recognition`
- `Update README with API setup instructions`

### SwiftUI Best Practices

- Extract complex views into separate components
- Use `@StateObject` for view models
- Use `@EnvironmentObject` for shared state
- Keep views lightweight
- Use preview providers for development

## Project Structure

```
Views/          # SwiftUI views
Models/         # Data models
Services/       # API and business logic
Extensions/     # Swift extensions
Sheets/         # Modal sheet views
```

## Areas for Contribution

### High Priority
- [ ] Data persistence with SwiftData/CoreData
- [ ] Offline mode support
- [ ] Widget extension
- [ ] Export functionality (PDF/CSV)

### Nice to Have
- [ ] Apple Watch companion app
- [ ] Siri shortcuts
- [ ] AR features for landmarks
- [ ] Social sharing features

### Bug Fixes
- Check the [Issues](https://github.com/yourusername/finpin/issues) page

## Questions?

Feel free to open an issue with the tag "question" or reach out to the maintainers.

## Recognition

Contributors will be recognized in:
- README.md contributors section
- In-app credits (future feature)
- Release notes

Thank you for helping make Finpin better! 🎉
