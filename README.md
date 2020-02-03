# kvault - Keep Encrypted Textual Data

This is meant to be a single-file way to keep encrypted notes. It should work
as a place to keep passwords and whatnot, too. The encrypted data is stored as
a JSON file and it is possible to access only parts of that data at a time. It
is meant to be a fairly low-level program, to be wrapped by more user-friendly
scripts, functions or aliases.

This is mostly based off of the password example from the
[Cryptography documentation](https://python-docs.readthedocs.io/en/latest/scenarios/crypto.html)'s
example for password storage. Since I know essentially nothing about
encryption, hopefully that example is not too far off the mark.

The unencrypted data, while it exists, is stored in `/tmp` with `0600` permissions,
as far as I can tell (I used the `tempfile` module), so it's safe to use on
personal machines and not at all on shared systems where others have root
access. Only the bits of the vault the user wants access are put in this file;
the rest stays in memory.

The encryption relies on two parts: a salt and a password. The salt should be
long and random according to
[this article](https://en.wikipedia.org/wiki/Salt_(cryptography)), although the
software doesn't try to enforce this (that is, the user can set it to `''`). For
that matter, the user can set the password to `''`, too. Setting either to `''` is
likely a bad idea; setting both to `''` makes using this utility more or less
pointless. From what I understand, picking a good salt and keeping it secret
makes up for a weak password.

In the vault, the data is stored as a JSON, but it is presented to the user as
TOML which is a bit more human-friendy to edit. The `--which`/`-w` argument can
descend into the tree represented by the JSON/TOML to some arbitrary degree so
that all of the potentially-sensitive information isn't displayed at once.

## Usage - The Short Version

Create a password entry for a website. The data store is essentially a tree,
and the `--which`/`-w` parameter pulls out a subtree to operate on. That subtree is
converted to TOML and `--action`/`-a` is an action to be applied to that TOML data.

I probably wouldn't use `ed` as an editor in practice, but this way the entire
example is self-contained. Omitting `--action`/`-a` will default to `$EDITOR` or
`nano`.

```
$ kvault -v vault --new-with-salt-of-size 64 --action cat
New Password:
Repeat Password:
$ kvault -v vault -w www.website.com --action 'ed -p ">> "'
Password:
0
>> a
user='name'
pass='very_secret'
.
>> w
31
>> q
$ kvault -v vault --action cat
Password:
["www.website.com"]
user = "name"
pass = "very_secret"
$ kvault -v vault --action cat -w www.website.com pass
Password:
very_secret
$ ./kvault -v vault --action 'xclip <' -w www.website.com pass
Password:
$ xclip -o
very_secret
```

## Usage - The Long Version

To make a new vault with a random 64-byte salt, something like this could be
done, where omiting the action argument would open a text editor to allow
initializing the vault:

```
$ kvault --new-with-salt-of-size 64 --v vault --action cat
New Password:
Repeat Password:
$ ls vault vault.salt
vault  vault.salt
$ cat vault
gAAAAABeN0ZlYQ9fwJfzDqPrew4JujDNCzz_eIDHxSE4tFBmi9lde_EEwaE7OwHTRPJQCU6uf_4JWDf5SPrfm-e6yjUtPNZstg==\
$ cat vault.salt
8b45b00a8ef4da95d095cc29afa5a6c48815d2363d0b0d2a3a5ac45b6fa39293a0e1a008759602cf5e5cb78de1e63c1cbb3b17b3fb53c72e7943e32d869bf9a1
```

Similarly, with some arbitrary string the user now needs to remember because it
will not be saved by default (but can be with `--new-salt-path`):

```
$ kvault --new-with-salt 'some, ideally random, long string that you need to remember' -v vault -a cat
```

To change the password of an existing vault, but with the same salt. The action
is largely immaterial again, but `'<'` alone doesn't seem to do anything in BASH
(unlike `'>'` which will wipe out all data in the file, which feels like
something I should probably add a check for at some point; then again, BASH
hasn't in decades):

```
$ kvault -v vault --new-with-salt-path vault.salt --action '<'
Password:
New Password:
Repeat Password:
```

To get data out of a vault. Change the action to `vim` or similar or leave it
out to edit that data. Some clipboard helper can be used to interact with the
clipboard, e.g., `'xclip -i <'` to copy to clipboard and `'xclip -o >'` to paste
from the clipboard.

```
$ kvault -v vault -a cat
Password:
["www.website.com"]
user = "name"
pass = "secret"
$ kvault -v vault -a cat -w www.website.com
Password:
user = "name"
pass = "secret"
./kvault -v vault -a cat -w www.website.com pass
Password:
secret
```

As a specific example, generate a password and put it in the clipboard:

```
$ kvault -v vault -w www.website.com pass -a 'xkcdpass >'
Password:
$ kvault -v vault -w www.website.com pass -a 'xclip <'
Password:
$ xclip -o
suffix imitate unpiloted unpaid alibi greyhound
```

or just do it all in one go:

```
$ kvault -v vault -w www.website.com pass -a 'xkcdpass | tee {} | xclip'
Password:
misho@calliope ~/git/kvault ‹master*› ⋙  xclip -o
tarantula browbeat coziness clamshell superman filled
$ kvault -v vault -w www.website.com pass -a cat
Password:
tarantula browbeat coziness clamshell superman filled
```
