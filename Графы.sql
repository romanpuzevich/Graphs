--- 1
select top 1 with ties (select �������� from ������ where �����_ID = �����_ID_1) as City_1, 
(select �������� from ������ where �����_ID = �����_ID_2) as City_2
from ��������
order by ���������� asc

--- 2
select top 1 with ties Cities_1.��������, Cities_2.��������
from �������� left join ������ as Cities_1 on �����_ID_1 = Cities_1.�����_ID
left join ������ as Cities_2 on �����_ID_2 = Cities_2.�����_ID
where Cities_1.�������_ID = Cities_2.�������_ID
order by Cities_1.�������_ID asc

--- 3
select Cities_1.�����_ID, Cities_2.�����_ID
from ������ as Cities_1 cross join ������ as Cities_2
where Cities_1.�����_ID < Cities_2.�����_ID
	except
select �����_ID_1, �����_ID_2
from ��������

--- 4
select distinct �����_ID_1
from ��������
	except
select distinct �����_ID_2
from ��������

--- 5
select distinct �����_ID_2
from ��������
	except
select distinct �����_ID_1
from ��������

--- 6
/*� ����� ������� ����� ����� ������. �� ����� ��������, ���� ����� ����� ����� ��������� ������ ��� ������� ���������� ���������.
������ ��������, ���� ����� ����� �� ������ 1, �.�. ���� �� ������ �� ��������� ��� ������ 1 ���*/
declare @city int, @n int
set @city = 4
set @n = 3 /*������������ ����� �����*/

/*�������, ������� �������� � ���� ������ � �������� ��������.*/
create table #Routes(City_ID_1 int, City_ID_2 int, Distance float, primary key(City_ID_1, City_ID_2))

insert into #Routes(City_ID_1, City_ID_2, Distance)
	select �����_ID_1, �����_ID_2, ����������
	from ��������

insert into #Routes(City_ID_1, City_ID_2, Distance)
	select �����_ID_2, �����_ID_1, ����������
	from ��������
	
/*#Sources - ������� �� ����� ��������. ���� �� �� 1-�� ���� �������� �� ������ 1, �� ���������� ����. 
���� �� 2-�� ���� �� �������� �� ������� 2, 3, 4, �� ��� ���� ���������� ����*/
create table #Sources(ID_sour int)

/*#Destinations - ������� � ��������� ��������. ���� ���� �� ������ 1, �� ��� ����� ���������� 2, 3, 4*/
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

select ��������
from (select distinct ID_sour
	  from #Sources
		union
	  select distinct ID_des
	  from #Destinations) as Identificators left join ������ on ID_sour = �����_ID

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
from (���������� as Timetable_1 inner join ���������� as Timetable_2 on Timetable_1.����������_ID = Timetable_2.����������_ID and Timetable_1.����� = Timetable_2.����� - 1)
left join #Routes on Timetable_1.�����_ID = #Routes.City_ID_1 and Timetable_2.�����_ID = #Routes.City_ID_2
group by Timetable_1.����������_ID
having count(#Routes.City_ID_1) = count(Timetable_1.�����)

drop table #Routes