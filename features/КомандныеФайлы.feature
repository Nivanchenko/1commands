# language: ru

Функциональность: Выполнение командных файлов

Как разработчик
Я хочу иметь возможность создавать и выполнять командные файлы
Чтобы я мог проще автоматизировать больше действий на OneScript

Контекст: Отключение отладки в логах
    Допустим Я выключаю отладку лога с именем "oscript.lib.commands"

Сценарий: Выполнение простого командного файла
    Когда Я создаю командный файл
    И Я добавляю строку "chcp 1251" в командный файл
    И Я добавляю строку "echo командный файл" в командный файл
    И Я сообщаю содержимое командного файла
    И Я выполняю командный файл
    Тогда Вывод командного файла содержит "командный файл"
    И Код возврата командного файла равен 0
