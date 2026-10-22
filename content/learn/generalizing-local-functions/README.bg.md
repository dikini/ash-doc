# Обобщаване на локални функции {#generalizing-local-functions}

В предишната глава една глобална тъждествена функция получи сигнатурата
`A -> A`, а всяко използване избираше свой тип за `A`. Блокът също може
да съдържа такава функция за повторна употреба — когато свързването е записано
по един начин. Записано по друг начин, същото тяло дава една мономорфна
функционална стойност — с един фиксиран тип за всяко използване. Две функции,
които връщат входните си стойности, могат да имат различни договори за
повторна употреба; разликата е в начина, по който е записано и проверено
локалното свързване.

## Изберете отделен тип за всяко използване {#give-each-use-its-own-type-choice}

В първата програма анонимна функция се свързва без анотация:

<!-- source: src/01-local-identity.ash -->
```ash
main : Unit -> (Int, Bool)
main () = {
    let identity = fn(value) {
        value
    }
    (identity 42, identity true)
}
```

Ash извежда, че входът и резултатът трябва да са от един и същ тип. Нищо не
фиксира този тип до `Int` или `Bool`, нито той идва от обхващащото
свързване. Компилаторът оставя типа отворен за всяко използване на `identity`.
Това се нарича *локално обобщение*.

Предскажете типа на функцията, необходим за всяко използване, и типа на
получената двойка. От директорията `src` за този урок стартирайте:

```text
$ ash 01-local-identity.ash
(42, true) : (Int, Bool)
```

При първата поява `identity` има избрания тип `Int -> Int`. При втората има
`Bool -> Bool`. И двата избора произлизат от една и съща дефиниция.

Това правило важи, когато анотиран с `let` binding свързва едно име и
инициализаторът му синтактично е анонимна функция. Обобщават се само все още
отворените избори на тип, които не произлизат от околната среда. Това не прави
всяко локално свързване полиморфно.

## Анотацията избира един договор {#an-annotation-chooses-one-contract}

Следващата програма задава изрично обикновен функционален тип:

<!-- source: src/02-annotated-identity.ash -->
```ash
main : Unit -> (Int, Bool)
main () = {
    let identity : Int -> Int = fn(value) {
        value
    }
    (identity 42, identity true)
}
```

Сравнете входния тип в анотацията с всеки подаден аргумент. Могат ли и двете
използвания да спазят този договор? За диагностичните команди запазете
директорията `src` на този урок като работна директория:

<!-- diagnostic: src/02-annotated-identity.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-annotated-identity.ash
This function argument must have type `Int`, but has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:28
6 |     (identity 42, identity true)
  |                            ^ This has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:19
6 |     (identity 42, identity true)
  |                   ^ This function requires an argument of type `Int`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:19
6 |     (identity 42, identity true)
  |                   ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

Етикетите свързват `true` с целочисления аргумент, необходим за `identity`.
Анотацията проверява един тип; тя не въвежда нови типови параметри. Премахнете
я, за да получите отново първата допустима форма на свързване, или я запазете
и използвайте функцията само с цели числа.

Глобалната сигнатура може да въвежда параметри. Локалната анотация няма такава
роля, дори ако обхващащата дефиниция вече има параметър с име, което може да
се появи в анотацията.

## Едно извикване създава една функционална стойност {#a-call-produces-one-function-value}

Този път инициализаторът е извикване:

<!-- source: src/03-returned-function.ash -->
```ash
make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let identity = make_identity ()
    (identity 42, identity true)
}
```

Самият `make_identity` е полиморфен. При всяка поява се избира по един тип за
`A`, но върнатата функция се свързва чрез инициализатор-извикване, а не
чрез допустимия синтаксис на анонимна функция. Това свързване запазва един общ
избор. Кое използване фиксира входния тип на функцията и може ли другото
използване да запази същия избор?

<!-- diagnostic: src/03-returned-function.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 03-returned-function.ash
This function argument must have type `Int`, but has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:28
9 |     (identity 42, identity true)
  |                            ^ This has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:19
9 |     (identity 42, identity true)
  |                   ^ This function requires an argument of type `Int`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:19
9 |     (identity 42, identity true)
  |                   ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

Диагностиката отново отбелязва булева стойност, подадена на целочислена
функция. Сега причината е общият изведен тип на върнатата функция, а не
изричната анотация. Ash не проверява тялото на фабриката, за да третира
резултата ѝ така, сякаш локалният инициализатор е бил анонимна функция.

Ако са ни необходими две отделно избрани функционални стойности, извикайте
фабриката два пъти:

<!-- source: src/04-separate-creations.ash -->
```ash
make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let integer_identity = make_identity ()
    let boolean_identity = make_identity ()
    (integer_identity 42, boolean_identity true)
}
```

Сега има две появи на фабриката. Предскажете дали изборите им на тип трябва да
съвпадат и дали двойката може да удовлетвори типа резултат на `main`:

```text
$ ash 04-separate-creations.ash
(42, true) : (Int, Bool)
```

Всяка поява на `make_identity` задава свой избор. Като алтернатива напишете
локалната анонимна функция директно, когато една обобщена дефиниция изразява
желаната повторна употреба.

Подобните тела на функциите предлагат различни места за избор на тип:

| Свързване | Къде се избира типът | | --- | --- | | Директна неанотирана
анонимна функция (`01`) | При всяко използване | | Анотирана функция
(`02`) | В единствения деклариран локален тип | | Един резултат от
фабрика (`03`) | Използванията споделят избора за върнатата стойност | |
Отделни резултати от фабрика (`04`) | Независимо при всяко извикване на
фабриката |

## Запазвайте фиксирани типовете на уловените стойности {#keep-captured-types-fixed}

Локална функция може да улови обхващаща стойност, като остави собствения си
входен тип отворен. Програмата по-долу запазва една стойност и я свързва с
всеки вход:

<!-- source: src/05-captured-input.ash -->
```ash
pair_with : A -> ((A, Int), (A, Bool))
pair_with saved = {
    let pair = fn(value) {
        (saved, value)
    }
    (pair 42, pair true)
}

main : Unit -> ((Bool, Int), (Bool, Bool))
main () = pair_with false
```

В `pair_with` типът на `saved` е типът на обхващащия параметър `A`.
Локалната дефиниция не може да избере различен тип за тази уловена стойност.
Тя може да обобщи новия си входен тип, който е независим от `saved`.
Предскажете типа на двете полета във всяка двойка, преди да стартирате:

```text
$ ash 05-captured-input.ash
((false, 42), (false, true)) : ((Bool, Int), (Bool, Bool))
```

И в двете двойки първото поле запазва същата булева стойност. Вторите полета
са от различни типове. Обобщаването запазва връзките с обхващащите стойности,
вместо да измисля нов тип за всяко улавяне.

## Подаването на функция избира обикновен функционален тип {#passing-a-function-chooses-an-ordinary-function-type}

Обобщено име може да се използва и като аргумент:

<!-- source: src/06-function-arguments.ash -->
```ash
apply_twice : (A -> A, A) -> A
apply_twice (transform, value) = transform (transform value)

main : Unit -> (Int, Bool)
main () = {
    let identity = fn(value) {
        value
    }
    (apply_twice (identity, 42), apply_twice (identity, true))
}
```

Всяко извикване на `apply_twice` избира по един `A`. Параметърът
`transform` е една обикновена функция `A -> A` за това извикване; това не е
параметър, който може да се извиква с несвързани типове в тялото. Двете появи
на `identity` се инстанцират поотделно, преди да бъдат съпоставени с
договорите на тези параметри. Предскажете двата резултата и посочете кой
единствен функционален тип използва всеки параметър `transform` през цялото
извикване:

```text
$ ash 06-function-arguments.ash
(42, true) : (Int, Bool)
```

Това е границата на ранг 1: общите избори на тип принадлежат на глобалните
сигнатури и допустимите локални дефиниции. Обикновените функционални параметри
и резултати не съдържат допълнителен слой полиморфен договор. Кортеж или
инициализатор с приложение също не придобива обобщаване само защото съхранява
функция.

[Правилата за блокове][blocks] определят допустимите свързвания, а [правилата
за извеждане][inference] посочват кои променливи остават фиксирани. Всеки
избор на тип трябва накрая да бъде решен или обобщен; неизползваното име не
оправдава неразрешен тип.

## Незадължителна връзка: запазване на ефектите на обратните извиквания {#optional-connection-preserving-callback-effects}

Можете направо да продължите към следващата глава от Learn. Върнете се към
този пример след [урока за редовете на обратните извиквания при
ефекти](../../effects/preserving-callback-effects/README.md), в който са
въведени заявки, обработчици и редове от ефекти.

<!-- source: src/07-local-effect-row.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

request_bonus : Unit -> Int ! {Bonus}
request_bonus ignored = perform Bonus.amount ()

main : Unit -> (Int, Int)
main () = {
    let apply = fn((function, value)) {
        function value
    }
    let constant = fn(ignored) {
        40
    }
    let first = apply (constant, ())
    let second = handle (apply (request_bonus, ())) with Bonus {
        amount ignored => resume 2
    }
    (first, second)
}
```

Прекият анонимен инициализатор позволява на `apply` да обобщи входа,
резултата и реда от ефекти на обратното си извикване. Определете изискването
към обратното извикване при всяко извикване, след което предскажете двете цели
числа. При второто извикване около заявката на обратното извикване има
обработчик:

```text
$ ash 07-local-effect-row.ash
(40, 2) : (Int, Int)
```

Чистото обратно извикване връща `40`; обратното извикване с ефект
получава `2` от своя обработчик. Изборът на ред следва всяко обратно
извикване, както входният тип следва всеки аргумент. Обобщаването запазва
ограниченията на реда и съхранява ефектите му. То не въвежда изисквания към
интерфейсите; те произлизат от договорите и свидетелствата, разгледани в
пътеката за библиотеките.

## Упражнение: намерете избора на тип {#exercise-locate-the-type-choice}

За всяка задача направете ново копие на посочения изходен файл в работна
директория извън дървото `src` на този урок. Предскажете наблюдението,
след което стартирайте копието от неговата директория.

1. Променете `01-local-identity.ash` така, че да връща три използвания — с
   целочислен, булев и unit вход. Преди да стартирате, променете и типа на
   резултата в началния модул.
2. В `04-separate-creations.ash` задайте и на двете функции целочислен вход.
   Обяснете защо два независимо избрани типа все пак може да се окажат
   еднакви.
3. Променете `pair_with false` на `pair_with 7` в `05-captured-input.ash` и
   променете типа на резултата в `main`. Предскажете кои полета сменят типа
   си.
4. В `06-function-arguments.ash` заменете един аргумент-функция тъждественост
   с функция, която прибавя единица. Проследете двете извиквания в
   `apply_twice`.

Възможността за повторна употреба на локална функция произлиза от начина, по
който е свързана, и от връзките ѝ с обхващащата среда. Сега можем да различим
обобщена дефиниция от една съхранена функционална стойност. В следващата глава
ще разберете как локалните дефиниции могат безопасно да се обръщат към себе си
и една към друга по време на инициализация.

[blocks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#blocks
[inference]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#inference-and-rank-1-restrictions
