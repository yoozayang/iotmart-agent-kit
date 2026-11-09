# iotmart-agent-kit

**English** | [繁體中文](README.zh-TW.md)

Coding-agent rules and skills for IoTMart 3.0. Codex, Claude Code and Gemini read the same rules and skills, installed into the project working tree and kept out of the company repository's version control.

## Install for team members (Windows / macOS)

No agent, git skills or admin rights needed.

1. Get the kit: `git clone https://github.com/yoozayang/iotmart-agent-kit.git`, or on the GitHub page click **Code → Download ZIP** and extract it
2. Double-click the installer:
   - Windows: `install-windows.cmd` (if "Windows protected your PC" appears, click **More info → Run anyway**)
   - macOS: right-click `install-mac.command` → **Open** (needed the first time only)
3. When the folder picker appears, choose your IoTMart project folder (the one containing `sfdx-project.json`); **Cancel** installs the skills to your user folder only
4. When "安裝完成" (installation complete) appears, press Enter, then restart Codex / Claude Code / Gemini

What the installer does:
- Copies the rules (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.codex/`) and skills (`.agents/skills`, `.claude/skills`) into the project and adds them to the project's `.git/info/exclude`
- Changed files are first moved to `~/.iotmart-agent-kit-backup/<timestamp>/`; identical files are left alone
- Removes the SF Guard installed by older versions: the `# iotmart-agent-kit sf guard` PATH lines in shell startup files, `~/.codex/rules/iotmart-sf-guard.rules`, `~/.iotmart-agent-kit/bin` and the project's `.codex/rules/sf-guard.rules`

To update: `git pull` (or download the ZIP again) and double-click the installer again. The same steps are in `INSTALL.txt` at the repository root.

The installer's on-screen messages are in Traditional Chinese.

## Architecture

```mermaid
flowchart TD
    A[AGENTS.md<br/>root control: hard constraints, Ponytail-first, routing entry] --> R[.codex/routing.md<br/>task routing table]
    C[CLAUDE.md] -->|bridge| A
    G[GEMINI.md] -->|bridge| A
    R --> K[.codex/knowledge<br/>stable background knowledge]
    R --> P[.codex/playbooks<br/>executable procedures and guardrails]
    R --> S[.codex/skills<br/>work-pattern templates]
    R --> O[.codex/playbooks/sf-skills-overlay.md<br/>overrides for official skills]
    O -->|overrides| F[.agents/skills/platform-*<br/>official sf-skills, unmodified]
    R --> E[.agents/skills/evidence-investigation-documentation<br/>own skill]
```

- Precedence: `AGENTS.md` > `.codex/playbooks` > official skills. When rules conflict, the stricter and more conservative one applies
- Official skills only provide knowledge and operating patterns and are never edited by hand; IoTMart-specific constraints live in the overlay

## Directory layout

```text
iotmart-agent-kit/
├── AGENTS.md                  root control layer, read directly by Codex
├── CLAUDE.md                  Claude Code bridge to AGENTS.md and .codex
├── GEMINI.md                  Gemini bridge
├── GIT_GUIDE.md               commit and PR conventions
├── skills-lock.json           skill sources and content hashes
├── review-skill-sources.json  upstream sources of the review skills (maintenance only)
├── .codex/
│   ├── config.toml            Codex MCP settings (Salesforce DX, context7, Notion)
│   ├── routing.md             task type -> files to read
│   ├── knowledge/             market architecture, system boundaries, SAP/SIS, repo map, environments, Salesforce review standards
│   ├── playbooks/             deploy, prod-validate, uat-compare, mcp-usage, git-baseline, magnolia-flow, sf-skills-overlay, code-review-overlay, wi-development-handoff
│   └── skills/                requirement-review, minimum-sdd, test-case-generation, validation-review, deployment-package
├── .agents/skills/            agent skills (own + third party)
├── .gemini/                   Gemini MCP settings and code review style
├── .mcp.json                  Claude Code project MCP settings
├── salesforce-mcp-config.json Salesforce hosted MCP endpoints
├── scripts/link.sh            maintainers: mount into a project with symlinks
├── scripts/install.ps1, install.sh  team members: install by copying
├── scripts/upstream/          risk scan for official skill updates
├── scripts/autoupdate.sh      maintainer's daily local auto-update (kit and personal tools)
├── scripts/install-autoupdate.sh  installs the local schedule
├── personal-tools.json        upstream and update method of personal tools
├── .github/workflows/         upstream-check schedule
├── install-windows.cmd        team member installer entry (Windows, runs scripts/install.ps1)
├── install-mac.command        team member installer entry (macOS, runs scripts/install.sh)
├── INSTALL.txt                install guide for non-technical users
├── THIRD_PARTY_NOTICES.md
└── LICENSES/
```

## Layers

| Layer | Location | Contains | Does not contain |
| --- | --- | --- | --- |
| Root control | `AGENTS.md` | hard constraints, Ponytail-first, routing entry | detailed procedures and file inventories |
| Routing | `.codex/routing.md` | which files to read per task type and layer baseline | rule bodies |
| Knowledge | `.codex/knowledge/*.md` | market architecture, system responsibility boundaries, domain background | operating steps |
| Procedures | `.codex/playbooks/*.md` | deploy, validate, compare, MCP usage and other executable procedures and guardrails | background explanations |
| Work patterns | `.codex/skills/*.md` | output formats for requirement review, SDD, test cases, validation review, deployment package | environment operations |
| Agent skills | `.agents/skills/*/SKILL.md` | own skills and third-party official skills | edits to third-party files |

## Maintainer install (symlink mode)

For people who edit and commit the kit directly; changes show up immediately in mounted projects.

```bash
git clone git@github.com:yoozayang/iotmart-agent-kit.git ~/Development/iotmart-agent-kit
cd ~/Development/iotmart-agent-kit

# project root has no files with the same names
scripts/link.sh ~/Development/IoTMart3.0

# project root already has real AGENTS.md, .codex etc.: move them to ~/codex_tmp/agent-kit-backup/ first, then link
scripts/link.sh ~/Development/IoTMart3.0 --replace

# also expose own skills to other projects (links into ~/.agents/skills/)
scripts/link.sh ~/Development/IoTMart3.0 --user-links

# also link every existing worktree, and auto-link worktrees created later
scripts/link.sh ~/Development/IoTMart3.0 --all-worktrees --hook
```

`link.sh`:
- creates symlinks in the project root for `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `GIT_GUIDE.md`, `skills-lock.json`, `.mcp.json`, `salesforce-mcp-config.json`, `.codex`, `.agents`, `.gemini`
- removes stale `.claude/settings.json` links left by the removed SF Guard
- creates `.claude/skills` -> `../.agents/skills` so Claude Code loads the skills natively
- adds those paths to the project's `.git/info/exclude`, so they never show up in the company repo's `git status`
- can be re-run; correctly linked items print `ok`
- `--all-worktrees` also links every existing worktree of the project; a worktree blocked by real files is reported and the others are still linked
- `--hook` installs a `post-checkout` hook in the project's repo, so a worktree created with `git worktree add` (including by an agent) is linked automatically; it is skipped when `core.hooksPath` is set or another `post-checkout` hook already exists

SF Guard has been removed; agents use the native `sf` CLI. Prod and Target Org authorization still follow `AGENTS.md` and `.codex/playbooks/prod-validate.md`. To clean up a maintainer machine, delete the lines ending in `# iotmart-agent-kit sf guard` from the shell startup files and remove `~/.codex/rules/iotmart-sf-guard.rules`; `command -v sf` should then print the native CLI path.

## How each environment reads the kit

| Environment | Rule entry | Skill loading |
| --- | --- | --- |
| Codex | `AGENTS.md` | scans `.agents/skills/` natively |
| Claude Code | `CLAUDE.md` -> `AGENTS.md` | scans `.claude/skills/` natively |
| Gemini | `GEMINI.md` -> `AGENTS.md` | reads `SKILL.md` via the paths in `GEMINI.md` and `routing.md` |

## Skills

### Own
| Skill | Purpose |
| --- | --- |
| `evidence-investigation-documentation` | evidence-led investigation and documentation workflow, including safe Notion update rules |
| `iotmart-code-review` | task-aware review of an implementation against its ADO work item, PR or branch |

### Third party
| Skill | Source | Purpose |
| --- | --- | --- |
| `platform-metadata-api-context-get` | forcedotcom/sf-skills | fields, directories, naming and sample XML for 604 Metadata API types |
| `platform-data-and-tooling-api-context-get` | forcedotcom/sf-skills | field definitions for 2130 standard and Tooling objects |
| `platform-metadata-retrieve` | forcedotcom/sf-skills | retrieve command patterns and flags |
| `platform-metadata-deploy` | forcedotcom/sf-skills | deploy/validate flag reference; agents deploy only through the playbook authorization flow |
| `platform-soql-query` | forcedotcom/sf-skills | writing and running SOQL |
| `platform-apex-test-run` | forcedotcom/sf-skills | Apex test execution and coverage |
| `code-review` | mattpocock/skills | primary review framework: separate Spec and Standards axes |
| `differential-review` | trailofbits/skills | security review, only for high-risk changes |

The official sf-skills were chosen from error statistics of past agent sessions (wrong SOQL fields or objects, non-existent CLI flags, malformed metadata members, etc.); details are on the Notion page "官方Agent Skill整合計畫".

## Optional personal tools

These tools are personal preferences. They are not in this repository and are not installed into projects by `link.sh` or the installers. Install them at user level if wanted (`scripts/autoupdate.sh` and `personal-tools.json` are for the maintainer's own machine):

| Tool | Purpose | Install | Notes |
| --- | --- | --- | --- |
| Ponytail | runs the Ponytail-first evaluation in `AGENTS.md` | Codex personal plugin (git clone at `~/.codex/plugins/ponytail`), updated by `scripts/autoupdate.sh` | optional; the checklist is built into `AGENTS.md` and works without the plugin |
| caveman skills | compressed output, subagent delegation | installed and updated by `scripts/autoupdate.sh` from `personal-tools.json` | `caveman-commit` writes Conventional Commits, which differ from `GIT_GUIDE.md`; `caveman-compress` rewrites the original file; `cavecrew` needs its own subagent definitions |

## Official skills and the overlay

The official skills are written for general use, and parts of them conflict with IoTMart's hard constraints, for example:
- `platform-metadata-deploy` shows `sf project deploy start --source-dir force-app`
- `platform-metadata-retrieve` offers `--ignore-conflicts`
- the default org is used when none is specified

These conflicts are not fixed in the official files. They are written in `.codex/playbooks/sf-skills-overlay.md`; `AGENTS.md` and the Task Routing Table require it before an official Salesforce skill is used. `CLAUDE.md` and `GEMINI.md` bridge to that shared path. When the official skills are upgraded, only the overlay needs to be re-checked.

Review skills follow the same pattern: `code-review` and `differential-review` stay unmodified, and IoTMart overrides (ADO WI as the spec, PR target or `origin/Dev` as the diff base, Salesforce standards and risk levels in `.codex/knowledge/salesforce-review-standards.md`, read-only output) live in `.codex/playbooks/code-review-overlay.md`. Reviews start from `iotmart-code-review`; `differential-review` runs only when the risk level is HIGH. `code-review-and-quality` (addyosmani/agent-skills) is kept as a source reference only. Pinned commits and tree SHAs are in `review-skill-sources.json`.

## Adding or updating skills

Third-party skills:

```bash
cd ~/Development/iotmart-agent-kit
npx skills add <owner>/<repo> -s <skill-name> -a codex -y   # add; writes .agents/skills and skills-lock.json
npx skills update -p -y                                     # update
```

Then:
1. Check the skill against the hard constraints in `AGENTS.md`; write any conflict into the overlay
2. If routing is needed, update `.codex/routing.md`
3. Update `THIRD_PARTY_NOTICES.md` and `LICENSES/`
4. Update the skill list in both READMEs (`README.md`, `README.zh-TW.md`)

Own rules:
- background knowledge goes in `.codex/knowledge/`, executable procedures in `.codex/playbooks/`, output templates in `.codex/skills/`, natively triggered skills in `.agents/skills/<name>/SKILL.md`
- add a Task Routing Table entry only when a new file must be loaded for a distinct task type; do not add static file inventories to `AGENTS.md`

## Upstream updates

Fully automatic, no manual step. Official skill files stay unmodified; repo hard constraints and Prod authorization come from `AGENTS.md` and `.codex/playbooks/sf-skills-overlay.md`.

| Target | Runner | Frequency | Action |
| --- | --- | --- | --- |
| official sf-skills (`.agents/skills/platform-*`) | GitHub Actions `upstream-check` | Mondays 09:00 Taipei | opens a PR when upstream changes and merges it automatically; the PR includes a change summary, a risk scan (`scripts/upstream/scan-risk.sh`) and an overlay reference check |
| maintainer's local kit clone | macOS LaunchAgent (`scripts/autoupdate.sh`) | daily 09:30 | `git pull --ff-only`; merged updates take effect in every mounted project |
| personal tools (`personal-tools.json`) | same | daily 09:30 | caveman: reinstalls the listed skills when upstream has a new commit; Ponytail: checks out the newest release tag |

- The only automatic gate: an official skill update may only change `.agents/skills/platform-*`, `skills-lock.json` and `THIRD_PARTY_NOTICES.md`; anything else fails the workflow (GitHub sends an email) and nothing is merged
- Local unpushed changes or modified tool folders are skipped, never overwritten
- A macOS notification appears on update or failure; log: `~/Library/Logs/iotmart-agent-kit-autoupdate.log`
- Roll back Ponytail with the `git -C ~/.codex/plugins/ponytail checkout <old version>` command recorded in the log
- Change which caveman skills are installed by editing `skills` in `personal-tools.json`
- Manual run: `gh workflow run upstream-check.yml`; `bash scripts/autoupdate.sh`
- Install the local schedule: `scripts/install-autoupdate.sh`; remove: `scripts/install-autoupdate.sh --remove`
- The repository must allow GitHub Actions to create pull requests (Settings → Actions → General → Workflow permissions)

## Notes

- This repository holds only agent rules and skills, never `force-app` or any company code
- In a project's `.git/info/exclude`, patterns with a trailing slash (such as `.agents/`) match real directories only, not symlinks; `link.sh` adds the slash-less form
- The Salesforce DX MCP does not enable the `metadata` toolset; retrieve, deploy and validate always go through the `sf` CLI and the playbook authorization flow
- Temporary output always goes to `~/codex_tmp`

## License

Sources and licenses of the third-party skills are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
