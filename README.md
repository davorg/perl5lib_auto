# perl5lib_auto.sh

A Bash script that automatically sets the `PERL5LIB` environment variable when you `cd` into a directory containing a Perl project.

It scans for `lib/` directories containing `.pm` files, applies intelligent exclusions and limits, and sets or appends to `PERL5LIB` accordingly.

## ✅ Features

- Recursively scans for `lib/` directories under the current directory
- Includes only those containing `.pm` files
- Excludes common build/IDE directories and versioned-release folders
- Skips scanning when inside specific top-level directories (like `~/git`)
- Optionally limits how many `lib/` directories to include
- Supports dry-run mode and verbose debugging
- All behaviour is configurable via environment variables

## 🔄 Installation

Save the script somewhere convenient, for example:

```bash
mkdir -p ~/bin
curl -o ~/bin/perl5lib_auto.sh https://raw.githubusercontent.com/davorg/perl5lib_auto/main/perl5lib_auto.sh
chmod +x ~/bin/perl5lib_auto.sh
```

Then source it in your `~/.bashrc` or `~/.bash_profile`:

```bash
source ~/bin/perl5lib_auto.sh
```

Open a new terminal or run `source ~/.bashrc` to activate it.

## 🌍 Environment Variables

You can customise the script’s behaviour with the following environment variables:

| Variable                     | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `PERL5LIB_LIB_CAP`          | Max number of `lib/` dirs to include (default: `3`)                         |
| `PERL5LIB_FORCE`            | Set to `1` to override exclusions and cap                                   |
| `PERL5LIB_APPEND`           | Set to `1` to append to existing `PERL5LIB` rather than overwrite           |
| `PERL5LIB_VERBOSE`          | Set to `1` for debug output                                                 |
| `PERL5LIB_DRYRUN`           | Set to `1` to preview `PERL5LIB` without actually setting it                |
| `PERL5LIB_EXCLUDE_DIRS`     | Colon-separated absolute directory paths to skip entirely (default: `~/git`) |
| `PERL5LIB_EXCLUDE_PATTERNS` | Colon-separated substrings to filter out of matched `lib/` paths (default: `.vscode:blib`) |

## 🧪 Example Usage

```bash
PERL5LIB_VERBOSE=1 cd ~/projects/MyApp            # Show matched lib dirs
PERL5LIB_DRYRUN=1 cd ~/projects/MyApp             # Preview what would happen
PERL5LIB_FORCE=1 cd ~/git                         # Force scanning even if excluded
PERL5LIB_LIB_CAP=5 cd ~/src/BigProject            # Temporarily increase cap
```

## 🧼 Example Defaults

By default, the script behaves as if the following were set:

```bash
export PERL5LIB_LIB_CAP=3
export PERL5LIB_EXCLUDE_DIRS="$HOME/git"
export PERL5LIB_EXCLUDE_PATTERNS=".vscode:blib"
```

## 📜 License

MIT or similar — feel free to adapt for your own shell environment.
