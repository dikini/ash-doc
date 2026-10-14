"""Check the closed source excerpts and output selections taught by this Case."""
import ast
from pathlib import Path
import re
import sys

MARKER = re.compile(r'<!-- (excerpt|observation): ([^\s]+#[a-z_]+) -->')
DECLARATION = re.compile(r'^(?:pub )?[a-z_]+ :', re.MULTILINE)


def fragments(sources):
    result = {}

    def add(file, name, text):
        result[f'src/{file}#{name}'] = text.strip('\n')

    def section(file, name, first, last):
        text = sources[file]
        start = text.index(first)
        end = text.index(last, start) if last else len(text)
        add(file, name, text[start:end])

    def operation(file, name):
        text = sources[file]
        matches = [m for m in DECLARATION.finditer(text)
                   if m[0].removeprefix('pub ').startswith(name + ' :')]
        if len(matches) != 1:
            raise ValueError(f'canonical source must have one {name} signature')
        start = matches[0].start()
        end = next((m.start() for m in DECLARATION.finditer(text) if m.start() > start), len(text))
        signature, body = text[start:end].strip('\n').split('\n', 1)
        add(file, name + '_type', signature)
        return body

    file = 'dictionaries.ash'
    section(file, 'frames', 'type FrameStack<K, V> =', 'pub opaque type Iterator<K, V> =')
    section(file, 'iterator_data', 'pub opaque type Iterator<K, V> =', 'pub interface Order<A> {')
    add(file, 'iterator', operation(file, 'iterator'))
    body = operation(file, 'next').split('\n', 1)
    add(file, 'next_empty', body[0])
    add(file, 'next_frame', body[1])
    body = operation(file, 'push_left').split('\n', 1)
    add(file, 'push_empty', body[0])
    add(file, 'push_node', body[1])

    file = '01-sequence.ash'
    section(file, 'imports', 'import dictionaries as Dictionaries', '\n\n')
    for name in ('collect', 'is_finished'):
        add(file, name, operation(file, name))
    operation(file, 'main')
    section(file, 'keys', '    let one =', '    let empty_dictionary')
    section(file, 'entries', '    let entries =', '    let dictionary =')
    section(file, 'empty', '    let empty_dictionary', '    let entries =')
    section(file, 'finish', '    let dictionary =', '\n}')

    file = '02-retained-state.ash'
    section(file, 'replay_data', 'type ReplayObservation =', 'replay :')
    add(file, 'replay', operation(file, 'replay'))
    operation(file, 'main')
    section(file, 'entries', '    let entries =', '    replay (')
    section(file, 'finish', '    replay (', '\n}')
    return result


def observations(captures):
    parts = {}
    arities = dict(Next=1, More=2, Replay=3, Iterator=1, MoreFrame=4, Node=5, Some=2)
    names = {'true', 'false', 'Zero', 'End', 'NoFrame', 'Empty', 'Red', 'Black'}

    def parse(name, expected_type):
        capture = captures[name]
        if not capture.endswith('\n') or len(capture.splitlines()) != 1:
            raise ValueError('expected one complete captured result line')
        value, _, actual_type = capture.rstrip('\n').rpartition(' : ')
        if actual_type != expected_type:
            raise ValueError(f'{name}: unexpected captured type')
        tree = ast.parse(value, mode='eval').body

        def validate(node):
            if isinstance(node, ast.Tuple):
                for child in node.elts:
                    validate(child)
            elif isinstance(node, ast.Call):
                if not isinstance(node.func, ast.Name) or node.keywords:
                    raise ValueError('unsupported captured constructor')
                if node.func.id not in arities or len(node.args) != arities[node.func.id]:
                    raise ValueError('unexpected captured constructor shape')
                for child in node.args:
                    validate(child)
            elif isinstance(node, ast.Name) and node.id in names:
                pass
            elif isinstance(node, ast.Constant) and type(node.value) is int:
                pass
            else:
                raise ValueError('unsupported captured value')

        validate(tree)
        parts[name + '#type'] = actual_type
        return tree, lambda node: ast.get_source_segment(value, node)

    tree, text = parse('sequence', '(Bool, List<(Natural, Int)>)')
    if not isinstance(tree, ast.Tuple) or len(tree.elts) != 2:
        raise ValueError('sequence must contain the empty flag and list')
    parts['sequence#empty'] = text(tree.elts[0])
    current = tree.elts[1]
    for name in ('one', 'two', 'three'):
        if not isinstance(current, ast.Call) or current.func.id != 'More':
            raise ValueError('sequence must contain three More entries')
        parts['sequence#' + name] = text(current.args[0])
        current = current.args[1]
    if not isinstance(current, ast.Name) or current.id != 'End':
        raise ValueError('sequence must end after the third entry')
    parts['sequence#end'] = text(current)

    tree, text = parse('retained-state', 'ReplayObservation')
    if not isinstance(tree, ast.Call) or tree.func.id != 'Replay':
        raise ValueError('retained result must contain three Replay fields')
    for name, field in zip(('saved', 'first', 'second'), tree.args):
        parts['retained-state#' + name] = text(field)
    return parts


def verify(document, sources, captures):
    expected = {'excerpt': fragments(sources), 'observation': observations(captures)}
    seen = set()
    lines = document.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        match = MARKER.fullmatch(line)
        if match:
            kind, key = match.groups()
            if key not in expected[kind]:
                raise ValueError(f'unknown {kind}: {key}')
            if (kind, key) in seen:
                raise ValueError(f'duplicate {kind}: {key}')
            seen.add((kind, key))
            i += 1
            while i < len(lines) and not lines[i].strip():
                i += 1
            if i == len(lines) or lines[i] != '```text':
                raise ValueError(f'{kind}: {key} must introduce a text fence')
            start = i + 1
            i = start
            while i < len(lines) and lines[i] != '```':
                i += 1
            if i == len(lines):
                raise ValueError('unterminated selection fence')
            if '\n'.join(lines[start:i]) != expected[kind][key]:
                raise ValueError(f'{kind}: {key} differs from canonical content')
        elif '<!--' in line and re.search(r'\b(excerpt|observation)\b', line):
            raise ValueError('malformed display marker')
        elif line.startswith('```'):
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                i += 1
        i += 1
    missing = {(kind, key) for kind, values in expected.items() for key in values} - seen
    if missing:
        raise ValueError(f'missing display selections: {sorted(missing)}')
    return len(expected['excerpt']), len(expected['observation'])


if __name__ == '__main__':
    root = Path(__file__).resolve().parents[1]
    try:
        count = verify((root / 'README.md').read_text(),
                       {p.name: p.read_text() for p in (root / 'src').glob('*.ash')},
                       {name: (root / f'fixtures/{name}.stdout').read_text()
                        for name in ('sequence', 'retained-state')})
    except (ValueError, SyntaxError) as error:
        sys.exit(str(error))
    print(f'Verified {count[0]} source excerpts and {count[1]} result selections.')
