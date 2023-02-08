﻿Перем ПутьОбмена;
Перем ПапкаЗагружено;

Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.4.5.71");
	
	ПараметрыРегистрации.Вставить("Вид", "ДополнительнаяОбработка");    
	ПараметрыРегистрации.Вставить("Наименование", Метаданные().Синоним + " " + Метаданные().Комментарий);
	ПараметрыРегистрации.Вставить("Версия", Метаданные().Комментарий);
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Информация", Метаданные().Синоним + " " + Метаданные().Комментарий);
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление=НСтр("ru = 'Загрузка всей номенклатуры'");
	НоваяКоманда.Идентификатор="ЗагрузкаВсейНоменклатуры";
	НоваяКоманда.Использование="ВызовСерверногоМетода";
	НоваяКоманда.ПоказыватьОповещение=Истина;
	НоваяКоманда.Модификатор="";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление=НСтр("ru = 'Загрузка измененной номенклатуры'");
	НоваяКоманда.Идентификатор="ЗагрузкаИзмененнойНоменклатуры";
	НоваяКоманда.Использование="ВызовСерверногоМетода";
	НоваяКоманда.ПоказыватьОповещение=Истина;
	НоваяКоманда.Модификатор="";

	Возврат ПараметрыРегистрации;
	
КонецФункции   

Процедура ВыполнитьКоманду(Идентификатор, ОбъектыНазначения) Экспорт        
	Если Идентификатор = "ЗагрузкаВсейНоменклатуры" Тогда
		ЗагрузкаВсейНоменклатуры();
	ИначеЕсли Идентификатор = "ЗагрузкаИзмененнойНоменклатуры" Тогда
		ЗагрузкаИзмененнойНоменклатуры();
	КонецЕсли		
КонецПроцедуры

Процедура ЗагрузкаВсейНоменклатуры()
	
	Перем ДатаФайла, ИмяФайла, ОбработкаОбмена, Разница, СекундВСутках;
	
	ИмяФайла = ПутьОбмена + "Goods_AAtoKEDO.xml";
	ДатаФайла = ПолучитьДатуФайла(ИмяФайла);
	
	Событие = "Обмен с АА. Полная загрузка.";
	ЗаписьЖурналаРегистрации(Событие , УровеньЖурналаРегистрации.Информация,,, 
	"Начало загрузки номенклатуры из АА от: " + Формат(ДатаФайла,"ДЛФ=DDT"));
	
	Разница = ТекущаяДата() - ДатаФайла;
	СекундВСутках = 86400;
	Если Разница > СекундВСутках Тогда 
		ЗаписьЖурналаРегистрации(Событие , УровеньЖурналаРегистрации.Ошибка,,, 
		"Файл с номенклатурой из АА не загружен - слишком старый, более суток: " + Формат(ДатаФайла,"ДЛФ=DDT"));
	Иначе	
		ОбработкаОбмена = Обработки.УниверсальныйОбменДаннымиXML.Создать();
		ОбработкаОбмена.ИмяФайлаОбмена = ИмяФайла;
		ОбработкаОбмена.РежимОбмена = "Загрузка";
		ОбработкаОбмена.ОткрытьФайлЗагрузки(Истина);
		ОбработкаОбмена.АрхивироватьФайл = Ложь;;
		ОбработкаОбмена.ВыполнитьЗагрузку();
		ОбработкаОбмена = Неопределено;      
		
		ЗаписьЖурналаРегистрации(Событие , УровеньЖурналаРегистрации.Информация,,, 
		"Загружена номенклатура из АА от: " + Формат(ДатаФайла,"ДЛФ=DDT"));
	КонецЕсли;

КонецПроцедуры

Процедура ЗагрузкаИзмененнойНоменклатуры()
	Сообщить(ПутьОбмена);
	Файлы = НайтиФайлы(ПутьОбмена, "Goods_AAtoKEDOincr" + Константы.ПрефиксУзлаРаспределеннойИнформационнойБазы.Получить() + "*.xml",);
	ФайлыПоПорядку = СортированныйСписокФайлов(Файлы);
	Для каждого Файл Из ФайлыПоПорядку Цикл
		Сообщить("Загружаем файл: " + Файл);
		
		Событие = "Обмен с АА. Загрузка инкр.";
		ЗаписьЖурналаРегистрации(Событие, УровеньЖурналаРегистрации.Информация,,, 
		"Начало загрузки измененной номенклатуры из АА - " + Файл);
		
		ОбработкаОбмена = Обработки.УниверсальныйОбменДаннымиXML.Создать();
		ОбработкаОбмена.ИмяФайлаОбмена = Файл;
		ОбработкаОбмена.РежимОбмена = "Загрузка";
		ОбработкаОбмена.ОткрытьФайлЗагрузки(Истина);
		ОбработкаОбмена.АрхивироватьФайл = Ложь;;
		ОбработкаОбмена.ВыполнитьЗагрузку();
		ОбработкаОбмена = Неопределено;      
			
		КудаПереместить = ПутьОбмена + ПапкаЗагружено + ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Файл).Имя;
		ПереместитьФайл(Файл, КудаПереместить);
		ЗаписьЖурналаРегистрации(Событие, УровеньЖурналаРегистрации.Информация,,, 
			"Загружена измененная номенклатура из АА - " + КудаПереместить);
	КонецЦикла;
КонецПроцедуры

Функция СортированныйСписокФайлов(Знач ФайлыМассив)
	
	Перем Файл, ФайлыПоПорядку;
	
	ФайлыПоПорядку = Новый СписокЗначений;
	Для каждого Файл Из ФайлыМассив Цикл
		ФайлыПоПорядку.Добавить(Файл.ПолноеИмя);
	КонецЦикла;
	ФайлыПоПорядку.СортироватьПоЗначению();
    Возврат ФайлыПоПорядку;
КонецФункции


Функция ПолучитьДатуФайла(Знач ИмяФайла) Экспорт
	
	Файл = Новый Файл(ИмяФайла);
	Возврат Файл.ПолучитьВремяИзменения();
	 
КонецФункции


ПутьОбмена = "\\wdmycloud\Public\";
ПапкаЗагружено = "Загружено\";