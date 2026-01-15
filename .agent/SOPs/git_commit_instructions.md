### 📦 COMMIT CONVENTIONS

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification, enforced automatically by `commitlint`.

#### 📀 Commit Format

> ⚠️ The commit message must be no longer than **120 characters** in the first line.

```txt
<type>(optional scope): <short message>

[blank line]

[detailed description if necessary]
```

#### ✅ Valid Examples

```txt
feat: add login page
fix(auth): fix logout flow bug
docs: update README documentation
refactor(core): improve folder structure
style: format code with Prettier
test: add tests for button component
chore: update dependencies
```

#### ❌ Invalid Examples

```txt
"code tweaks"
"final commit"
"bug fixed"
"update"
```

---

### 🧩 Supported Types

| Type       | Description                                    |
| ---------- | ---------------------------------------------- |
| `feat`     | New feature                                    |
| `fix`      | Bug fix                                        |
| `docs`     | Documentation changes                          |
| `style`    | Code style changes (spacing, formatting, etc.) |
| `refactor` | Code refactoring (no behavior changes)         |
| `test`     | Adding or modifying tests                      |
| `chore`    | Build tasks, CI, dependencies, etc.            |
| `perf`     | Performance improvements                       |
| `ci`       | CI/CD pipeline or config changes               |
| `build`    | Changes affecting the build system             |

---

### 📌 Recommendations

* Use **imperative present tense**: "add", "fix", "remove".
* Use a `scope` in parentheses if the change affects a specific part of the project.
* Avoid vague messages like "tweaks", "updates", or "fixes".

---

### ✅ Automatically Validated

All commits are validated using [`commitlint`](https://github.com/conventional-changelog/commitlint). Commits that do not follow the pattern will be rejected.
