--- 1
select top 1 with ties (select Название from Города where Город_ID = Город_ID_1) as City_1, 
(select Название from Города where Город_ID = Город_ID_2) as City_2
from Маршруты
order by Расстояние asc

--- 2
select top 1 with ties Cities_1.Название, Cities_2.Название
from Маршруты left join Города as Cities_1 on Город_ID_1 = Cities_1.Город_ID
left join Города as Cities_2 on Город_ID_2 = Cities_2.Город_ID
where Cities_1.Область_ID = Cities_2.Область_ID
order by Cities_1.Область_ID asc

--- 3
select Cities_1.Город_ID, Cities_2.Город_ID
from Города as Cities_1 cross join Города as Cities_2
where Cities_1.Город_ID < Cities_2.Город_ID
	except
select Город_ID_1, Город_ID_2
from Маршруты

--- 4
select distinct Город_ID_1
from Маршруты
	except
select distinct Город_ID_2
from Маршруты

--- 5
select distinct Город_ID_2
from Маршруты
	except
select distinct Город_ID_1
from Маршруты

--- 6
/*Я решил сделать более общий запрос. Он будет работать, если нужно будет найти возможные города при большем количестве переходов.
Запрос работает, если число шагов не больше 1, т.е. если мы вообще не двигаемся или делаем 1 шаг*/
declare @city int, @n int
set @city = 4
set @n = 3 /*Максимальное число шагов*/

/*Таблица, которая включает в себя прямые и обратные маршруты.*/
create table #Routes(City_ID_1 int, City_ID_2 int, Distance float, primary key(City_ID_1, City_ID_2))

insert into #Routes(City_ID_1, City_ID_2, Distance)
	select Город_ID_1, Город_ID_2, Расстояние
	from Маршруты

insert into #Routes(City_ID_1, City_ID_2, Distance)
	select Город_ID_2, Город_ID_1, Расстояние
	from Маршруты
	
/*#Sources - таблица со всеми началами. Если мы на 1-ом шаге выезжаем из города 1, он пемещается сюда. 
Если на 2-ом шаге мы выезжаем из городов 2, 3, 4, то они тоже помещаются сюда*/
create table #Sources(ID_sour int)

/*#Destinations - таблица с конечными пунктами. Если едем из города 1, то тут будут находиться 2, 3, 4*/
create table #Destinations(ID_des int)

insert into #Destinations
	select City_ID_2
	from #Routes
	where City_ID_1 = @city
	
insert into #Sources
	select distinct City_ID_1
	from #Routes
	where City_ID_1 = @city

while (@n > 1)
begin
	insert into #Sources
		select *
		from #Destinations
	
	insert into #Destinations
		select City_ID_2
		from #Destinations left join #Routes on ID_des = City_ID_1
	
	delete #Destinations
	where ID_des in (select * from #Sources)
	
	set @n = @n - 1
end 

select Название
from (select distinct ID_sour
	  from #Sources
		union
	  select distinct ID_des
	  from #Destinations) as Identificators left join Города on ID_sour = Город_ID

drop table #Destinations
drop table #Sources

--- 7
select distinct #Routes.City_ID_1, #Routes.City_ID_2
from #Routes left join (select R1.City_ID_1, R2.City_ID_2, R1.Distance + R2.Distance as Distance
from #Routes as R1 left join #Routes as R2 on R1.City_ID_2 = R2.City_ID_1) as Temp on #Routes.City_ID_2 = Temp.City_ID_1
where #Routes.City_ID_1 = Temp.City_ID_2 and #Routes.Distance > Temp.Distance and #Routes.City_ID_1 < #Routes.City_ID_2
order by #Routes.City_ID_1 asc

--- 8
select SUM(Distance) as Route_distance
from (Расписание as Timetable_1 inner join Расписание as Timetable_2 on Timetable_1.Расписание_ID = Timetable_2.Расписание_ID and Timetable_1.Номер = Timetable_2.Номер - 1)
left join #Routes on Timetable_1.Город_ID = #Routes.City_ID_1 and Timetable_2.Город_ID = #Routes.City_ID_2
group by Timetable_1.Расписание_ID
having count(#Routes.City_ID_1) = count(Timetable_1.Номер)

drop table #Routes