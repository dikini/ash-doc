---
diagrams:
  - kind: illustration
    id: fig-add-types
    width: 49.563mm
    caption: Кърингована функция.
    description: "Сигнатурата add : Int -> Int -> Int е подравнена с червена кутия за функция и три сини кутии за целочислените позиции."
  - kind: illustration
    id: fig-add-type-value
    width: 49.563mm
    caption: Прилагане на функция.
    description: "Същата сигнатура се появява над разделени кутии. Горните половини показват типове: червено за функцията и синьо за Int. Долните половини разграничават по цвят add, 20, 22 и резултата 42, с етикети под тях. Стрелките на долния ред са схематични указатели за прилагане, а не преобразувания между цели числа."
  - kind: illustration
    id: fig-add-20-application
    width: 37.375mm
    caption: Частично прилагане.
    description: Прилагането на add към 20 дава функцията add_20 от тип Int -> Int. Отделната функция square има червена половина за типа и оранжева половина за стойността с етикет add 20. Входът 22 и резултатът 42 имат сини половини за типовете и виолетови и зелени половини за стойностите. В реда със стойностите етикетът на функцията е add_20.
---

# Използване на повече от един вход {#using-more-than-one-input}

Досега нашите функции са получавали по една стойност. `double` е получавала
едно число; `Arithmetic.answer` е получавала `()`.

Много изчисления изискват повече информация. Например, за да събере две числа,
функция трябва да получи и двете. Ash не изисква за това нов вид извикване.
Можем да използваме техника, наречена *къринг* (българска транслитерация на
английското *currying*). Функцията получава първия вход и оставя готова
функция, която да получи втория. Подаването на двата входа на един ред е
същият процес, записан без пауза. Можем да видим двете стъпки, като започнем
от пълно извикване и после спрем по средата.

## Подаване на два входа {#supplying-two-inputs}

Ето функция, която събира две цели числа:

<!-- source: src/01-two-inputs.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = add 20 22
```

Дефиницията назовава два параметъра: `left` и `right`. В извикването
`add 20 22` входовете съответстват на тези параметри отляво надясно.
Предскажете стойността, после запазете и стартирайте програмата. Ash отчита:

```text
42 : Int
```

Заместването обяснява този резултат:

```text
add 20 22
20 + 22
42
```

Сигнатурата разказва същото като дефиницията. Стрелките на функциите [групират
отдясно][arrows] — стрелката е *дясно асоциативна* — затова четем

```text
Int -> Int -> Int
```

като

```text
Int -> (Int -> Int)
```

Първият `Int` е първият вход. След като този вход пристигне, оставащото
има тип `Int -> Int`: функция, която чака втория вход. Когато пристигне
вторият `Int`, изчислението дава окончателната `Int`.

## Пауза след първия вход {#pausing-after-the-first-input}

За да направите тази междинна стъпка видима, премахнете `22` от
извикването. Тъй като `main` вече връща функция, типът на резултата също
трябва да се промени:

<!-- source: src/02-one-input-left.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int -> Int
main () = add 20
```

Преди да стартирате, пребройте колко входа още са нужни. `add` е получила
`20` за `left`; какво остава да получи `right` и какъв тип има то?
Стартирайте програмата, за да сравните предсказанието си:

```text
<function> : Int -> Int
```

Не е пристигнало второ цяло число, затова резултатът е функция от тип
`Int -> Int`. Инструментът показва функцията като `<function>`; този изглед не
показва тялото ѝ. Такова извикване се нарича *частично извикване* или
*частично прилагане*: то подава някои, но не всички входове на функцията.
Резултатът все пак е полезен. Той помни вече подадения вход и може да получи
останалите по-късно.

Три фигури в полето показват същото развитие нагледно: сигнатурата заедно с
нейните кутии, типове, насложени върху стойностите в пълното извикване, и
частичното извикване, проследено от `add 20` през `add_20` до `42`.

::: {#note-add-one-input .column-margin}

::: {.block}

```{#fig-add-types .illustration}
Align add : Int -> Int -> Int with a red function square and three blue
integer squares. Show the schematic application guide from the second integer
input to the result. Preserve the solid type-square vocabulary, not a value
conversion. Use shared aside-size squares, rough strokes, and Excalifont labels.
```

```{#fig-add-type-value .illustration}
Keep the signature alignment and four square positions of the type-only
figure. Split each square horizontally: the upper half shows the function
or Int type; the lower half identifies add, 20, 22, or 42 with its color and
label. Preserve the application guide and shared aside square size. Use rough
strokes and Excalifont; do not imply that arrows convert integer values.
```

```{#fig-add-20-application .illustration}
Show add with 20 in the upper row, then a downward transition to the waiting
function add_20 with input 22 and result 42. Preserve type/value halves:
function types red, Int types blue, add_20 orange, 22 violet, and 42 green.
Align add_20 : Int -> Int over the lower row. Keep its application guide
distinct from the between-row arrow. Match square size to the other aside
figures, not the width of this shorter row. Use rough strokes and Excalifont.
```

:::

:::

Можем да дадем име на чакащата функция и да я използваме на следващия ред:

<!-- source: src/03-reuse-a-partial-call.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = {
    let add_20 = add 20
    add_20 22
}
```

Къдравите скоби обединяват тези редове в един *блок*; последният ред дава
стойността на блока. Свързването `let add_20 = add 20` дава на чакащата
функция името `add_20`. Тя помни `20` и има тип `Int -> Int`. Следващият
ред подава `22` като оставащ вход. Предскажете резултата, после
стартирайте програмата и сравнете `42 : Int` на Ash с тези стъпки:

```text
add_20 22
add 20 22
20 + 22
42
```

## Упражнение: умножаване на три числа {#exercise-multiply-three-numbers}

Започнете с ново копие на `src/01-two-inputs.ash` в работната си директория и
изградете умножение с три входа със следната сигнатура:

```text
multiply_three : Int -> Int -> Int -> Int
```

После опитайте три извиквания в `main`, едно по едно: подайте всички
входове и предскажете цялото число; подайте само два и предскажете типа на
чакащата функция; подайте на тази функция последния вход и проверете
резултата. Използвайте стрелките в сигнатурата, за да обясните всеки вход и
всеки резултат.

## От входове към решения {#from-inputs-to-decisions}

Няколкото входа не променят начина, по който се чете едно извикване: всяка
стойност пристига отляво, всяка стрелка показва какво остава, а пълното
извикване достига окончателния резултат. Частичното извикване просто спира
по-рано, като оставя функция, която все още чака.

Досега всяко изчисление следваше един фиксиран път. Какво се случва, когато
програмата трябва да разгледа стойност и да избере пътя?

[arrows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#precedence-and-associativity
