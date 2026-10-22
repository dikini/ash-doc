# Bulgarian translation glossary

Pinned terminology for the multilingual workflow pilot, seeded 2026-10-22
from Learn 1-3 (`what-is-an-ash-program`, `using-another-source-file`,
`using-more-than-one-input`). Consumers: the MT prompt template and the
glossary check in the translation sync script.

This file pins wording, not meaning. Meaning stays with the English lesson
and the pinned specification at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`; a glossary entry can never
widen, narrow, or soften what the English lesson teaches.

An entry that claims an established Bulgarian rendering must carry its
source. An unverified claim is a coinage and belongs in Provisional
choices for the review owner to confirm or reject.

## Coinage rule

When no established Bulgarian rendering exists for a concept a lesson
must name, the project coins one: transliterate the English term
phonetically under Bulgarian orthographic convention — /ˈkʌri/ gives
*къринг*, with ъ for English /ʌ/. The coinage enters Provisional choices;
on the review owner's approval it moves to Approved renderings with the
decision and date recorded, and each lesson's first mention carries a
brief inline note tying the coinage to the English term. A coinage
returns to review if later evidence establishes a different Bulgarian
rendering or the owner reopens the decision.

## Transplant rule

Anything inside a fenced block, inline code span, or diagnostic transcript
is transplanted byte-identical; the MT pipeline never sees it. The
never-translate list below covers strings that can also appear in plain
prose and must pass through unchanged there.

## Never translate

<!-- markdownlint-disable MD013 -->

- Keywords: `main`, `pub`, `import`, `as`, `let`
- Builtins and types: `Unit`, `Int`, `Bool`, `String`, `Bytes`, `<function>`
- Syntax tokens: `()`, `->`
- Commands and flags: `ash`, `ash program.ash`, `ash main.ash`,
  `--message-format human`, `--locale en`
- Reason codes: `entry.missing-main`, `resolve.unavailable-export`
- Identifiers and file names: `increment`, `double`, `square`, `answer`,
  `number`, `left`, `right`, `add`, `add_20`, `multiply_three`,
  `arithmetic`, `Arithmetic`, `calculation`, `program`, `program.ash`,
  `main.ash`, `arithmetic.ash`, the `.ash` extension

<!-- markdownlint-enable MD013 -->

`pub` is short for *public*: the prose gloss translates (`публичен`), the
keyword stays. Prose may name an identifier in words — "the `add_20`
binding" — in which case the identifier stays and only the words around it
translate. The list covers the pilot lessons; each new lesson extends it.

## Approved renderings

<!-- markdownlint-disable MD013 -->

| English | Bulgarian | Note |
| --- | --- | --- |
| program | програма | |
| source file | изходен файл | |
| definition | дефиниция | |
| expression | израз | |
| value | стойност | |
| evaluate | изчислява | |
| signature | сигнатура | |
| type | тип | |
| function | функция | |
| integer | цяло число | |
| operation | операция | |
| addition | събиране | |
| multiplication | умножение | |
| parentheses | скоби | |
| braces | къдрави скоби | |
| parameter | параметър | |
| argument | аргумент | |
| function call | извикване на функция | |
| substitution | заместване | |
| function composition | композиция на функции | |
| trace | проследяване | |
| module | модул | |
| import | импорт | the keyword `import` itself stays |
| alias | псевдоним | |
| qualified name | квалифицирано име | |
| public | публичен | the concept behind `pub` |
| private | частен | |
| declaration | декларация | |
| operator precedence | приоритет на операциите | |
| unit type | unit тип | `Unit` itself stays |
| input | вход | |
| currying | къринг | Project coinage approved 2026-10-22: transliteration of /ˈkʌri/ with ъ. The first mention in a lesson adds a brief inline note tying it to English *currying*. |
| right-associative | дясно асоциативен | |
| partial application | частично прилагане | |
| partial call | частично извикване | |
| block | блок | |
| binding | свързване | |
| predict | предсказване | Instructions use the imperative Предскажете. Review ruling 2026-10-22: предвиждане and предвидете mean foresight, not predicting a concrete result. |
| run | стартиране | |
| report (the tool reports) | отчита | |
| exercise | упражнение | |
| scratch directory | работна директория | |
| learning assistant | учебен асистент | |
| rejection | отхвърляне | |
| entry module | начален модул | |
| entry file | начален файл | |
| text | текст | |
| line break | нов ред | |
| byte | байт | |
| equality | равенство | |
| matching | съпоставяне | |
| equation (in patterns) | уравнение | |
| field | поле | |
| branch | клон | |
| exhaustive | изчерпателен | |
| constructor | конструктор | |
| recursive call | рекурсивно извикване | |
| mutually recursive | взаимно рекурсивен | |
| anonymous function | анонимна функция | |
| type parameter | типов параметър | |
| data definition | дефиниция на данни | |

<!-- markdownlint-enable MD013 -->

## Provisional choices

Valid renderings the pipeline accepts, flagged for the human reviewer to
confirm one choice for the whole book:

<!-- markdownlint-disable MD013 -->

| Chosen | English | Alternative | Open question |
| --- | --- | --- | --- |
| изчислява | evaluate | пресмята | School habit prefers `пресмята`; computing texts prefer `изчислява`. One choice for all lessons. |
| начален модул | entry module | входен модул | `входен` collides with the input sense of "entry". Confirm the coinage. |
| отчита | report | съобщава | Whether the tool's reports and the prose's "reports" share one verb. |
| извикване | call | повикване | Older texts use `повикване`; newer ones `извикване`. One choice. |
| частен | private | частен за модула | Short form vs the unambiguous longer form. |
| strict evaluation | стриктно оценяване | нетърпеливо оценяване | One choice for the strict/lazy pair across all lessons. |
| lazy evaluation | мързеливо оценяване | отложено оценяване | Pair with strict evaluation above. |
| structural recursion | структурна рекурсия | рекурсия по структурата | |
| in scope | в областта на видимост | в scope | Diagnostic prose uses this heavily. |
| arm (of a match) | клон | случай | |
| pattern | образец | шаблон | The pattern-matching sense. |
| tuple | кортеж | наредена двойка | |
| product type | тип произведение | product тип | |
| sum type | тип сума | sum тип | |
| algebraic data type | алгебраичен тип данни | АДТ | |
| abstract data type | абстрактен тип данни | АТД | |
| closure | затваряне | клозър | |
| higher-order function | функция от по-висок ред | | |
| generics | обобщени типове | обобщено програмиране | |
| parameterized algebraic data type | параметризиран алгебраичен тип | | |
| ad-hoc polymorphism | ad-hoc полиморфизъм | презареждащ полиморфизъм | Keep the Latin prefix or coin a Bulgarian one? |
| parametric polymorphism | параметричен полиморфизъм | | |
| kind | kind | кайнд | Keeping the English word avoids collision with „вид“; transliterate instead? |
| local generalization | локално обобщение | | |
| monomorphic | мономорфен | | |

<!-- markdownlint-enable MD013 -->

## Figures and assistant notes

Figure `caption` and `description` fields in a lesson's `diagrams` front
matter are prose and translate; `split` fence bodies are notation and stay
unchanged. Blockquoted learning-assistant prompts are prose; the bold
lead-in ("With a learning assistant:") translates with them.
