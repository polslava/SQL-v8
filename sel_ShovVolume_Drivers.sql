SELECT shov_name AS shov_name,
       shov_driver_fio AS shov_driver_fio,
       DATE_TRUNC('day', shift_date) AS shift_date,
       shift_name AS shift_name,
       sum(volume) AS "SUM(Объём)"
FROM
  (select trip.id,
          trip.begin_lon,
          trip.begin_lat,
          trip.end_lon,
          trip.end_lat,
          trip.height_load,
          trip.height_unload,
          trip.course_unload,
          trip.avg_speed_loaded,
          trip.avg_speed_unloaded,
          trip.load_arrive_time,
          trip.load_depart_time,
          trip.load_duration,
          trip.load_checkpoint_time,
          trip.load_arrive_waiting_zone,
          trip.loaded_run_len,
          trip.loaded_run_len_reduced,
          trip.loaded_run_duration,
          trip.loaded_run_len_by_transitions,
          trip.unload_run_begin_time,
          trip.unload_run_begin_fuel,
          trip.unload_arrive_time,
          trip.unload_depart_time,
          trip.unload_duration,
          trip.unloaded_run_len,
          trip.unloaded_run_duration,
          trip.unloaded_run_len_reduced,
          trip.wait_for_load_duration,
          trip.wait_for_load_in_queue_duration,
          trip.wait_for_load_in_stoppage_duration,
          trip.wait_for_unload_duration,
          trip.wait_for_unload_in_queue_duration,
          trip.weight_std,
          trip.weight,
          trip.weight_by_scale,
          trip.weight_on_unload,
          trip.weight_on_load,
          trip.volume_std,
          trip.volume,
          trip.buckets_count_by_weight,
          trip.set_to_load_begin,
          trip.set_to_load_end,
          trip.set_to_load_duration,
          trip.set_to_load_len,
          trip.set_to_load_maneuver_len,
          trip.set_to_unload_begin,
          trip.set_to_unload_end,
          trip.set_to_unload_duration,
          trip.set_to_unload_len,
          trip.set_to_unload_maneuver_len,
          trip.load_waiting_time,
          trip.begin_time,
          trip.begin_time_load,
          trip.end_time,
          trip.turnround_begin_time,
          trip.fuel_begin,
          trip.fuel_end,
          trip.last_modified,
          trip.is_manual,
          trip.dynamic_weight,
          trip.update_time,
          enterprise."name" as enterprise_name,
          truck_vehicle.id as truck_id,
          truck_vehicle."name" as truck_name,
          truck_vmodel."name" as truck_model_name,
          truck_pmodel.weight_capacity as truck_weight_capacity,
          shov_vehicle.id as shov_id,
          shov_vehicle."name" as shov_name,
          shov_vmodel.name as shov_model_name,
          unload_geometry."name" as unload_name,
          loadtype."name" as loadtype_name,
          worktype."name" as worktype_name,
          workplace.name as workplace_name,
          truck_vehicle.default_workregime_id,
          to_char(date_trunc('day'::text, trip.end_time + shift.date_offset)::date, 'YYYY-MM') as shift_month,
          date_trunc('day'::text, trip.end_time + shift.date_offset)::date as shift_date,
          shift."name" as shift_name,
          shift.number as shift_number,
          concat(truck_driver.fam_name, ' ', truck_driver.first_name, ' ', truck_driver.second_name) as truck_driver_fio,
          truck_empl.employee_num as truck_driver_table_num,
          concat(shov_driver.fam_name, ' ', shov_driver.first_name, ' ', shov_driver.second_name) as shov_driver_fio,
          shov_empl.employee_num as shov_driver_table_num
   from v8.vist_pit_trip trip
   left join v8.vist_enterprise_enterprise enterprise on (enterprise.id = trip.enterprise_id)
   left join v8.vist_core_vehicle truck_vehicle on (truck_vehicle.id = trip.truck_id)
   left join v8.vist_core_model truck_vmodel on (truck_vmodel.id = truck_vehicle.model_id)
   left join v8.vist_pit_truckmodel truck_pmodel on (truck_pmodel.model_ptr_id = truck_vehicle.model_id)
   left join v8.vist_core_vehicle shov_vehicle on (shov_vehicle.id = coalesce(trip.shov_id, trip.shov_auto_id))
   left join v8.vist_core_model shov_vmodel on (shov_vmodel.id = shov_vehicle.model_id)
   left join v8.vist_core_geometry unload_geometry on (unload_geometry.id = coalesce(trip.unload_id, trip.unload_auto_id))
   left join v8.vist_core_loadtype loadtype on (loadtype.id = coalesce(trip.load_type_id, trip.load_type_auto_id))
   left join v8.vist_core_worktype worktype on (worktype.id = coalesce(trip.work_type_id, trip.work_type_auto_id))
   left join
     (select 1 AS marker,
             shift.id as work_regime_detail_id,
             shift.work_regime_id,
             shift.is_deleted,
             shift.deleted_at,
             shift.name,
             shift.begin_offset,
             shift.end_offset,
             shift.begin_break_offset,
             shift.end_break_offset,
             shift.number,
             make_interval(mins => shift.begin_offset) as begin_offset_interval,
             make_interval(mins => shift.end_offset) as end_offset_interval,
             '0 sec'::interval as date_offset
      FROM vist_enterprise_workregimedetail shift
      UNION ALL select 2 AS marker,
                       shift.id as work_regime_detail_id,
                       shift.work_regime_id,
                       shift.is_deleted,
                       shift.deleted_at,
                       shift.name,
                       shift.begin_offset,
                       shift.end_offset,
                       shift.begin_break_offset,
                       shift.end_break_offset,
                       shift.number,
                       make_interval(mins => shift.begin_offset) as begin_offset_interval,
                       make_interval(mins => shift.end_offset) as end_offset_interval,
                       '-1 day'::interval as date_offset
      FROM vist_enterprise_workregimedetail shift
      UNION ALL select 3 AS marker,
                       shift.id as work_regime_detail_id,
                       shift.work_regime_id,
                       shift.is_deleted,
                       shift.deleted_at,
                       shift.name,
                       shift.begin_offset,
                       shift.end_offset,
                       shift.begin_break_offset,
                       shift.end_break_offset,
                       shift.number,
                       make_interval(mins => shift.begin_offset) as begin_offset_interval,
                       make_interval(mins => shift.end_offset) as end_offset_interval,
                       '1 day'::interval as date_offset
      FROM vist_enterprise_workregimedetail shift) shift on (shift.work_regime_detail_id = trip.work_regime_detail_id)
   or (shift.work_regime_id = truck_vehicle.default_workregime_id
       and trip.end_time >= (date_trunc('day'::text, trip.end_time) + shift.begin_offset_interval + shift.date_offset)
       and trip.end_time < (date_trunc('day'::text, trip.end_time) + shift.end_offset_interval + shift.date_offset))
   left join vist_city_shifttask truck_task on truck_task.vehicle_id = trip.truck_id
   and trip.end_time >= truck_task.time_begin
   and trip.end_time <= truck_task.time_end
   left join vist_enterprise_employee truck_empl on truck_empl.id = truck_task.driver_id
   left join vist_enterprise_person truck_driver on truck_driver.id = truck_empl.person_id
   left join vist_city_shifttask shov_task on shov_task.vehicle_id = coalesce(trip.shov_id, trip.shov_auto_id)
   and trip.end_time >= shov_task.time_begin
   and trip.end_time <= shov_task.time_end
   left join vist_enterprise_employee shov_empl on shov_empl.id = shov_task.driver_id
   left join vist_enterprise_person shov_driver on shov_driver.id = shov_empl.person_id
   left join vist_pit_shovelworkplacearchive workplace_arch on workplace_arch.shovel_id = coalesce(trip.shov_id, trip.shov_auto_id)
   and trip.begin_time >= workplace_arch.begin_time
   and trip.begin_time <= coalesce(workplace_arch.end_time, 'infinity'::timestamp with time zone)
   left join vist_core_workplace workplace on workplace_arch.work_place_id = workplace.id
   where not trip.is_deleted) AS virtual_table
WHERE load_arrive_time >= TO_TIMESTAMP('2023-12-31 20:00:00.000000', 'YYYY-MM-DD HH24:MI:SS.US')
  AND load_arrive_time < TO_TIMESTAMP('2024-01-31 20:00:00.000000', 'YYYY-MM-DD HH24:MI:SS.US')
GROUP BY shov_name,
         shov_driver_fio,
         DATE_TRUNC('day', shift_date),
         shift_name
ORDER BY "SUM(Объём)" DESC
LIMIT 50000;