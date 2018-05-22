# Repo Auditor Tool

This repo contains two tools:

1. fetch_repo_archives.sh
2. audit_repo_archive.sh
3. find_case_insensitive_conflicts_in_archives.sh

## fetch_repo_archives.sh

    usage: fetch_repo_archives.sh [-b <branch>] -c <cachedir> [repourl [repourl...]]

`fetch_repo_archives.sh` downloads gzipped tar archives of the current state of the specified branch or `master` to the specified cache directory, ready for further analysis later.

## audit_repo_archive.sh

    usage: audit_repo_archive.sh -a <archive> <command> [cmdarg [cmdarg...]]

`audit_repo_archive.sh` temporarily extracts the specified archive, switches the working directory to this temporary location and runs your command with your arguments in that working directory. When done, the temporary working directory is deleted, so if you want to persist data from your tool, make sure to specify an absolute path.

## find_case_insensitive_conflicts_in_archives.sh

    usage: find_case_insensitive_conflicts_in_archives.sh [archive [archive...]]

`find_case_insensitive_conflicts_in_archives.sh` scans archives for files which are different on case sensitive systems, but which cannot be analysed on a case insensitive filesystem.

## Examples

Assuming you have a text file, `repos.txt`, with a list of all the repos you want to audit, e.g.:

    git@github.com:kaldor/repo_auditor.git
    git@github.com:kaldor/bitbucket_deploy_key_util.git

If you use [`bitbucket_deploy_key_util list_repos > repos.txt`][bitbucket_deploy_key_util] to generate your list of repos, you may want to run the following to prepend `git@bitbucket.org:` and append `.git` to the list it generates:

    sed -i "" "s/^/git@bitbucket.org:/" repos.txt
    sed -i "" "s/$/.git/" repos.txt

You can download them all, four at a time, to a cache folder, `cache`, like so:

    cat repos.txt | xargs -P 4 -n 1 fetch_repo_archives.sh -c cache

Once you have all the archives downloaded, you can run any utility you want against the archives using `audit_repo_archive.sh`.

---

For instance let's say you have a tool for finding sensitive information, `find_keys.sh` in your current directory, and you have downloaded archives of all the repos you want to audit to a cache directory, `cache`:

    for archive in cache/*.tgz; do
        audit_repo_archive.sh -a "$archive" $(pwd)/find_keys.sh
    done

**Nota bene** the potential need for `$(pwd)` ahead of the tools name if you refer to it relatively. `audit_repo_archive.sh` executes its command using the temporarily extracted archive as current working directory.

---

If on the other hand the repo itself, contains a `test.sh` tool you would like to run, you should refer to it relatively, as it will be run relative to the repo:

    for archive in cache/*.tgz; do
        audit_repo_archive.sh -a "$archive" ./test.sh
    done

[bitbucket_deploy_key_util]: https://github.com/kaldor/bitbucket_deploy_key_util