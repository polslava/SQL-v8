SELECT sel1.driver_name
	, sel1.shiftmonth
--	, sel1.shov_id
	, AVG(sel1.loading_time) AS loading_time
	, sel1.shov_name
FROM (

SELECT --COUNT(1) AS trips

sel_0.* 
	, ep.fam_name||' '||ep.first_name||' '||ep.second_name AS driver_name
, to_char(sel_0.shiftdate,'mm') AS shiftmonth
, veh.name AS shov_name
FROM (
SELECT 
t.begin_time,
t.work_type_id,
t.load_type_id,
t.unload_id,
t.truck_id,
t.shov_id,
t.weight,
t.weight_std
/*, t.volume,
t.volume_std*/
, 100-(case when t.weight_std>0 
THEN (t.weight/t.weight_std)*100
ELSE 100 END) AS diff_weight
--, t.load_depart_time , t.load_arrive_time
, t.load_depart_time - t.load_arrive_time AS loading_time
	 ,(CASE when to_number(to_char(begin_time, 'hh24'),'99') BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shift
, DATE(begin_time)   AS shiftdate
--, t.load_arrive_time	, t.load_depart_time	, t.load_checkpoint_time	, t.load_arrive_waiting_zone	, t.unload_arrive_time	, t.unload_depart_time	, t.set_to_load_begin	, t.set_to_load_end	, t.set_to_unload_begin	, t.set_to_unload_end	, t.load_waiting_time	, t.begin_time	, t.begin_time_load	, t.end_time	, t.turnround_begin_time


	 FROM v8.vist_pit_trip t

WHERE t.begin_time_load between TO_timestamp('2024-01-01 08:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2025-01-01 08:00:00','yyyy-mm-dd hh24:mi:ss')
) sel_0
	LEFT JOIN v8.vist_city_shifttask st
 		ON st.shift_id = sel_0.shift AND st.task_date = sel_0.shiftdate AND st.vehicle_id=sel_0.shov_id
 	LEFT JOIN v8.vist_enterprise_employee ee
 		ON ee.id = st.driver_id
 	LEFT JOIN v8.vist_enterprise_person ep
 		ON ep.id = ee.person_id
 	LEFT JOIN v8.vist_core_vehicle veh
 		ON veh.id = sel_0.shov_id  
 	WHERE veh.name IN ('06292№4','06322_№7','20292№2','Bucyrus1','Bucyrus2',
		 'Ex_2500 №5','Ex_2600 №3','Ex_3600 №8','PC1250_№1','PC4000_№10','PC4000_№11','PC4000_№9',
		 'XCMG XE2000 №6','ЭКГ-5А(8185)')
		 
		 AND sel_0.loading_time IS not NULL --отсекаем рейсы с мгновенной погрузкой
		 
		 ) sel1
		 GROUP BY sel1.driver_name
	, sel1.shiftmonth
--	, sel1.shov_id

	, sel1.shov_name