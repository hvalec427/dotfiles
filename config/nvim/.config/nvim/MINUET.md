# minuet-ai.nvim

## New machine setup

```sh
security add-generic-password -a "$USER" -s ANTHROPIC_API_KEY -w "sk-ant-..."
```

Restart terminal/Neovim.

## Keymaps

| Key     | Action                      |
| ------- | ---------------------------- |
| `Alt-A` | Accept whole suggestion      |
| `Alt-a` | Accept current line          |
| `Alt-z` | Accept N lines                |
| `Alt-[` | Prev suggestion               |
| `Alt-]` | Next suggestion / trigger     |
| `Alt-e` | Dismiss                       |
