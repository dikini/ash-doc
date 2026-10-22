# Multilingual workflow pilot plan

Owning decision: multilingual documentation workflow, a bounded repository
decision drafted 2026-10-22 for approval. On approval, the roadmap records the
decision and links this plan while the pilot is active. The plan leaves the
tree when the pilot completes.

The pilot tests one claim: machine translation, with human review that may
lag, can carry ash-doc prose into Bulgarian while English revisions continue,
without semantic drift, without contradicting the English meaning, and without
destroying human corrections. Every executable claim still targets the pinned
FFI Base baseline at `354c76b391fe4af665cf6a03479a9874a57cb3e3`; the edition
remains unpublished. This plan defines no Ash semantics and no permanent
repository architecture.

## Reader and maintainer problem

- A beginner who does not read English comfortably cannot use the learning
  path at all today. The executable and diagnostic layer stays English under
  any plan; the gap is the prose.
- English lessons revise continuously — the Learn extension is in progress
  now. Any translation process must absorb English revisions without unbounded
  retranslation work, must survive scarce human corrections being applied
  late, and must keep every language semantically convergent with English and
  with each other.

## Authority and version boundaries

- English prose, canonical programs, and observations remain the source of
  truth. The pinned specification and tool govern every language claim in
  every language; a translation cannot define or soften an Ash boundary.
- Diagnostic captures stay byte-identical English, taken with
  `--message-format human --locale en`. No output the compiler owns is
  translated.
- A translation error is an ash-doc mistake, classified and corrected against
  the pinned sources. A systemic MT failure pattern is tooling pressure,
  recorded in a register and fixed in the glossary or prompt — not lesson by
  lesson.
- The MT engine is the codex CLI at a pinned version calling the pinned
  `gpt-6-luna` model: the one hosted dependency this decision approves, with
  lesson prose reaching no other third party. Outputs are checked-in
  artifacts and regeneration is an explicit recorded action, like the
  rendering toolchain's pins.

## Design

1. **Transplant, don't translate.** The pipeline segments a lesson
   mechanically at plain-prose boundaries. Fenced blocks (code, transcripts,
   diagrams), inline code, and Ash identifiers are transplanted byte-identical;
   only plain prose runs reach the MT. The executable-evidence layer stays
   single-language; every existing compiler, source-agreement, and transcript
   check runs once, in English, untouched by the translation machinery.
2. **Whole-file storage with per-lesson state.** A translation is a complete
   Markdown file beside the English one. A per-lesson state file records the
   review tier, the English source hash the translation claims, and the MT
   provenance (model, prompt, glossary hashes).
3. **Ownership tiers.** `mt-draft` — pipeline output, strict checks green, no
   human review. `reviewed` — a human certified it against the meaning core.
   `corrected` — human changes materially altered the prose; the lesson is
   promoted to human-owned and its corrections persist as overrides.
4. **Feedback classes absorbed at the highest tier.** Every human intervention
   is one of: a fidelity repair (translation diverged from English meaning —
   lesson override, or language glossary if the rule generalizes); a
   meaning-neutral improvement (proposal to the English lane); or a teaching
   insight (proposal to the English lane, verified against the pinned
   specification before acceptance). Unabsorbed generalized guidance
   re-creates its own feedback item on the next regeneration, so absorption at
   the highest applicable tier is the idempotence mechanism.
5. **Convergence contract.** One arbiter (the meaning core: spec-governed
   claims plus transplanted evidence), one writer per artifact, star-shaped
   sync — insights travel Lang → En → all Langs only, never peer-to-peer.
   The model is non-deterministic: no byte-reproducible regeneration is
   promised or needed. Instead, each convergence pass retranslates the
   current English into a fresh candidate, aligns it with the stored
   translation, and flags spans where the two disagree — including spans
   where a human edit conflicts with the model's current reading. That
   disagreement surface is the divergence report: rule-adjudicable classes
   (a glossary violation or transplant drift in the fresh text) resolve
   mechanically; every other flagged span goes to the human with the
   English, the stored text, and the fresh text side by side. The
   adjudication keeps the override, adopts the fresh reading, rewrites,
   or escalates to English as feedback. Quiescence — the machine-checkable
   fixed point — means no unadjudicated flagged spans and empty feedback
   queues. Non-contradiction is human-certified on exactly the flagged
   surface. Overrides are hash-keyed: when the English text under the key
   changes, the override demands re-review — silent re-application and
   silent dropping are both prohibited. Language-specific exceptions cover
   expression only; an exception that touches the claim is a proposal.
   Recorded artifacts, provenance, and adjudications make every decision
   auditable; auditability replaces reproducibility.
6. **Tiered honesty.** Reviewed lessons are certified against the meaning
   core; mt-draft lessons are certified for structure only — skeleton,
   transplants, glossary. Draft status appears in book chrome, never inside
   lesson prose.

## Compared approaches

<!-- markdownlint-disable MD013 -->

| Approach | Verdict |
| --- | --- |
| Whole-file parallel translations, drift reported by anchor alignment | Selected. No new authoring model; smallest replaceable choice. |
| Segment store with stable paragraph IDs (Gettext-style) | Deferred. Precise drift, but fragments the connected prose the writing skill requires and needs an assembly layer. Revisited only if per-lesson drift volume makes whole-file review unaffordable. |
| Hosted translation platform | Rejected for now. Conflicts with the no-hosted-service rule and knows nothing about executable evidence. Revisited only at publication with external translators. |
| Fork per language | Rejected. Divergent histories, merge pain at restructures, violates the single forward line. |

<!-- markdownlint-enable MD013 -->

MT is the production vehicle, not a drafting aid, because human review time is
the scarce resource; the strict guard layer substitutes for absent humans
until review arrives. **Cost of deferring the pilot:** translation work stays
impossible to schedule, and every future English lesson lands as untranslated
debt.

## Pilot scope

- **Lessons:** Learn 1–3 — `what-is-an-ash-program`,
  `using-another-source-file`, `using-more-than-one-input`. The arc includes
  one complete rejection episode; the three share the Learn path's diagnostic
  conventions.
- **Language:** Bulgarian. Cyrillic script exercises the full design,
  including font and repagination work.
- **MT runtime:** codex CLI with the pinned `gpt-6-luna` model, recorded in
  the manifest; a local quantized model is the recorded fallback.
- **Book policy:** mt-draft chapters render with a visible status notice in
  book chrome (HTML, EPUB, and both PDFs); never in lesson prose.
- **Out of scope:** translated lessons do not enter family indexes or active
  navigation — AGENTS.md admits only verified units there; any index presence
  is a separate post-pilot decision. The two continuation lessons, other
  families, and a second language are excluded.

## Files

The pilot adds no repository root; shared pieces live under the existing
`content/checks/` root, lesson pieces beside their lesson.

```text
content/checks/translation/
  glossary-bg.md            pinned terminology: never-translate terms,
                            approved renderings
  manifest.json             engine identity (codex CLI version, model id),
                            prompt template and glossary hashes, output-hash
                            records
  pipeline.py               segmentation, MT call, assembly, provenance
                            writing, and the convergence-pass comparison
                            (Python standard library)
  sync.sh                   drift, quiescence, skeleton, glossary, and
                            transplant checks for all translated lessons
content/learn/<lesson>/
  README.bg.md              the translated chapter
  checks/translation.json   tier, claimed English hash, provenance,
                            adjudications
  checks/divergence.json    flagged spans with English, stored, and fresh
                            text; written by each convergence pass
  translation/overrides.json   present only after promotion; hash-keyed
                            human corrections
```

Rendering adds a `--lang` selection to `rendering/build.py` scoped builds and
a chapter-status mechanism in the shared chrome. Diagram glyphs are
identifier-derived and stay transplanted, so only prose faces need Cyrillic
coverage; the style contract change is a micro-design inside step 5.

## Verification

Strict, machine-run for every translated lesson:

- skeleton identity: headings, anchors, and block order match English;
- transplanted blocks byte-identical to the English source;
- zero glossary violations;
- the drift marker names the English state the translation claims, and the
  divergence report is empty or fully adjudicated;
- feedback queues empty (quiescence).

Semantic, human, incremental: a convergence pass flags the spans where the
stored and fresh readings disagree; certification renews only on flagged
spans, and the tier, the certified surface, and the adjudications are
recorded in `checks/translation.json`.

Rendering: the Bulgarian scoped builds for the three lessons pass the existing
artifact and browser checks in HTML and A4 PDF, the draft notice is visible in
each format, and repagination-sensitive checks (wide blocks, note placement)
run against the Bulgarian text.

## Completion conditions

The pilot is complete only when all hold:

1. Lessons 1–3 translate to at least `mt-draft` with all strict checks green.
2. A deliberate English prose edit to lesson 2 triggers a convergence
   pass whose divergence report names exactly the changed section.
3. A human correction on lesson 1 promotes the lesson; regeneration does not
   clobber the correction; the override is hash-keyed and persists.
4. The glossary check fires at least once as a negative control.
5. The scoped Bulgarian book builds in HTML and A4 PDF with the draft notice
   visible and passing artifact and browser checks.
6. Quiescence holds after exercises 2–4: queues empty, every flagged span
   adjudicated.
7. The review owner signs the tiered-honesty wording and sets the human
   review effort budget for any continuation.

## Progress record

Steps 1-3 and 5 have landed. The decision is recorded in the roadmap;
the glossary carries the coinage rule born of review, with къринг as its
first application; the pipeline translates, checks, compares, and
converges; Learn 1-3 are mt-draft with strict checks green. Step 5:
TeX Gyre Pagella has no Cyrillic (the current CTAN release was checked
too), so PT Serif (OFL, Cyrillic-first, 0401-04FF coverage verified)
is the Bulgarian body face. `--lang` renders translated lesson scopes
with a translation-check pre-flight, a blockquote draft notice visible
in HTML and both PDFs, and PT Serif in the HTML theme and the patched
project-local Typst partial. All three lessons pass artifact checks in
HTML and A4 PDF; lesson 3 renders its three split figures from
transplanted notation. Step 6: the convergence loop fired on a real
English edit and named the changed span exactly amid heavy model jitter
(a second fresh run flagged a different jitter set, fixing batch
adjudication as the normal mode); lessons 1-2 then took real owner
corrections (imperative exercise heading, на ръка phrasing), promoted to
human-owned, and their wording survived fresh machine passes through
keep-stored adjudication - including one fresh grammatical regression
the adjudication rejected. Step 4 is complete: the review owner read all
three chapters on the rendered preview, applied the terminology
rulings, promoted two corrections, verified the translated figure
captions, and certified the chapters - lessons 1-2 at tier corrected,
lesson 3 at tier reviewed with its draft notice dropped from the
render. Figure captions and descriptions translate through the pipeline
since the owner's preview finding; only the generated book chrome
(landing, reader setup) stays English, deferred as a rendering-scope
choice. EPUB was not exercised in the pilot builds. Remaining: the step
7 pilot review.

## Continuation

The step 7 review selected continue. The pilot extends across the
remaining Learn lessons on this branch (4-15: choosing-a-result through
the two continuation chapters), with the machinery unchanged and
certification at the review owner's pace. The glossary grows to v1
first: curriculum terms named in the new lessons enter Approved only
when they are ordinary Bulgarian vocabulary, everything else enters
Provisional for the owner to confirm or reject in batches. Each lesson
lands as mt-draft with strict checks green; the volatile
working-with-text lesson translates like any other, flagged as the
English lesson is. Chapters render through the same --lang scopes.
Remaining after translation: batch review of the Provisional table and
per-lesson certification.

## Execution order

1. Approval of this design; roadmap records the decision and links this plan;
   glossary `bg` v0 seeds from the three lessons' terminology.
2. Pipeline prototype on lesson 1; the glossary and transplant checks must
   fail planted violations.
3. Translate lessons 1–3 to `mt-draft`; `sync.sh` green.
4. Semantic pass: the review owner certifies lesson 1 (the rejection episode)
   first, per the diagnostic-adjacent-prose-first triage; tiers recorded.
5. Rendering micro-design: confirm TeX Gyre Pagella Cyrillic coverage and
   select an approved face if absent; `--lang` selection; chrome notice;
   scoped HTML and A4 PDF builds; artifact and browser checks.
6. Loop exercises: the lesson 2 convergence pass after an English edit
   (condition 2) and the lesson 1 promotion event (condition 3); quiescence
   checked after each.
7. Pilot review: record observations against this plan; decide continue
   (extend across the Learn part), revise (segment store or different model,
   by manifest revision with recorded output-diff review), or stop and remove
   the machinery.

## Deferred decisions

- A local pinned quantized model as the MT engine; trigger: escalation away
  from the hosted engine, decided at the pilot review or on availability
  changes. The RTX 4050's 6 GB VRAM fits 4B-class Q4 weights with context
  headroom; 7-8B fits only with CPU offload at markedly lower Bulgarian
  quality and speed.
- A dedicated `translation/` root, if the tooling outgrows `content/checks/`;
  trigger: a second language or pipeline features the checks directory cannot
  express.
- Segment-level authoring stores; trigger: drift volume whole-file reports
  cannot make affordable.
- Hosted platforms; trigger: publication with external translators.
- Index presence for translated lessons; trigger: a verified translation a
  family owner elects to publish.

## Replacement and removal

Replace the whole-file store only by a recorded design with the same
authority boundaries. Replace the MT model only by manifest revision plus
review of the recorded output diff. Remove all translation machinery if the
pilot cannot reach an acceptable review tier within the approved effort
budget; removal restores the tree to English-only content and leaves this
plan in Git history.
