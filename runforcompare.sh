#!/bin/sh
# Run this against a build of gecko to collect data on what works or not
# Create a symlink from domains.txt to the file you want in order to prepare, e.g.:
#   $ ln -s pulse-domains-master.txt domains.txt

gecko="${1-../gecko-dev}"
input="${2-domains.txt}"

if ! [ -d "$gecko" ]; then
    echo "Usage: $0 [gecko-dev-dir]" 1>&2
    echo "       where [gecko-dev-dir] is a git repo with a build already available"
    exit 2
fi

if ! [ -r "$input" ]; then
    echo "Can't load input file '$input'" 1>&2
    exit 2
fi

objdir=$(cd "$gecko"; ./mach environment | sed '/config topobjdir/,+1 !d' | tail -1)
bin="${objdir}/dist/bin"
branch=$(cd "$gecko"; git branch 2>/dev/null | grep '*' | cut -c 3- -)
if [ -z "$branch" ]; then
    branch=$(cd "$gecko"; hg log -r tip --template "{node}\n" | cut -c 1-12 -)
fi
echo Running test against $(wc -l domains.txt) domains on $branch from $gecko
exec $bin/run-mozilla.sh $bin/xpcshell getXHRSSLStatus.js domains.txt \
    domains.$branch.errors domains.$branch.ev > domains.$branch.log 2>&1
