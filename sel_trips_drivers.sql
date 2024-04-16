SELECT sel_0.* 
	, ep.fam_name||' '||ep.first_name||' '||ep.second_name AS driver_name

FROM (
SELECT 
t.begin_time,
t.work_type_id,
t.load_type_id,
t.unload_id,
t.truck_id,
t.shov_id,
t.weight,
t.weight_std,
/*t.volume,
t.volume_std*/
100-(case when t.weight_std>0 
THEN (t.weight/t.weight_std)*100
ELSE 100 END) AS diff_weight
	 ,(CASE when to_number(to_char(begin_time, 'hh24'),'99') BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shift
, DATE(begin_time)   AS shiftdate
	 FROM v8.vist_pit_trip t

WHERE t.begin_time_load between TO_timestamp('2024-01-01 08:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-03-01 08:00:00','yyyy-mm-dd hh24:mi:ss')
) sel_0
	LEFT JOIN v8.vist_city_shifttask st
 		ON st.shift_id = sel_0.shift AND st.task_date = sel_0.shiftdate AND st.vehicle_id=sel_0.shov_id
 	LEFT JOIN v8.vist_enterprise_employee ee
 		ON ee.person_id = st.driver_id
 	LEFT JOIN v8.vist_enterprise_person ep
 		ON ep.id = ee.person_id
 