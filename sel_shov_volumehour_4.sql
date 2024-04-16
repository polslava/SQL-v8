SELECT sel5.driver_name,
sel5.shiftmonth,
sel5.shovel_name,
avg(sel5.volume_hour) AS volume_hour_avg,
avg(sel5.volume_1_hour) AS volume_plan_hour_avg,
max(sel5.volume_hour) AS volume_hour_max,
max(sel5.volume_1_hour) AS volume_plan_hour_max,
AVG(sel5.volume_hour)/AVG(sel5.volume_1_hour),
AVG(sel5.volume_hour_percent) AS volume_hour_percent

FROM (
SELECT sel4.* 
, sel4.volume_hour/sel4.volume_1_hour AS volume_hour_percent
, ep.fam_name||' '||LEFT(ep.first_name,1)||'.'||LEFT(ep.second_name,1)||'.' AS driver_name
FROM (
select sel3.*
, (CASE WHEN sel3.is_volume IS FALSE THEN sel3.volume_plan/sel3.density ELSE sel3.volume_plan
END) AS volume_1
, (CASE WHEN sel3.is_volume IS FALSE THEN (sel3.volume_plan/sel3.density)/(11+(1/6)) ELSE sel3.volume_plan/(11+(1/6))
END) AS volume_1_hour
 FROM 
(SELECT sel2.* 
, sp1.volume AS volume_plan
, lt.is_volume --признак тонн или кубов
, lt.density --плотность для перевода тонн в кубы
FROM (
SELECT sel1.work_type_id,
sel1.load_type_id,
sel1.shov_id,
sum(sel1.volume) AS volume,

sum(sel1.volume/((11+(1/6))/* /24 */)) AS volume_hour,
sel1.shiftdate,
sel1.shiftmonth
, sel1.shift
, sel1.shovel_name
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
t.volume,
t.volume_std
/*100-(case when t.weight_std>0 
THEN (t.weight/t.weight_std)*100
ELSE 100 END) AS diff_weight*/
	 ,(CASE when to_number(TO_CHAR(t.begin_time, 'hh24'),'99') BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shift
, DATE(t.begin_time)   AS shiftdate
--, to_char(t.begin_time ,'yyyy.mm.dd') AS shiftdate_t
, to_char(t.begin_time ,'mm') AS shiftmonth
, 1 AS trip  --для подсчёта рейсов
, veh.name AS shovel_name
	 FROM v8.vist_pit_trip t

		LEFT JOIN v8.vist_core_vehicle veh
 		ON veh.id = t.shov_id 	
 		
WHERE t.begin_time_load between TO_timestamp('2024-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2025-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND 
veh.name IN ('06292№4','06322_№7','20292№2','Bucyrus1','Bucyrus2',
		 'Ex_2500 №5','Ex_2600 №3','Ex_3600 №8','PC1250_№1','PC4000_№10','PC4000_№11','PC4000_№9',
		 'XCMG XE2000 №6','ЭКГ-5А(8185)')
--	AND veh.id = 146
) sel1
GROUP BY sel1.work_type_id,
sel1.load_type_id,
sel1.shov_id,

sel1.shiftdate,
sel1.shiftmonth
, sel1.shift
, sel1.shovel_name
) sel2
LEFT JOIN v8.vist_core_loadtype lt
	ON lt.id = sel2.load_type_id



LEFT JOIN 
(SELECT sp.*,
	sv.volume
	,sv.day
	, (sp.date+ sv.day-1) AS shiftdate
	,sv.number AS shiftnum

	 FROM v8.vist_pit_shiftmonthplan sp
	LEFT JOIN v8.vist_pit_shiftmonthplanfactvolume sv
		ON sv.plan_id = sp.id
		WHERE 	  sv.volume >0
		) sp1 --планы на смену
		ON sp1.shovel_id = sel2.shov_id AND sel2.shiftdate = sp1.shiftdate AND sel2.shift = sp1.shiftnum
			AND sel2.load_type_id = sp1.load_type_id 
) sel3
--WHERE shov_id = 146

	/*	LEFT JOIN v8.vist_pit_shovelloadpassport pass 
		ON pass.shovel_id = veh.id
		*/
) sel4
LEFT JOIN v8.vist_city_shifttask st
 		ON st.shift_id = sel4.shift AND st.task_date = sel4.shiftdate AND st.vehicle_id=sel4.shov_id
 	LEFT JOIN v8.vist_enterprise_employee ee
 		ON ee.id = st.driver_id
 	LEFT JOIN v8.vist_enterprise_person ep
 		ON ep.id = ee.person_id
   
 	
) sel5
GROUP BY sel5.driver_name,
sel5.shiftmonth,
sel5.shovel_name
