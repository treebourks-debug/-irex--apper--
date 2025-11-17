# Contributing to TIREX SAPPER

Thank you for your interest in contributing to TIREX SAPPER! This document provides guidelines and information for contributing to the project.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub with:
- Clear description of the bug
- Steps to reproduce
- Expected behavior vs actual behavior
- MetaTrader 5 version
- Symbol and timeframe used
- Configuration parameters
- Screenshots or logs if applicable

### Suggesting Enhancements

We welcome suggestions for new features or improvements:
- Create an issue with detailed description
- Explain the use case and benefits
- Provide examples if possible
- Consider implementation complexity

### Code Contributions

1. **Fork the repository**
   ```
   Fork the project on GitHub
   Clone your fork locally
   ```

2. **Create a branch**
   ```
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards (see below)
   - Write clear, documented code
   - Test your changes thoroughly
   - Update documentation if needed

4. **Commit your changes**
   ```
   git commit -m "Add feature: description"
   ```

5. **Push to your fork**
   ```
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Explain testing performed

## 📝 Coding Standards

### MQL5 Code Style

- **Indentation**: Use 3 spaces (MQL5 standard)
- **Naming conventions**:
  - Functions: PascalCase (e.g., `CalculateLotSize`)
  - Variables: camelCase (e.g., `currentPrice`)
  - Global variables: g_ prefix (e.g., `g_symbol`)
  - Input parameters: Inp prefix (e.g., `InpRiskPercent`)
  - Constants: UPPER_CASE (e.g., `MAX_RETRIES`)

- **Comments**:
  - Use `//---` for section separators
  - Document all functions with purpose and parameters
  - Comment complex logic
  - Use English for comments

- **Function structure**:
  ```mql5
  //+------------------------------------------------------------------+
  //| Function description                                              |
  //+------------------------------------------------------------------+
  ReturnType FunctionName(parameters)
  {
     //--- Implementation
     return value;
  }
  ```

### Best Practices

1. **Error Handling**
   - Check return values
   - Validate input parameters
   - Handle edge cases
   - Log errors appropriately

2. **Performance**
   - Minimize indicator calculations
   - Reuse buffers where possible
   - Avoid unnecessary loops
   - Cache frequently used values

3. **Testing**
   - Test on demo account first
   - Backtest on historical data
   - Test edge cases
   - Verify on multiple symbols/timeframes

4. **Documentation**
   - Update README if adding features
   - Document configuration changes
   - Update CHANGELOG
   - Add examples if appropriate

## 🧪 Testing Guidelines

### Before Submitting

1. **Compilation**
   - Code must compile without errors
   - No warnings if possible

2. **Functionality**
   - Test new features thoroughly
   - Verify existing features still work
   - Test on multiple scenarios

3. **Backtesting**
   - Run strategy tester
   - Check for errors in logs
   - Verify results are logical

4. **Code Quality**
   - Remove debug code
   - Clean up commented-out code
   - Check for memory leaks
   - Validate resource cleanup

## 🔍 Pull Request Checklist

Before submitting your PR, ensure:

- [ ] Code compiles without errors
- [ ] Follows coding standards
- [ ] Includes appropriate comments
- [ ] Documentation updated if needed
- [ ] CHANGELOG updated
- [ ] Tested on demo account
- [ ] No breaking changes (or clearly documented)
- [ ] Commits have clear messages
- [ ] PR description explains changes

## 📋 Types of Contributions

We appreciate various types of contributions:

### Code
- Bug fixes
- New features
- Performance improvements
- Code refactoring
- Test coverage

### Documentation
- README improvements
- Code comments
- Configuration examples
- Usage guides
- Translation

### Testing
- Bug reports
- Test scenarios
- Backtest results
- Optimization findings

### Community
- Answering questions
- Helping other users
- Sharing configurations
- Writing tutorials

## 🚫 What Not to Contribute

Please don't submit:
- Untested code
- Code that doesn't compile
- Proprietary or copyrighted material
- Malicious code
- Low-quality or spam contributions

## 📧 Communication

- Use GitHub Issues for bugs and features
- Be respectful and constructive
- Provide context and details
- Follow up on your contributions

## 🏆 Recognition

Contributors will be recognized in:
- CHANGELOG
- GitHub contributors list
- Special thanks in documentation

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You

Your contributions help make TIREX SAPPER better for everyone. We appreciate your time and effort!

---

*Happy Trading and Coding!*
