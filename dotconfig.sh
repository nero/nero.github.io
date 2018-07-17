#!/bin/sh
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$HOME/.run/$HOSTNAME}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
UPSTREAM=https://github.com/nero/etc.git

fail() {
	echo "FAIL: $1" >&2
	exit 1
}

hash git >/dev/null 2>&1 || fail "git not installed"

# Setup the checkout directory itself
mkdir -p "$XDG_CONFIG_HOME" || fail "Unable to create config dir"
cd "$XDG_CONFIG_HOME"
if ! [ -d .git ]; then
	git init || fail "Unable to init repo"
	git remote add origin "$UPSTREAM"
	git config branch.master.remote origin
	git config branch.master.merge refs/heads/master
	git fetch --all || fail "Unable to fetch data"
	git reset --hard origin/master
else
	git pull --ff-only || fail "Pull failed"
fi

./deploy.sh
