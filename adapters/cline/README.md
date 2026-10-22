# Cline & Roo Code Integration

This adapter supports both [Cline](https://github.com/cline/cline) and [Roo Code](https://github.com/RooVetGit/Roo-Code).

---

## 🚀 Setup

1. For **Cline**:
   Copy `.clinerules` to your project root:
   ```bash
   cp adapters/cline/.clinerules .clinerules
   ```

2. For **Roo Code**:
   Copy both `.clinerules` and `.roomodes` to your project root:
   ```bash
   cp adapters/cline/.clinerules .clinerules
   cp adapters/cline/.roomodes .roomodes
   ```
   Roo Code will expose two specialized modes in the UI dropdown:
   - **Frappe Developer**: for code, DocTypes, bench commands, APIs.
   - **Frappe Course Architect**: for authoring curricula and lessons in Arabic.
