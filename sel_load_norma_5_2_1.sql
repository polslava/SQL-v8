SELECT sel4.* ,
ROUND(cast(sel4.trips AS numeric)/cast(sel4.trips_dr_all AS numeric),5) AS trips_load_dr_perc -- процент рейсов из общего числа рейсов машиниста с нормальной загрузкой
,
ROUND(cast(sel4.trips AS numeric)/cast(sel4.trips_all AS numeric),5) AS trips_load_perc  -- процент рейсов из общего числа рейсов с нормальной загрузкой
FROM (	--sel4
select sel2_1.shovel, sel2_1.loadless
, sel2_1.trips 
, sel3.trips AS trips_dr_all --рейсов машиниста
, sel2_1.driver_name
/*, (SELECT COUNT(1) AS tips_all FROM v8.vist_pit_trip t1
WHERE t1.begin_time_load between TO_timestamp('2024-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-01 00:00:00','yyyy-mm-dd hh24:mi:ss')*/
/*AND (CASE WHEN 
		100-(case WHEN t1.weight_std>0 
		THEN (t1.weight/t1.weight_std)*100
		ELSE 100 END)
 >5 THEN 'недогруз'
ELSE (CASE WHEN 
		100-(case WHEN t1.weight_std>0 
		THEN (t1.weight/t1.weight_std)*100
		ELSE 100 END)
 <-10 THEN 'перегруз' ELSE 'норма' END)
END) IN ('норма') -- с нормальной загрузкой
*/
/*) AS trips_all --рейсов за период */
, sel3.trips_all 
, sel2_1.shiftmonth
FROM (	--sel2_1
SELECT sel2.shovel, sel2.loadless, sum(trip) AS trips --рейсы машиниста
	, sel2.driver_name
	, sel2.shiftmonth
FROM (	--sel2
SELECT sel1.* 

, tr_model.weight_capacity
, veh_tr.name AS Truck
, veh_sh.name AS Shovel

FROM (	--sel1
SELECT sel_0.* 
	, ep.fam_name||' '||ep.first_name||' '||ep.second_name AS driver_name
, (CASE WHEN sel_0.diff_weight >5 THEN 'недогруз'
ELSE (CASE WHEN sel_0.diff_weight <-10 THEN 'перегруз' ELSE 'норма' END)
END) AS loadless

FROM (	--sel_0
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
, DATE(t.begin_time)   AS shiftdate
, to_char(t.begin_time,'mm') AS shiftmonth
, 1 AS trip
	 FROM v8.vist_pit_trip t

WHERE t.begin_time_load between TO_timestamp('2024-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2025-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
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
 
) sel1
LEFT JOIN v8.vist_pit_truck truck ON truck.vehicle_ptr_id = sel1.truck_id
LEFT JOIN v8.vist_pit_truckmodel tr_model ON tr_model.model_ptr_id = truck.truck_model_id 
LEFT JOIN v8.vist_core_vehicle veh_tr ON veh_tr.id = sel1.truck_id
LEFT JOIN v8.vist_core_vehicle veh_sh ON veh_sh.id = sel1.shov_id
WHERE sel1.loadless IN ('норма')
) sel2
GROUP BY sel2.shovel, sel2.loadless, sel2.driver_name
	, sel2.shiftmonth
ORDER BY  sel2.shovel, sel2.loadless) sel2_1

LEFT JOIN 
(	--sel3
SELECT sel2.shovel,  sum(trip) AS trips --рейсы машиниста на экскаваторе
	, sel2.driver_name
, sel2.shiftmonth
, sel2_trips.trips_all
FROM (	--sel2
SELECT sel1.* 
/*, (CASE WHEN sel1.diff_weight >5 THEN 'недогруз'
ELSE (CASE WHEN sel1.diff_weight <-10 THEN 'перегруз' ELSE 'норма' END)
END) AS loadless*/
, tr_model.weight_capacity
, veh_tr.name AS Truck
, veh_sh.name AS Shovel
FROM (	--sel1
SELECT sel_0.* 
	, ep.fam_name||' '||ep.first_name||' '||ep.second_name AS driver_name
/*, (CASE WHEN sel_0.diff_weight >5 THEN 'недогруз'
ELSE (CASE WHEN sel_0.diff_weight <-10 THEN 'перегруз' ELSE 'норма' END)
END) AS loadless*/

FROM (	--sel_0
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
, DATE(t.begin_time)   AS shiftdate
, to_char(t.begin_time ,'mm') AS shiftmonth
, 1 AS trip
	 FROM v8.vist_pit_trip t

WHERE t.begin_time_load between TO_timestamp('2024-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2025-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
) sel_0
	LEFT JOIN v8.vist_city_shifttask st
 		ON st.shift_id = sel_0.shift AND st.task_date = sel_0.shiftdate AND st.vehicle_id=sel_0.shov_id
 	LEFT JOIN v8.vist_enterprise_employee ee
 		ON ee.id = st.driver_id
 	LEFT JOIN v8.vist_enterprise_person ep
 		ON ep.id = ee.person_id
 	LEFT JOIN v8.vist_core_vehicle veh
 		ON veh.id = sel_0.shov_id   
 	WHERE veh.name IN /*('06322_№7')*/
	 	('06292№4','06322_№7','20292№2','Bucyrus1','Bucyrus2',
		 'Ex_2500 №5','Ex_2600 №3','Ex_3600 №8','PC1250_№1','PC4000_№10','PC4000_№11','PC4000_№9',
		 'XCMG XE2000 №6','ЭКГ-5А(8185)')
 
) sel1
LEFT JOIN v8.vist_pit_truck truck ON truck.vehicle_ptr_id = sel1.truck_id
LEFT JOIN v8.vist_pit_truckmodel tr_model ON tr_model.model_ptr_id = truck.truck_model_id 
LEFT JOIN v8.vist_core_vehicle veh_tr ON veh_tr.id = sel1.truck_id
LEFT JOIN v8.vist_core_vehicle veh_sh ON veh_sh.id = sel1.shov_id
--WHERE sel1.loadless IN ('норма') --все рейсы по машинистам

) sel2
LEFT JOIN (SELECT COUNT(1) AS trips_all, TO_CHAR(t2.begin_time ,'mm') AS shiftmonth  FROM v8.vist_pit_trip t2
WHERE t2.begin_time_load between TO_timestamp('2024-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2025-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
GROUP BY TO_CHAR(t2.begin_time ,'mm')
)  sel2_trips 
	ON sel2_trips.shiftmonth = sel2.shiftmonth

GROUP BY sel2.shovel, sel2.driver_name
	, sel2.shiftmonth, sel2_trips.trips_all
ORDER BY  sel2.shovel
) sel3 ON sel3.shovel=sel2_1.shovel AND sel3.driver_name = sel2_1.driver_name AND sel3.shiftmonth = sel2_1.shiftmonth
GROUP BY sel2_1.shovel, sel2_1.loadless, sel2_1.trips , sel2_1.driver_name
, sel3.trips 
, sel2_1.shiftmonth
, sel3.trips_all
) sel4

ORDER BY  sel4.shovel, sel4.loadless
