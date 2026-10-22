# Cursor AI Integration

Cursor supports two levels of rule configurations:
1. **`.cursorrules`**: Single root configuration file loaded automatically by Cursor.
2. **`.cursor/rules/*.mdc`**: Fine-grained, glob-targeted rules introduced in modern Cursor.

---

## 🚀 How to Install in Your Project

### Option A: Modern MDC Rules (Recommended)
Copy the `.mdc` files into your project's `.cursor/rules/` directory:
```bash
mkdir -p .cursor/rules
cp adapters/cursor/*.mdc .cursor/rules/
```

### Option B: Root `.cursorrules`
Copy `.cursorrules` to your project root:
```bash
cp adapters/cursor/.cursorrules .cursorrules
```
