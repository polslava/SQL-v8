SELECT --*
	--,
	begin_time,
	 to_date(TO_char(begin_time, 'dd.mm.yyyy')  , 'dd.mm.yyyy') 
	 ,to_number(to_char(begin_time, 'hh24'),'99') AS hour_trip
	 ,(CASE when to_number(to_char(begin_time, 'hh24'),'99') BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shift
, DATE(begin_time)   AS shiftdate

	FROM v8.vist_pit_trip t
	WHERE t.begin_time_load between TO_timestamp('2024-03-01 08:00:00','yyyy-mm-dd hh24:mi:ss')
		AND TO_timestamp('2024-04-01 08:00:00','yyyy-mm-dd hh24:mi:ss')