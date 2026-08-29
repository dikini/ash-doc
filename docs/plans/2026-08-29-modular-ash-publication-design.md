# Modular Ash Publication Design

## Reader question

How can a reader or downstream evidence record identify the reviewed beginning
learning path as one durable Ash documentation edition?

The observable boundary lies between verified source on ash-doc `main` and an
immutable repository source snapshot that names both its documentation identity
and the exact Ash behavior it teaches.

## Decision

Publish the reviewed beginning path directly from the ash-doc repository with
an annotated Git tag named `modular-ash`. The documentation tag uses the exact
name of its target Ash milestone tag. The two tags are repository-local: the
`ash-lang` tag resolves to the language and tool commit, while the `ash-doc` tag
resolves to the documentation source commit.

Record this matching-name rule in the repository workflow and agent guidance.
Identify the published documentation tag, Ash milestone, and resolved Ash
commit in the repository README and roadmap. Repository-hosted Markdown remains
the first edition's readable publication surface.

Create the tag only after the final publication commit is clean and all
publication checks pass. Push `main` and the tag atomically so readers cannot
observe the published tag without its governing source commit. Never move or
reuse the published tag.

## Alternatives

### Annotated repository-source tag

An annotated tag gives readers and downstream evidence an immutable source
identity without adding a renderer or publication dependency. Existing
Markdown remains readable through repository browsing, and every runnable
example remains adjacent to its canonical source and checks. This is the
selected approach.

### Tag plus repository release page

A release page could add discovery text and downloadable source archives. It
would select a second publication surface whose content and update rules the
project would need to verify. The source tag already supplies the durable
identity required by this increment, so a release page adds no necessary
observation.

### Rendered documentation build

A generated site could control navigation and presentation. It would also
select a renderer, output format, hosting mechanism, and verification boundary
before a concrete reader problem requires them. A future presentation may
consume the immutable tag without changing it.

Deferring publication entirely would leave the reviewed path without a stable
edition reference and prevent downstream evidence from naming one immutable
ash-doc snapshot.

## Authority and version boundary

The edition teaches `modular-ash` at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The specification at that commit
governs language claims. The pinned implementation, tests, and tool guide
govern executable observations. The ash-doc tag identifies documentation; it
does not define Ash behavior or retarget the edition.

Current `ash-lang/main` remains future pressure. The next roadmap outcome may
run an exact-commit compatibility canary, but that observation will not change
the published pin or begin a forward migration.

## Publication state

The final tagged tree will:

- identify `modular-ash` as both the documentation tag and target Ash milestone
  tag;
- retain `dca16039923475c48025c5f17beadeb6bcb6a4bf` as the resolved Ash commit;
- state that the first repository-source edition is published;
- retain the reviewed eleven-lesson path and its local executable evidence;
- select a bounded exact-commit compatibility canary as the next roadmap
  outcome; and
- contain no completed publication plans.

The tag annotation will name the documentation edition, Ash milestone, and
resolved Ash commit. The tag object itself identifies the exact ash-doc source
commit.

## Failure handling

Before publication, stop if `modular-ash` already exists locally or remotely,
the branch is not based on current `origin/main`, a required check fails, or
the final tree is dirty. Correct the source and repeat the complete
verification instead of weakening a check.

Use an atomic push for `main` and `refs/tags/modular-ash`. If the remote rejects
the push, retain the local branch and diagnose the rejection before retrying.
An unpushed local tag may be recreated only while no remote publication exists.
After the remote accepts the tag, do not move or delete it as part of ordinary
project work. A discovered publication error requires a separately approved
forward correction.

## Verification

- Run all eleven lesson verifiers against a clean Ash checkout at
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`.
- Check Bash syntax for the shared helper and all lesson verifiers.
- Run `markdownlint-cli2` over repository Markdown outside `.worktrees/`.
- Check every changed relative link and read every changed file as source.
- Confirm that no runnable Ash block or canonical source changed.
- Run `git diff --check` and inspect the final status and commit.
- Confirm that local and remote `modular-ash` tags were absent before
  publication.
- After the push, resolve the remote annotated tag and confirm that it points
  to the verified publication commit.

## Replacement and migration condition

Keep the source-only publication model while repository browsing presents the
edition coherently. A future bounded design may add a renderer or release page
when a concrete reader or maintainer need justifies it; that presentation must
consume the immutable tag rather than replace it.

A future Ash edition uses the exact name of its own Ash milestone tag in
ash-doc. Forward migration moves `main` to one exact new Ash commit and
publishes a new immutable matching-name tag only after the intended coverage is
coherent. It never moves `modular-ash`.

## Exclusions

This publication adds no renderer, release page, publication platform,
manifest, registry, coverage view, CI service, dependency, license, lesson
entry rename, language topic, canary implementation, or forward migration. It
does not change lesson prose, Ash programs, executable observations, or the
authority of any Ash artifact.
