# Подреждане чрез данни {#ordering-from-data}

След предишния урок остана един въпрос без отговор. Без изваждане и оператори
за подреждане откъде идват спускането и сравнението в програмата? Този урок
отговаря: дефинирайте числата като данни и операциите се превръщат в
структурна рекурсия — със същата форма, установена в урока за рекурсивните
данни, включително базовия случай.

Всичко, което използва компилацията, вече е на мястото си: дефиниции на данни,
съпоставяне по образци (включително заместващи символи и вложени образци) и
структурна рекурсия.

## Числата, построени като данни {#the-numbers-built-as-data}

Една дефиниция на данни може да построи числата, вместо само да ги описва:

<!-- source: src/01-natural.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

main : Unit -> Natural
main () = Next(Next(Zero))
```

Прочетете дефиницията форма по форма. `Zero` е число — първото.
`Next(rest)` е числото след друго `Natural`, а полето му съдържа числото, след
което идва. Това са естествените числа в математиката: нула, после числото
след нулата, после числото след него — по една стъпка на броене за всеки слой.

Стойността в `main` построява две стъпки след `Zero`. Предскажете
показаната стойност и типа ѝ, преди да стартирате; Ash отчита
`Next(Next(Zero)) : Natural`.

## Сравнение, по едно уравнение за всяка форма {#comparison-one-equation-per-form}

За да сравните две стойности от `Natural`, първо назовете отговорите, които
може да даде сравнението:

<!-- source: src/02-compare.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

type Ordering =
    Less
    | Equal
    | Greater

compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Zero = Equal
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

main : Unit -> Ordering
main () = {
    let two = Next(Next(Zero))
    let three = Next(two)
    compare_natural two three
}
```

`Ordering` носи по един конструктор за всеки изход, а функцията съпоставя
всяка форма на единия вход с всяка форма на другия. Две стойности `Zero` са
равни; `Zero` идва преди всяка стойност `Next` и така отговаря на
`Less`; всяка стойност `Next` идва след `Zero` и така отговаря на
`Greater`. Всяка от двете стойности `Next` крие по една стъпка на броене —
премахването на двата външни слоя сравнява останалите числа.

Това е *структурна рекурсия* точно както я определи урокът за рекурсивните
данни: по едно уравнение за всяка форма, като всяко рекурсивно извикване
получава поле от съпоставената стойност. Тук двата входа се съпоставят заедно,
затова извикването се спуска едновременно към остатъците и на двата.

Ash няма образци с целочислени литерали, затова програмата построява
стойностите си с конструктори; свързванията дават четими имена на сравняваните
числа. Проследете извикването:

```text
compare_natural two three
compare_natural (Next(Zero)) (Next(Next(Zero)))
compare_natural Zero (Next(Zero))
Less
```

Всяко извикване премахва по един слой от двете страни, докато двойката с
`Zero` даде пряк отговор — базовият случай. Предскажете резултатите от
обратното извикване, `compare_natural three two`, и от
`compare_natural two two`, преди да ги опитате в работното си копие.
Стартирайте програмата; Ash отчита `Less : Ordering`.

## Пътят обратно и пътят надолу {#the-way-back-and-the-way-down}

Сравнението остава в рамките на `Natural`; за да видите колко брои една
стойност, преобразувайте я в `Int`:

<!-- source: src/03-to-int.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

main : Unit -> Int
main () = to_int (Next(Next(Next(Zero))))
```

Базовият случай посочва пряко броя на `Zero`: `0`; уравнението за
`Next` първо иска броя на остатъка, а после добавя единица за външния слой.
Събиранията изчакват рекурсивното извикване:

```text
to_int (Next(Next(Next(Zero))))
1 + to_int (Next(Next(Zero)))
1 + (1 + to_int (Next(Zero)))
1 + (1 + (1 + to_int Zero))
1 + (1 + (1 + 0))
3
```

Всяко извикване предава резултата си на изчакващото събиране и целият отговор
се сглобява при връщането на извикванията — резултатът се построява по
обратния път от базовия случай. Предскажете какво ще отчете програмата; Ash
отговаря `3 : Int`.

Същото преобразуване може да пренася броя си и надолу към извикванията:

<!-- source: src/04-to-int-down.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

to_int_down : Natural -> Int -> Int
to_int_down Zero count = count
to_int_down Next(rest) count = to_int_down rest (count + 1)

main : Unit -> (Int, Int)
main () = {
    let three = Next(Next(Next(Zero)))
    (to_int three, to_int_down three 0)
}
```

Вторият параметър пази натрупания дотук брой: при извикването той започва от
`0`, всяко уравнение за `Next` го увеличава с единица и го предава
надолу, а базовият случай връща полученото. Такъв параметър, който пренася
частичен резултат към базовия случай, се нарича *акумулатор*. Проследяването
показва къде се извършва работата сега:

```text
to_int_down (Next(Next(Next(Zero)))) 0
to_int_down (Next(Next(Zero))) (0 + 1)
to_int_down (Next(Zero)) ((0 + 1) + 1)
to_int_down Zero (((0 + 1) + 1) + 1)
(((0 + 1) + 1) + 1)
3
```

Нито едно събиране не изчаква връщането: всяка стъпка завършва, преди да
започне следващото извикване, а базовият случай връща текущата сума. Първата
функция изчислява по обратния път от базовия случай; тази изчислява по пътя
надолу. Програмата изпълнява и двете форми върху една и съща стойност и
съчетава отговорите; предскажете двойката, преди да я стартирате. Ash отчита
`(3, 3) : (Int, Int)` — и двата пътя стигат до една и съща стойност.

## Двойката, за която няма уравнение {#the-pairing-no-equation-answers}

Проверката за изчерпателност е обхванала всяка дефиниция досега: сигнатура,
която приема всяка стойност от `Natural`, изисква уравнения за всяка форма.
Премахнете уравнението за `Zero` и `Zero` и обещанието се нарушава точно
там, където `main` все още задава въпрос:

<!-- source: src/05-missing-equal.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

type Ordering =
    Less
    | Equal
    | Greater

compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

main : Unit -> Ordering
main () = compare_natural Zero Zero
```

Стартирайте тази версия от `content/learn`:

<!-- diagnostic: src/05-missing-equal.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en ordering-from-data/src/05-missing-equal.ash
These cases do not cover every possible input; for example, `Zero Zero` is not covered.
  --> /path/to/ash-doc/content/learn/ordering-from-data/src/05-missing-equal.ash:10:1
10 | compare_natural : Natural -> Natural -> Ordering
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
11 | compare_natural Zero Next(right) = Less
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
12 | compare_natural Next(left) Zero = Greater
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
13 | compare_natural Next(left) Next(right) = compare_natural left right
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

Съобщението посочва непокритата двойка — `Zero` срещу `Zero` — и
обозначава цялата останала дефиниция, която е трябвало да даде отговор.
Възстановяването на `compare_natural Zero Zero = Equal` изпълнява обещанието.

## Упражнение: удвоете числото {#exercise-double-the-number}

Започнете от ново копие на `src/03-to-int.ash` в работната си директория, като
запазите дефиницията на данните. Дефинирайте `double : Natural -> Natural` по
структурния начин: по едно уравнение за всяка форма на данните, като
рекурсивното извикване получава остатъка. Извикайте `double` върху
`Next(Next(Zero))` и върху `Next(Next(Next(Zero)))`, като предскажете всеки
резултат, преди да стартирате.

## Операциите, произлезли от данните {#from-data-the-operations}

Спускането и сравнението се появиха без нито един оператор. Дефиницията на
данните построи числата, структурната рекурсия построи сравнението върху тях,
а две форми на изчисление пренесоха броя до `Int` и обратно. Езикът се
отказа от операторите за изваждане и подреждане; програмата ги замени с един
тип число и две операции — сравнение и преобразуване, защитени от проверката
за изчерпателност.

Пътеката Cases прави същата стъпка в по-голям мащаб: [Търсене в подредено
дърво](../../cases/searching-ordered-tree/README.md) съхранява тези унарни
числа като ключове и извежда избора на клон от същите четири уравнения.

Остава още една стъпка, свързана със самите стойности. Досега всяка функция
стоеше зад име и се извикваше там, където беше нужна. Функциите също са
стойности: могат да се подават като входове, да се получават като резултати и
да се създават за конкретно изчисление. Следващият урок прави тази стъпка.
