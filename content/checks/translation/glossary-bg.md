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
| comment | коментар | |
| operator | оператор | |
| literal | литерал | |
| subtraction | изваждане | |
| ordering | подреждане | |
| boolean (value) | булева стойност | |
| accumulator | акумулатор | |
| effect | ефект | |
| provider | доставчик | |

| evaluate | изчислява | Batch-approved 2026-10-22 from Provisional. |
| entry module | начален модул | Batch-approved 2026-10-22 from Provisional. |
| report | отчита | Batch-approved 2026-10-22 from Provisional. |
| call | извикване | Batch-approved 2026-10-22 from Provisional. |
| private | частен | Batch-approved 2026-10-22 from Provisional. |
| strict evaluation | стриктно оценяване | Batch-approved 2026-10-22 from Provisional. |
| lazy evaluation | мързеливо оценяване | Batch-approved 2026-10-22 from Provisional. |
| structural recursion | структурна рекурсия | Batch-approved 2026-10-22 from Provisional. |
| in scope | в областта на видимост | Batch-approved 2026-10-22 from Provisional. |
| arm (of a match) | клон | Batch-approved 2026-10-22 from Provisional. |
| pattern | образец | Batch-approved 2026-10-22 from Provisional. |
| tuple | кортеж | Batch-approved 2026-10-22 from Provisional. |
| product type | тип произведение | Batch-approved 2026-10-22 from Provisional. |
| sum type | тип сума | Batch-approved 2026-10-22 from Provisional. |
| algebraic data type | алгебраичен тип данни | Batch-approved 2026-10-22 from Provisional. |
| abstract data type | абстрактен тип данни | Batch-approved 2026-10-22 from Provisional. |
| closure | затваряне | Batch-approved 2026-10-22 from Provisional. |
| higher-order function | функция от по-висок ред | Batch-approved 2026-10-22 from Provisional. |
| generics | обобщени типове | Batch-approved 2026-10-22 from Provisional. |
| parameterized algebraic data type | параметризиран алгебраичен тип | Batch-approved 2026-10-22 from Provisional. |
| ad-hoc polymorphism | ad-hoc полиморфизъм | Batch-approved 2026-10-22 from Provisional. |
| parametric polymorphism | параметричен полиморфизъм | Batch-approved 2026-10-22 from Provisional. |
| kind | kind | Batch-approved 2026-10-22 from Provisional. |
| local generalization | локално обобщение | Batch-approved 2026-10-22 from Provisional. |
| monomorphic | мономорфен | Batch-approved 2026-10-22 from Provisional. |
| targeted import | целев импорт | Batch-approved 2026-10-23 from Provisional. |
| re-export | реекспортиране | Batch-approved 2026-10-23 from Provisional. |
| facade | фасада | Batch-approved 2026-10-23 from Provisional. |
| opaque | непрозрачен | Batch-approved 2026-10-23 from Provisional. |
| handler | обработвач | Batch-approved 2026-10-23 from Provisional. |
| scope (resource) | обхват | Batch-approved 2026-10-23 from Provisional. |
<!-- markdownlint-enable MD013 -->

## Provisional choices

Coinages and contested renderings land here until the review owner
confirms or rejects them. None currently.

<!-- markdownlint-disable MD013 -->

| Chosen | English | Alternative | Open question |
| --- | --- | --- | --- |
<!-- markdownlint-enable MD013 -->

## Figures and assistant notes

Figure `caption` and `description` fields in a lesson's `diagrams` front
matter are prose and translate; `split` fence bodies are notation and stay
unchanged. Blockquoted learning-assistant prompts are prose; the bold
lead-in ("With a learning assistant:") translates with them.
