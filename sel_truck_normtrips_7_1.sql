SELECT sel7.truck_name, sel7.shiftdate, sel7.shiftnum
	,SUM(sel7.work_time) AS work_time_h
	, SUM(sel7.trips) AS trips
	, ROUND(AVG(sel7.norm_trips_work_time)::NUMERIC,1)  AS norm_trips_work_time
	, ROUND((AVG(trips_work_time)*100)::NUMERIC,1) AS trips_work_time_percent
	,string_agg(sel7.shovel_name,', ') AS shovel_name
	,string_agg(sel7.unload_name,', ') AS unload_name
	, sel7.truck_id
	, idle_shift.idle_sum_h
	FROM (
	SELECT sel6.*
		, (CASE WHEN sel6.count_shovels = 1 AND sel6.routes_shovels = 1
				THEN sel6.norm_trips
				ELSE sel6.norm_trips* sel6.work_time_shift
				END) AS norm_trips_work_time
		, /*(CASE WHEN sel6.count_shovels = 1 AND sel6.routes_shovels = 1
				THEN sel6.trips/(case when sel6.norm_trips IS null THEN 1 ELSE sel6.norm_trips END)
				ELSE sel6.trips/((case when sel6.norm_trips IS null THEN 1 ELSE sel6.norm_trips END)
					* (case when sel6.work_time_shift IS null or sel6.work_time_shift < 0.001 THEN 1 ELSE sel6.work_time_shift END))
				END)*/
				(CASE WHEN sel6.count_shovels = 1 AND sel6.routes_shovels = 1
				THEN sel6.trips/(sel6.norm_trips *1)
				ELSE sel6.trips/(sel6.norm_trips*sel6.work_time_shift)
				
				END)
				 AS trips_work_time
	FROM (
	SELECT sel5.*
	, /*(CASE WHEN sel5.work_time IS NULL then 0.001 ELSE (*/
	sel5.work_time/11.17
	/*)END)*/ AS work_time_shift
		, (case when sel_n.norm_trips IS null THEN 1 ELSE sel_n.norm_trips END ) AS norm_trips
	, sel_trips_shovels.trips_shovels
	, sel_count_shovels.count_shovels
	, sel_routes_shovels.routes_shovels
	FROM(
SELECT sel4.truck_name	, sel4.truck_id, sel4.model_id, sel4.shovel_name
 , sel4.load_type_id
	,sel4.shov_id
	,sel4.shiftdate, sel4.shiftnum
	, round(SUM(round(cast(
	(case when sel4.work_time IS NULL OR sel4.work_time < 0.001 THEN 0.001 ELSE sel4.work_time END)
	as NUMERIC(6)),3))/60,3)  AS work_time
	, SUM(sel4.trips) AS trips
	, round(avg(sel4.avg_load_length ),3) AS avg_load_length
	, string_agg(unload_name,', ') AS unload_name
	, (CASE WHEN POSITION (',' in (string_agg(unload_name,', ') )) >0 THEN 1 ELSE 0 END) AS step_calc
	--, (CASE WHEN POSITION (',' in (string_agg(unload_name,', ') )) >0 THEN avg(sel_n.norm_trips) ELSE avg(sel_n.norm_trips) END)	AS norm_trips	

FROM(
SELECT sel3.* 
 ,sel3.work_time/(11.17*60) AS work_time_shift
, veh_t.name AS truck_name
, veh_s.name AS shovel_name
, unload.name AS unload_name
--, model.name AS truck_model
, veh_t.model_id AS model_id
FROM (
SELECT
sel2.truck_id, sel2.shov_id, sel2.shiftdate, sel2.shiftnum
, 
round(sum( abs(extract(hour from  ( sel2.time_trip))*60)+ abs(extract(minute from ( sel2.time_trip)))+ abs(extract(second from ( sel2.time_trip))))::NUMERIC(6),3)
 AS work_time
, sum(sel2.trips) AS trips
, sel2.unload_id
, /*avg(sel2.load_length)*/
AVG(round(CAST(sel2.load_length as NUMERIC(6)),3)) AS avg_load_length
, sel2.load_type_id
FROM (
SELECT SUM(1) AS trips,	t.load_type_id, t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') AS shiftdate
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shiftnum
	, ROUND((cast(t.loaded_run_len AS NUMERIC(6))/1000),3) AS load_length
	, 	/*(case when t.begin_time_load IS NULL THEN 
			(CASE WHEN  t.turnround_begin_time is NULL THEN t.end_time- t.begin_time ELSE t.begin_time-t.turnround_begin_time END)
			 ELSE  
		 (CASE WHEN  t.turnround_begin_time is NULL THEN 
		 	t.end_time - t.begin_time_load else t.begin_time_load  - t.turnround_begin_time END) END)*/
			 (case when t.begin_time_load IS NULL THEN 
	 
		 	t.end_time - t.begin_time else t.end_time - t.begin_time_load   END) 
			  AS time_trip
	, t.unload_id
	
	FROM v8.vist_pit_trip t

	WHERE t.shov_id IS NOT null
		--and t.truck_id=41
		and 
		t.end_time between TO_timestamp('2024-04-09 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-13 12:00:00','yyyy-mm-dd hh24:mi:ss')
GROUP BY 
	t.load_type_id, t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') 
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) 
	, ROUND((cast(t.loaded_run_len AS NUMERIC(6))/1000),3) 
	,/*(t.begin_time_load-t.turnround_begin_time) */
	
	/*(case when t.begin_time_load IS NULL THEN 
			(CASE WHEN  t.turnround_begin_time is NULL THEN t.end_time- t.begin_time ELSE t.begin_time-t.turnround_begin_time END)
			 ELSE  
		 (CASE WHEN  t.turnround_begin_time is NULL THEN 
		 	t.end_time - t.begin_time_load else t.begin_time_load  - t.turnround_begin_time END) end)*/
		 	(case when t.begin_time_load IS NULL THEN 
	 
		 	t.end_time - t.begin_time else t.end_time - t.begin_time_load   END) 
	, t.unload_id

	) sel2
	GROUP BY sel2.truck_id, sel2.shov_id, sel2.shiftdate, sel2.shiftnum
		
		, sel2.unload_id
		, sel2.load_type_id
	) sel3
	LEFT JOIN v8.vist_core_vehicle veh_t
		ON veh_t.id = sel3.truck_id
	LEFT JOIN v8.vist_core_vehicle veh_s
		ON veh_s.id = sel3.shov_id
	LEFT JOIN v8.vist_core_geometry unload
		ON unload.id = sel3.unload_id
	LEFT JOIN v8.vist_core_model model
		ON model.id = veh_t.model_id
			
	ORDER BY sel3.truck_id, sel3.shiftdate, sel3.shiftnum 

	) sel4
		GROUP BY sel4.truck_name	, sel4.truck_id,sel4.shovel_name, sel4.shiftdate, sel4.shiftnum
		, sel4.load_type_id	,sel4.shov_id
		,sel4.model_id
	)sel5
	LEFT JOIN (SELECT 
		n_i.id AS norm_id,	n_i.distance_from ,n_i.distance_to ,n_i.n_trips AS norm_trips ,n_i.shovel_trip_norm_id,
	n_i.truck_model_id,	n_i.work_place_id,n_i.load_type_id 
	, n.begin_time, n.shovel_id
	
	FROM v8.vist_pit_shoveltripnormitem n_i

		LEFT JOIN 
			v8.vist_pit_shoveltripnorm n
			ON n.id = n_i.shovel_trip_norm_id
			WHERE TO_CHAR(n.begin_time,'yyyy.mm.dd hh24:mi:ss')||CAST(n.shovel_id AS CHAR(10)) IN 
				(SELECT TO_CHAR(MAX(n1.begin_time),'yyyy.mm.dd hh24:mi:ss')||CAST(n1.shovel_id AS CHAR(10)) FROM v8.vist_pit_shoveltripnorm n1 GROUP BY n1.shovel_id 
				)
	) sel_n 
		ON (sel_n.shovel_id = sel5.shov_id
			AND 
			ROUND((cast(sel5.avg_load_length  AS NUMERIC(6))),1)
			 
				BETWEEN  sel_n.distance_from and sel_n.distance_to
			AND sel_n.truck_model_id = sel5.model_id
			AND sel_n.load_type_id = sel5.load_type_id)
		LEFT JOIN 
		(/*количество рейсов самосвалов по разным экскаваторам*/
		SELECT SUM(1) AS trips_shovels,	t.load_type_id, t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') AS shiftdate
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shiftnum
	FROM v8.vist_pit_trip t
WHERE --t.shov_id = 146
		--t.truck_id=79
		--and 
		t.end_time between TO_timestamp('2024-04-09 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-13 12:00:00','yyyy-mm-dd hh24:mi:ss')
GROUP BY 
	t.load_type_id, t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') 
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) 
		) sel_trips_shovels
			ON (sel_trips_shovels.truck_id = sel5.truck_id and
			sel_trips_shovels.shov_id = sel5.shov_id and
			sel_trips_shovels.load_type_id = sel5.load_type_id and
			sel_trips_shovels.shiftdate = sel5.shiftdate and
			sel_trips_shovels.shiftnum = sel5.shiftnum)
		LEFT JOIN 
		(/*количество экскваторов у самосвалов*/
		SELECT count(DISTINCT t.shov_id) AS count_shovels, t.truck_id 
	, TO_CHAR(t.end_time,'yyyy.mm.dd') AS shiftdate
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shiftnum
	FROM v8.vist_pit_trip t
WHERE --t.shov_id = 146
		--t.truck_id=79
		--and 
		t.end_time between TO_timestamp('2024-04-09 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-13 12:00:00','yyyy-mm-dd hh24:mi:ss')
GROUP BY 
	 t.truck_id 
	, TO_CHAR(t.end_time,'yyyy.mm.dd') 
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) 
		) sel_count_shovels
			ON (sel_count_shovels.truck_id = sel5.truck_id and
			sel_count_shovels.shiftdate = sel5.shiftdate and
			sel_count_shovels.shiftnum = sel5.shiftnum)
		LEFT JOIN 
		(/*количество маршрутов у самосвалов по разным экскаваторам и видам работ*/
		SELECT count(distinct t.load_type_id) AS routes_shovels--,	t.load_type_id
		, t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') AS shiftdate
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) AS shiftnum
	FROM v8.vist_pit_trip t
WHERE --t.shov_id = 146
		--t.truck_id=79
		--and 
		t.end_time between TO_timestamp('2024-04-09 00:00:00','yyyy-mm-dd hh24:mi:ss')
AND TO_TIMESTAMP('2024-04-13 12:00:00','yyyy-mm-dd hh24:mi:ss')
GROUP BY 
	--t.load_type_id,
	 t.truck_id , t.shov_id
	, TO_CHAR(t.end_time,'yyyy.mm.dd') 
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) 
	ORDER BY 
	t.truck_id 
	, TO_CHAR(t.end_time,'yyyy.mm.dd') 
	, (CASE when cast(TO_CHAR(t.end_time,'hh24') as int) BETWEEN 0 AND 11 THEN 1 ELSE 2 END) 
	, t.shov_id
		) sel_routes_shovels
			ON (sel_routes_shovels.truck_id = sel5.truck_id and
			sel_routes_shovels.shov_id = sel5.shov_id and
			--sel_trips_shovels.load_type_id = sel4.load_type_id and
			sel_routes_shovels.shiftdate = sel5.shiftdate and
			sel_routes_shovels.shiftnum = sel5.shiftnum)

	/*
	
		, sel_n.norm_trips
		, sel_trips_shovels.trips_shovels
		, sel_count_shovels.count_shovels
		, sel_routes_shovels.routes_shovels*/
		ORDER BY sel5.truck_name, sel5.shiftdate, sel5.shiftnum	, sel5.shovel_name
		) sel6
		) sel7
		LEFT JOIN 
		(/*выборка простоев аварийных за смену, час*/

SELECT --sis.* 
	to_char(sis.shiftdate,'yyyy.mm.dd') AS shiftdate
	, sis.workregimedetail_id AS shiftnum
--	, sis.idle_type_id
	, sis.vehicle_id
	, ROUND((SUM(total_time :: float)/3600)::NUMERIC,3) as  idle_sum_h
	FROM v8.vist_core_shiftidlestat sis
	
	WHERE sis.idle_type_id IN (
SELECT it.id FROM v8.vist_core_idletype it
	WHERE it.analytic_category_id = 1)
	--and vehicle_id=5
		AND sis.shiftdate>=TO_timestamp('2024-01-01 ','yyyy-mm-dd')
	GROUP BY 	sis.shiftdate, sis.workregimedetail_id
	--, sis.idle_type_id
	, sis.vehicle_id
	ORDER BY sis.vehicle_id, sis.shiftdate, sis.workregimedetail_id) idle_shift
		ON idle_shift.shiftdate = sel7.shiftdate and
			idle_shift.shiftnum = sel7.shiftnum and
			idle_shift.vehicle_id = sel7.truck_id 
		GROUP BY  sel7.truck_name, sel7.shiftdate, sel7.shiftnum, sel7.truck_id
			,  idle_shift.idle_sum_h, idle_shift.shiftdate, idle_shift.shiftnum, idle_shift.vehicle_id