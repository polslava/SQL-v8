/*выборка простоев аварийных за смену, час*/

SELECT --sis.* 
	sis.shiftdate, sis.workregimedetail_id
--	, sis.idle_type_id
	, sis.vehicle_id
	, ROUND((SUM(total_time :: float)/3600)::NUMERIC,1) as  idle_sum_h
	FROM v8.vist_core_shiftidlestat sis
	
	WHERE sis.idle_type_id IN (
SELECT it.id FROM v8.vist_core_idletype it
	WHERE it.analytic_category_id = 1)
	 	AND sis.shiftdate>=TO_timestamp('2024-01-01 ','yyyy-mm-dd')
	and vehicle_id=41
	
	GROUP BY 	sis.shiftdate, sis.workregimedetail_id
	--, sis.idle_type_id
	, sis.vehicle_id
	ORDER BY sis.vehicle_id, sis.shiftdate, sis.workregimedetail_id