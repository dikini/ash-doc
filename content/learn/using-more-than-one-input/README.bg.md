---
diagrams:
  - kind: split
    id: fig-add-types
    caption: Curried function.
    description: "The signature add : Int -> Int -> Int aligns with a red function box and three blue boxes for the integer positions."
  - kind: split
    id: fig-add-type-value
    caption: Function application.
    description: The same signature appears above split boxes. Upper halves show types, red for the function and blue for Int. Lower halves distinguish add, 20, 22, and result 42 by color, with labels beneath. Arrows in the lower row are schematic application guides, not conversions between integers.
  - kind: split
    id: fig-add-20-application
    caption: Partial application.
    description: Applying add to 20 produces the function add_20 of type Int -> Int. Its separate function square has a red type half and an orange value half labelled add 20. The input 22 and result 42 have blue type halves and violet and green value halves. The value row labels the function add_20.
---

# Използване на повече от един вход

Нашите функции са получавали по една стойност наведнъж. `double` е получавала
едно число; `Arithmetic.answer` е получавала `()`. Много изчисления изискват
повече информация. Например, за да събере две числа, една функция трябва да
получи и двете.

Ash не изисква нов вид извикване за това. Можем да използваме техника,
наречена *каринг*. Функцията получава първия вход и оставя готова функция,
която да получи втория. Подаването на двата входа на един ред е същият процес,
записан без пауза. Можем да видим двете стъпки, като започнем с пълно
извикване и после спрем по средата.

## Подаване на два входа

Ето функция, която събира две цели числа:

<!-- source: src/01-two-inputs.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = add 20 22
```

Дефиницията назовава два параметъра: `left` и `right`. В извикването `add 20
22` входовете съответстват на тези параметри отляво надясно. Предвидете
стойността, после запазете и стартирайте програмата. Ash отчита:

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
се отдясно][arrows] — стрелката е *дясно асоциативна* — затова четем

```text
Int -> Int -> Int
```

като

```text
Int -> (Int -> Int)
```

Първият `Int` е първият вход. След като този вход пристигне, оставащото има
тип `Int -> Int`: функция, която чака втория вход. Когато пристигне вторият
`Int`, изчислението дава крайната `Int`.

## Пауза след първия вход

За да направите тази междинна стъпка видима, премахнете `22` от извикването.
Тъй като `main` сега дава функция, типът на резултата му също трябва да се
промени:

<!-- source: src/02-one-input-left.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int -> Int
main () = add 20
```

Преди да стартирате, пребройте колко входа още са нужни. `add` е получило `20`
за `left`; какво остава да получи `right` и какъв тип има то? Стартирайте
програмата, за да сравните това предвиждане:

```text
<function> : Int -> Int
```

Не е пристигнало второ цяло число, затова резултатът е функция от тип `Int ->
Int`. Инструментът показва функцията като `<function>`; това представяне не
показва тялото ѝ. Такова извикване се нарича *частично извикване*, или
*частично прилагане*: то подава някои, но не всички входове на функцията.
Резултатът все още е полезен. Той помни вече подадения вход и може да получи
останалите по-късно.

Три фигури в полето показват същото развитие нагледно: сигнатурата до нейните
полета, типове, наслоени върху стойностите в пълното извикване, и проследяване
на частичното извикване от `add 20` през `add_20` до `42`.

::: {#note-add-one-input .column-margin}

::: {.block}

```split
sig: [add] : [Int] -> [Int] -> [Int]
row: fn int int int
arrows: 3->4
```

```split
sig: [add] : [Int] -> [Int] -> [Int]
row: fn/add int/20 int/22 int/42
arrows: 3->4
```

```split
sig: [add] [Int]
row: fn/add int/20

sig: [add_20] : [Int] -> [Int]
row: fn/add_20 int/22 int/42
arrows: 2->3
hues: add_20=#e59b63/#91521e 22=#9673be/#71518f 42=#4e9d79/#286447
```

:::

:::

Можем да назовем чакащата функция и да я използваме на следващия ред:

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

Къдравите скоби обединяват тези редове в един *блок*; последният му ред дава
стойността на блока. Свързването `let add_20 = add 20` дава името `add_20` на
чакащата функция. Тя помни `20` и има тип `Int -> Int`. Следващият ред подава
`22` като оставащ вход. Предвидете резултата, после стартирайте програмата и
сравнете `42 : Int` от Ash с тези стъпки:

```text
add_20 22
add 20 22
20 + 22
42
```

## Упражнение: умножаване на три числа

Започнете с ново копие на `src/01-two-inputs.ash` в работната директория и
създайте умножение с три входа и тази сигнатура:

```text
multiply_three : Int -> Int -> Int -> Int
```

После опитайте три извиквания в `main`, едно по едно: подайте всички входове и
предвидете цялото число; подайте само два и предвидете типа на чакащата
функция; подайте на тази функция последния вход и проверете резултата.
Използвайте стрелките в сигнатурата, за да обясните всеки вход и всеки
резултат.

## От входовете към решенията

Няколко входа не променят начина, по който се чете извикването: всяка стойност
пристига отляво, всяка стрелка показва какво остава, а пълното извикване
достига до крайния резултат. Частичното извикване просто спира по-рано, като
оставя функция, която все още чака.

Досега всяко изчисление е следвало един и същ път. Какво се случва, когато
програмата трябва да разгледа стойност и да избере пътя?

[arrows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#precedence-and-associativity
