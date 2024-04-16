SELECT --sis.* 
	sis.shiftdate, sis.workregimedetail_id
	, sis.idle_type_id
	, sis.vehicle_id
	, (SUM(total_time :: float)/3600) as  idle_sum_h
	FROM v8.vist_core_shiftidlestat sis
	
	WHERE sis.idle_type_id IN (
SELECT it.id FROM v8.vist_core_idletype it
	WHERE it.analytic_category_id = 1)
	and vehicle_id=5
	GROUP BY 	sis.shiftdate, sis.workregimedetail_id
	, sis.idle_type_id
	, sis.vehicle_id
	ORDER BY sis.vehicle_id, sis.shiftdate, sis.workregimedetail_id