﻿//////////////////////////////////////////////////////////////////////////
// Работа с командными файлами

#Использовать tempfiles

Перем ЗаписьТекста;
Перем ПутьКоманды;
Перем Команда;
Перем ТекстФайла;

Перем ЭтоWindows;
Перем Лог;
Перем НемедленнныйВывод;

// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.commands";
КонецФункции

// Получить путь командного файла
//
// Возвращаемое значение:
//  Строка   - путь командного файла
//
Функция ПолучитьПуть() Экспорт
	Возврат ПутьКоманды;
КонецФункции

// Получить вывод выполненной команды.
//
//  Возвращаемое значение:
//   Строка - Вывод команды
//
Функция ПолучитьВывод() Экспорт
	ПроверитьЧтоКомандаВыполнена();
    Возврат Команда.ПолучитьВывод();
КонецФункции

// Получить код возврата выполненной команды.
//
//  Возвращаемое значение:
//   Число - код возврата команды
//
Функция ПолучитьКодВозврата() Экспорт
	ПроверитьЧтоКомандаВыполнена();
    Возврат Команда.ПолучитьКодВозврата();
КонецФункции

// Создать новый командный файл по переданному пути или создать новый временный файл
//
// Параметры:
//   Путь - Строка - путь создаваемого файла. Необязательное значение.
//		Если не задан, создается временный файл в каталоге временных файлов
//
//  Возвращаемое значение:
//   Строка - Путь созданного файла
//
Функция Создать(Знач Путь = "") Экспорт
	
	Если ПустаяСтрока(Путь) Тогда
		ПутьКоманды = ВременныеФайлы.НовоеИмяФайла(?(ЭтоWindows, ".bat", ".sh"));
		Лог.Отладка("КомандныйФайл: задаю временный путь командного файла <%1>.", ПутьКоманды);
	Иначе
		ПутьКоманды = Путь;
		Лог.Отладка("КомандныйФайл: использую путь командного файла <%1>.", ПутьКоманды);
	КонецЕсли;
	Кодировка = ?(ЭтоWindows, "cp866", КодировкаТекста.UTF8NoBOM);
	Если ЭтоWindows Тогда
		ЗаписьТекста = Новый ЗаписьТекста(ПутьКоманды, Кодировка);
	Иначе
		ЗаписьТекста = Новый ЗаписьТекста(ПутьКоманды, Кодировка, , , Символы.ПС);
	КонецЕсли;

	ТекстФайла = "";

	Возврат ПутьКоманды;
	
КонецФункции

// Добавить очередную команду в командный файл
//
// Параметры:
//  Команда  - Строка - очередная команда
//
Процедура ДобавитьКоманду(Знач Команда) Экспорт
	ПроверитьЧтоФайлОткрыт();
	ЗаписьТекста.ЗаписатьСтроку(Команда);
	ТекстФайла = ТекстФайла + Команда + Символы.ПС;	
КонецПроцедуры

// Выполнить командный файл и вернуть код возврата
//
//  Возвращаемое значение:
//   Число - код возврата
//
Функция Исполнить() Экспорт
	
	Закрыть();

	Команда = Новый Команда;
	Команда.УстановитьКодировкуВывода(КодировкаТекста.OEM);
	Команда.ПоказыватьВыводНемедленно(НемедленнныйВывод);

	Если ЭтоWindows Тогда 
		Приложение = "cmd.exe";
		СтрокаЗапуска = "/C ""%1""";
	Иначе
		Приложение = "sh";
		СтрокаЗапуска = "'%1'";
	КонецЕсли;
	Команда.УстановитьКоманду(Приложение);	
	Команда.ДобавитьПараметр(СтрШаблон(СтрокаЗапуска, ПутьКоманды));	
	
	КодВозврата = Команда.Исполнить();
		
	Возврат КодВозврата;

КонецФункции

// Завершает запись командного файла
//
// Возвращаемое значение:
//   Строка  - путь командного файла
//
Функция Закрыть() Экспорт
	
	Если ЗаписьТекста <> Неопределено Тогда
		ЗаписьТекста.Закрыть();
		ЗаписьТекста = Неопределено;
	КонецЕсли;
	
	Возврат ПутьКоманды;
	
КонецФункции

// Получить текст командного файла
//
// Возвращаемое значение:
//   Строка  - текст командного файла
//
Функция ПолучитьТекстФайла() Экспорт
	Возврат ТекстФайла;
КонецФункции

// Управляет мгновенным выводом лога команды
//
// Параметры:
//   НемедленныйПоказ - Булевое
//		Ложь: показывает вывод только после завершения выполнения команды
//		Истина: показ вывода выполняется почти сразу, после появления очередной порции сообщений от команды
//
Процедура ПоказыватьВыводНемедленно(Знач НемедленныйПоказ) Экспорт
	НемедленнныйВывод = НемедленныйПоказ;
КонецПроцедуры

// Получить строку перенаправления ввода-вывода "> файл"
//
// Параметры:
//   ИмяФайлаПриемника - Строка - имя файла для перенаправления вывода
//   УчитыватьStdErr - Булево - Если Истина, писать ошибки в этот же файл
//
//  Возвращаемое значение:
//   Строка - строка перенаправления ввода-вывода "> файл"
//
Функция СуффиксПеренаправленияВывода(Знач ИмяФайлаПриемника, Знач УчитыватьStdErr = Истина) Экспорт
	Возврат "> """ + ИмяФайлаПриемника + """" + ?(УчитыватьStdErr, " 2>&1", "");
КонецФункции

//////////////////////////////////////////////////////////////////////////
// Служебные процедуры и функции

Процедура ПроверитьЧтоФайлОткрыт()
	Если ЗаписьТекста = Неопределено Тогда
		Создать();
	КонецЕсли;
КонецПроцедуры

Процедура ПроверитьЧтоКомандаВыполнена()
	Если Не ЗначениеЗаполнено(Команда) Тогда
		ВызватьИсключение СтрШаблон("Команда еще не выполнялась. <%1>", ПутьКоманды);
	КонецЕсли;
КонецПроцедуры

// Инициализация работы библиотеки.
// Задает минимальные настройки.
//
Процедура Инициализация()
    
    Лог = Логирование.ПолучитьЛог(ИмяЛога());
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

	ТекстФайла = "";
	НемедленнныйВывод = Истина;

	Создать();
КонецПроцедуры

Инициализация();
