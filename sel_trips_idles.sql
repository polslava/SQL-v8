SELECT sel1.* FROM (
select ROUND((cast(t.loaded_run_len AS NUMERIC(6))/1000),1) AS load_length
	, shov_id, load_type_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') AS shiftdate
,(CASE when to_number(to_char(begin_time, 'hh24'),'99') BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shiftnum
, to_char(t.end_time, 'hh24') AS trip_h
	FROM v8.vist_pit_trip t
	WHERE --t.shov_id = 146
		truck_id=5
		and t.end_time between TO_timestamp('2024-04-09 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-13 12:00:00','yyyy-mm-dd hh24:mi:ss')
) sel1
--ORDER BY shiftdate desc, shiftnum desc, trip_h DESC
UNION
SELECT sel2.duration, 0, sel2.idle_type_id
	, TO_CHAR(sel2.shiftdate,'yyyy.mm.dd') AS shiftdate
	, sel2.shiftnum, to_char(sel2.end_time, 'hh24') AS idle_h
FROM(
SELECT i.date AS shiftdate, i.work_regime_detail_id AS shiftnum, i.vehicle_id, i.idle_type_id
	, i.time AS begin_time, i.time_end AS end_time, DATE_PART('minute', i.time_end - i.time )::float AS duration
from v8.vist_core_intervalpointshift i
WHERE i.vehicle_id = 5
AND i.idle_type_id IN (
SELECT it.id FROM v8.vist_core_idletype it
	WHERE it.analytic_category_id = 1)) sel2
	
	ORDER BY shiftdate desc, shiftnum desc, trip_h DESC
