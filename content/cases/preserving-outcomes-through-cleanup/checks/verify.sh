#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"

readonly sources=(
    src/01-success.ash
    src/02-primary-failure.ash
    src/03-nested-reports.ash
    src/04-cancellation.ash
    src/05-unreported-close.ash
    src/06-abortive-collector.ash
    src/07-resuming-collector.ash
    src/batch.ash
    src/reporting.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

# These expected values are application examples, independent of the Ash run.
# Full constructors retain categories, order, body outcomes and executed prefixes.
readonly success='Report(Execution(Success(5), Next(Add(2), Next(Add(3), End))), NoFailures)'
readonly empty='Report(Execution(Success(0), End), NoFailures)'
readonly rejected='Report(Execution(Failed(RejectedCommand(7)), Next(Add(2), Next(Reject(7), End))), NoFailures)'
readonly errors='FailureItem(AuditFailed(22), FailureItem(SummaryFailed(11), NoFailures))'
readonly nested_success="Report(Execution(Success(5), Next(Add(2), Next(Add(3), End))), $errors)"
readonly nested_rejected="Report(Execution(Failed(RejectedCommand(7)), Next(Add(2), Next(Reject(7), End))), $errors)"
readonly cancelled="Report(Execution(Failed(CancelledBatch), Next(Add(2), End)), $errors)"
readonly report_type='Report<Execution, CompletionError>'
readonly decision_type='Decision'

ash_doc_run_accepted "$unit_root" src/01-success.ash \
    "(($success, Accepted(5)), ($empty, Accepted(0))) : (($report_type, $decision_type), ($report_type, $decision_type))"
ash_doc_run_accepted "$unit_root" src/02-primary-failure.ash \
    "($rejected, PrimaryFailed(RejectedCommand(7))) : ($report_type, $decision_type)"
ash_doc_run_accepted "$unit_root" src/03-nested-reports.ash \
    "(($nested_success, CompletionFailed(AuditFailed(22)), 21), ($nested_rejected, PrimaryFailed(RejectedCommand(7)), 21)) : (($report_type, $decision_type, Int), ($report_type, $decision_type, Int))"
ash_doc_run_accepted "$unit_root" src/04-cancellation.ash \
    "($cancelled, PrimaryFailed(CancelledBatch), 21) : ($report_type, $decision_type, Int)"
ash_doc_run_accepted "$unit_root" src/05-unreported-close.ash \
    "($success, Accepted(5), FailureItem(SummaryFailed(11), NoFailures)) : ($report_type, $decision_type, Failures<CompletionError>)"
ash_doc_run_accepted "$unit_root" src/07-resuming-collector.ash \
    'Report(42, FailureItem(AuditFailed(22), FailureItem(SummaryFailed(11), NoFailures))) : Report<Int, CompletionError>'

# Check the causal source relationships behind abandonment and the wrong action.
# Output comparisons alone would not establish which work lies after the request.
python3 - "$unit_root" <<'PY'
from pathlib import Path
import sys

unit = Path(sys.argv[1])
batch = (unit / 'src/batch.ash').read_text()
addition = batch.split('run_from (total, Next(Add(amount), later)) = {', 1)[1].split('\n}', 1)[0]
assert addition.count('run_from(total + amount, later)') == 1
assert 'Execution(outcome, executed)' in addition
assert 'outcome, Next(Add(amount), executed)' in addition
rejection = batch.split('run_from (total, Next(Reject(code), later)) = {', 1)[1].split('\n}', 1)[0]
assert 'run_from' not in rejection
assert 'Execution(Failed(RejectedCommand(code)), Next(Reject(code), End))' in rejection
cancel = (unit / 'src/04-cancellation.ash').read_text()
prefix = 'Batch.Next(Batch.Add(2), Batch.End)'
request = 'let cancelled = perform Cancel.now prefix'
sentinel = 'let suffix_reached = Cell.write(action_trace, 9)'
suffix = 'Batch.run(Batch.Next(Batch.Add(3), Batch.End))'
assert cancel.index(prefix) < cancel.index(request) < cancel.index(sentinel) < cancel.index(suffix)
replacement = 'Batch.Execution(Batch.Failed(Batch.CancelledBatch), prefix)'
assert cancel.index('let closed = discard') < cancel.index(replacement)
assert 'let report = Reporting.collect(calculation)' in cancel
for entry in ('03-nested-reports.ash', '04-cancellation.ash'):
    source = (unit / 'src' / entry).read_text()
    summary = source.split('let summary = fn(ignored) {', 1)[1].split('\n    }', 1)[0]
    audit = source.split('let audit = fn(ignored) {', 1)[1].split('\n    }', 1)[0]
    for action, tag, error in ((summary, '1', 'SummaryFailed(11)'), (audit, '2', 'AuditFailed(22)')):
        assert action.count('Cell.write(action_trace,') == 1
        assert f'(Cell.read action_trace) * 10 + {tag}' in action
        assert action.index('Cell.write(') < action.index('Reporting.report_close(')
        assert error in action
    assert source.count('Cell.write(') == (3 if entry == '04-cancellation.ash' else 2)
wrong = (unit / 'src/05-unreported-close.ash').read_text()
action = wrong.split('forget_summary ignored = {', 1)[1].split('\n}', 1)[0]
assert 'Reporting.CloseFailed(Reporting.SummaryFailed(11))' in action
assert 'Reporting.report_close' not in action and 'perform ' not in action
assert '\n    ()\n' in action + '\n'
PY

ash_doc_run_rejected "$unit_root" src/06-abortive-collector.ash 1
ash_doc_check_human "$unit_root" src/06-abortive-collector.ash "$content_root/cases"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_finish "${#sources[@]}"
