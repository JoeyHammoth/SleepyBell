# 🌟 Contributing to SleepyBell

Thank you for considering contributing to **SleepyBell**! 🎉  
We appreciate your time and effort in improving the project. The following guidelines will help you get started.

---

## 📜 Table of Contents

1. [💡 How to Contribute](#💡-how-to-contribute)
2. [🐛 Reporting Bugs](#🐛-reporting-bugs)
3. [🎯 Requesting Features](#🎯-requesting-features)
4. [🛠 Setting Up the Development Environment](#🛠-setting-up-the-development-environment)
5. [🚀 Submitting a Pull Request](#🚀-submitting-a-pull-request)
6. [📏 Code Style Guidelines](#📏-code-style-guidelines)
7. [✅ Testing Your Changes](#✅-testing-your-changes)
8. [📝 Commit Message Guidelines](#📝-commit-message-guidelines)
9. [🤝 Code of Conduct](#🤝-code-of-conduct)

---

## 💡 How to Contribute

There are several ways you can contribute to SleepyBell:

- **Fix bugs** 🐞
- **Improve documentation** 📖
- **Suggest or implement new features** 🚀
- **Optimize code and performance** ⚡
- **Help with testing and debugging** 🛠
- **Share feedback** 💬

---

## 🐛 Reporting Bugs

If you find a bug, please open an issue following this template:

1. **Title:** A short description of the bug.
2. **Description:** A clear and concise explanation of the issue.
3. **Steps to Reproduce:** Provide a step-by-step guide to reproduce the issue.
4. **Expected Behavior:** What should have happened?
5. **Actual Behavior:** What actually happened?
6. **Screenshots (if applicable):** Attach screenshots to clarify the problem.
7. **Device & OS:** Mention the iOS version and device model.

**Example:**
```markdown
### Bug: Alarm does not trigger after app restart

**Description:** The alarm fails to ring if the app is restarted before the scheduled time.

**Steps to Reproduce:**
1. Set an alarm for 10 minutes from now.
2. Restart the app before the alarm triggers.
3. Wait for the alarm time to arrive.

**Expected Behavior:** The alarm should ring at the scheduled time.
**Actual Behavior:** The alarm does not ring.

**Device & OS:** iPhone 13, iOS 17.0
```

---

## 🎯 Requesting Features

To request a new feature, open an issue with the following details:

- **Feature Description:** What do you want to add?
- **Why is it useful?**
- **Possible Implementation:** Any ideas on how to implement it?
- **Screenshots or Examples (if applicable)**

---

## 🛠 Setting Up the Development Environment

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/JoeyHammoth/SleepyBell.git
   cd SleepyBell
   ```

2. **Open in Xcode:**  
   Open `SleepyBell.xcodeproj` in Xcode (13+ recommended).

3. **Install Dependencies (if applicable):**  
   ```sh
   pod install  # If CocoaPods is used
   ```

4. **Run the App in the Simulator:**  
   - Select an iOS simulator.
   - Press `Cmd + R` to build and run.

---

## 🚀 Submitting a Pull Request

1. **Fork the Repository**  
   Click the "Fork" button on the top right of the repository page.

2. **Create a Branch**
   ```sh
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**  
   - Follow the coding style and best practices.
   - Keep commits focused and logical.

4. **Test Your Changes**  
   Ensure the app runs correctly after your modifications.

5. **Commit and Push Your Changes**
   ```sh
   git commit -m "Add feature: Your feature description"
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**  
   - Go to your forked repository.
   - Click "New Pull Request."
   - Select the `main` branch of the original repository as the base branch.
   - Add a clear title and description of your changes.
   - Submit the PR for review.

---

## 📏 Code Style Guidelines

To maintain consistency, follow these guidelines:

- **SwiftLint Compliance:** Run `swiftlint` before submitting a PR.
- **Indentation:** Use 4 spaces per indentation level.
- **Variable Naming:** Use camelCase for variables and PascalCase for class names.
- **Function Documentation:** Use inline comments and `///` for function descriptions.
- **Avoid Force Unwrapping (`!`)** – Always use optional binding (`if let` or `guard let`).

---

## ✅ Testing Your Changes

Before submitting a pull request:

1. **Run the app and test it manually** in different scenarios.
2. **Write unit tests** for new features (if applicable).
3. **Ensure all tests pass** using:
   ```sh
   Cmd + U  # Runs unit tests in Xcode
   ```

---

## 📝 Commit Message Guidelines

- **Use Present Tense:** `"Add feature"`, not `"Added feature"`
- **Keep Messages Concise:** `"Fix bug in alarm system"`
- **Reference Issues (if applicable):**  
  ```sh
  git commit -m "Fix alarm bug (#12)"
  ```

---

## 🤝 Code of Conduct

We expect contributors to follow these guidelines:

1. **Be Respectful:** Constructive criticism is welcome, but personal attacks are not.
2. **Stay on Topic:** Keep discussions relevant to the project.
3. **Help Others:** If you see a question you can answer, feel free to help!
4. **No Spam:** Avoid irrelevant or repetitive messages.

By contributing to this project, you agree to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 🎉 Thank You!

Your contributions make **SleepyBell** better for everyone. ❤️  

If you have any questions, feel free to reach out by opening an issue or joining the discussions. Happy coding! 🚀
