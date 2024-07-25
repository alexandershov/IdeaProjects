import argparse
import os
from pathlib import Path


class PyGitError(Exception):
    pass


def find_git_dir(p: Path) -> Path:
    while True:
        candidate = p / ".git"
        if candidate.is_dir():
            return candidate
        if p == p.parent:
            break
        p = p.parent
    raise PyGitError("can't find .git directory")


def get_head(git_dir: Path) -> str:
    head_dir = git_dir / "HEAD"
    content = head_dir.read_text().rstrip("\n")
    assert content.startswith("ref: ")
    ref = content.removeprefix("ref: ")
    return ref.split("/")[-1]


def branch_command(args):
    git_dir = find_git_dir(Path.cwd())
    heads_dir = git_dir / "refs" / "heads"
    cur_branch = get_head(git_dir)
    branches = os.listdir(heads_dir)
    branches.sort(key=lambda br: br == cur_branch, reverse=True)
    for b in branches:
        if b == cur_branch:
            prefix = "* "
        else:
            prefix = "  "
        print(f"{prefix}{b}")


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    parser_branch = subparsers.add_parser('branch')
    parser_branch.set_defaults(func=branch_command)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
