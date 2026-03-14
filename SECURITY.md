# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.3.x   | :white_check_mark: |
| < 0.3   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Skribble, please report it
responsibly:

1. **Do not** open a public issue.
2. Email the maintainers at **security@openbudget.fun** with:
   - Description of the vulnerability
   - Steps to reproduce
   - Impact assessment
3. You will receive an acknowledgement within **48 hours**.
4. A fix will be developed and released as a patch version.

## Scope

Skribble is a client-side Flutter UI library. It does not handle
authentication, network requests, or sensitive data storage. Security
concerns are primarily around:

- Dependency vulnerabilities (transitive packages)
- Denial of service via malformed input to drawing routines
- XSS in rendered text (when used in Flutter Web)

Thank you for helping keep Skribble safe.
