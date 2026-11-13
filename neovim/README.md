# Neovim Setup

The config is a work in progress. Most of it is commented out and is turned on step by step.

## Monokai Pro compared to VS Code

The goal is for Neovim to look like the Monokai Pro theme in VS Code. The colors are the same in both. Some differences remain because the two editors color code in different ways.

The checks covered TypeScript, Python, CSS, HTML, JSON, Markdown, and Bash. The theme file used was the official Monokai Pro extension, version 2.0.17.

### Fixed with overrides

These overrides are in `lua/plugins/monokai-pro.lua`.

- `async` is pink and italic.
- Hint diagnostics are purple.
- The selected item in the completion menu uses the background `#5b595c`.
- The matching bracket has a gray background instead of yellow text.
- CSS class selectors are green, ID selectors are orange, and pseudo classes and pseudo elements are teal and italic.
- HTML: the `=` in attributes is gray, entities such as `&amp;` are purple, and link text is plain white.
- Markdown: block quotes are italic.

### Known differences

These cannot be fixed with a simple override. The same highlight group covers tokens that VS Code colors differently. A fix needs a custom Tree-sitter query.

- **Brackets:** VS Code colors bracket pairs by nesting depth (pink, orange, yellow, green, cyan, purple). Neovim colors all brackets pink. A rainbow brackets plugin would fix this.
- **`const`, `let`, `var`:** These are teal and italic in VS Code. In Neovim they are pink and italic, like `extends`.
- **`console`:** This is teal and italic in VS Code. In Neovim it is gray and italic, like `this` and `super`.
- **`${` in template strings:** This is pink in VS Code and gray in Neovim. The `?` in optional TypeScript properties shares the same group, so an override would turn `?` pink too.
- **CSS values:** Words such as `none`, `no-repeat`, and `sans-serif` are teal in VS Code and white in Neovim. A color such as `#fff` is purple in VS Code and yellow in Neovim.
- **HTML `class` and `id` values:** These are green and orange in VS Code. In Neovim they are yellow, like all strings.

### Not checked or not clear

- **Bash:** It is not clear how VS Code colors some tokens, such as `return` and uppercase variables like `NAME`. Nothing was changed.
- **Markdown inline code and link labels:** The theme file has no clear rule for them. Nothing was changed.
- **Semantic highlighting:** VS Code also colors code with information from language servers. Neovim will not match this until LSP is set up.
- **Other languages:** Only the languages listed above were checked.
