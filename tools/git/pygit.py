import argparse
import os
import zlib
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


def cat_file_command(args) -> None:
    git_dir = find_git_dir(Path.cwd())
    object_id = args.object_id
    prefix = object_id[:2]
    suffix = object_id[2:]
    object_dir = git_dir / "objects" / prefix
    if not object_dir.exists():
        raise PyGitError(f"object {object_id} does not exist")
    matches = [path for path in object_dir.iterdir() if path.name.startswith(suffix)]
    if not matches:
        raise PyGitError(f"object {object_id} does not exist")
    if len(matches) > 1:
        conflicts = [m.name for m in matches]
        raise PyGitError(f"ambiguous object id {object_id}: {conflicts}")
    compressed_content = matches[0].read_bytes()
    content = zlib.decompress(compressed_content)
    header, body = content.split(b"\x00", maxsplit=1)
    kind, size_str = header.split()
    assert int(size_str) == len(body)
    if kind == b"tree":
        print_tree(body)
    else:
        # blob and commit stores their content in body
        print(bytes_to_ascii(body))


def print_tree(content):
    # tree's content is
    # <mode> <name>\x00<binary-sha-1>
    # <mode> <name>\x00<binary-sha-1>
    # ...
    while content:
        mode_and_name, content = content.split(b"\x00", maxsplit=1)
        mode, name = mode_and_name.split(b" ", maxsplit=1)
        sha_1_len = 20
        sha_1 = content[:sha_1_len].hex()
        content = content[sha_1_len:]
        print(f"{bytes_to_ascii(mode)} {sha_1} {bytes_to_ascii(name)}")


def bytes_to_ascii(b):
    return b.decode("ascii", errors="ignore")

def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    branch_parser = subparsers.add_parser('branch')
    branch_parser.set_defaults(func=branch_command)

    cat_file_parser = subparsers.add_parser('cat-file')
    cat_file_parser.add_argument('-p', action='store_true', required=True)
    cat_file_parser.add_argument('object_id')
    cat_file_parser.set_defaults(func=cat_file_command)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
