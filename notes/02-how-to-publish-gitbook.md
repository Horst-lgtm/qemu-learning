# 如何发布到 GitBook

可以把本仓库笔记做成可浏览的书籍站点。推荐先本地预览，再绑定 GitHub/GitLab 做 GitBook Cloud 同步。

## 本仓库采用的结构

经典 GitBook / HonKit 风格：

| 文件 | 作用 |
| --- | --- |
| `SUMMARY.md` | 目录（左侧导航） |
| `book.json` | 书名、语言等元数据 |
| `README.md` | 书籍首页 |
| `notes/`、`experiments/` | 正文与实验说明 |

新增笔记时：先写 Markdown，再在 `SUMMARY.md` 里加一条链接即可。

## 本地预览（推荐先做）

需要本机已安装 Node.js（建议 LTS）。在仓库根目录：

```bash
npm run serve
```

或直接：

```bash
npx --yes honkit serve .
```

浏览器打开终端提示的本地地址（通常是 `http://localhost:4000`）。

生成静态站点：

```bash
npm run build
```

输出目录为 `_book/`（已被 `.gitignore` 忽略）。

Windows PowerShell 也可使用：

```powershell
.\scripts\preview-book.ps1
```

## 发布到 GitBook Cloud（官方常见方式）

GitBook 官方当前更常用 **Git Sync**：把 GitHub 或 GitLab 仓库与 GitBook 空间绑定，推送 Markdown 后自动同步，而不是把 token 写进仓库。

建议步骤：

1. 将本仓库推到 GitHub 或 GitLab（**不要**包含 `gittoken`、`.env` 等密钥文件）。
2. 打开 [GitBook](https://www.gitbook.com/)，创建 Space / Docs。
3. 在 Integrations / Git Sync 中选择 GitHub 或 GitLab，授权并选择本仓库。
4. 指定同步的分支（如 `main`）以及内容根目录（本仓库为根目录，已有 `SUMMARY.md`）。
5. 推送笔记更新后，等待 GitBook 同步完成，再在 GitBook 侧配置公开/私有访问。

若你的 GitBook 工作区要求「根目录为 `docs/`」，可二选一：

- 在 Git Sync 设置里把 content root 指到仓库根；或
- 把 `SUMMARY.md`、`book.json` 与笔记移入 `docs/`（需同步改路径）。当前骨架默认用仓库根，更简单。

## Token 与安全

- `gittoken`、`.env`、各类 `*.token` **只放本机**，已写入 `.gitignore`。
- **不要**把 token commit、push 进 Git。
- 若将来用 GitBook API、CI 或 CLI，把 token 放在环境变量或系统密钥库，例如：

```powershell
$env:GITBOOK_TOKEN = Get-Content .\gittoken -Raw
# 仅在当前终端会话使用；不要 echo / 不要写入脚本仓库
```

```bash
export GITBOOK_TOKEN="$(tr -d '\r\n' < ./gittoken)"
# 仅用于本地受控命令；不要打印完整值
```

- Git Sync 走 OAuth/应用授权时，通常**不需要**把个人 token 放进仓库。
- 若不慎提交过 token：立刻在平台吊销并轮换，再从 Git 历史中清除该文件。

## 可选：不装 Node 的极简浏览

若暂时只想在编辑器或 Git 托管页面读笔记，直接打开 `SUMMARY.md` 按链接浏览即可；`npm run serve` 只是为了获得书籍式侧栏预览。

## 检查清单

- [ ] `SUMMARY.md` 已包含新笔记链接
- [ ] `git status` 中看不到 `gittoken` / `.env`
- [ ] 本地 `npm run serve` 可打开目录
- [ ] 远程仓库已绑定 GitBook Git Sync
- [ ] 未把任何 token 写入 README、脚本或 CI 明文配置
