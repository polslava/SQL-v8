SELECT pass.*
	, veh.name 
	, pass_it.* --n_bucket, pass_it.truck_model_id, pass_it.load_type_id
	FROM v8.vist_pit_shovelloadpassport pass
		LEFT JOIN v8.vist_core_vehicle veh
			ON veh.id = pass.shovel_id
		LEFT JOIN v8.vist_pit_shovelloadpassportitem pass_it
			ON pass_it.passport_id = pass.id
		WHERE veh.name IN ('06292№4','06322_№7','20292№2','Bucyrus1','Bucyrus2',
		 'Ex_2500 №5','Ex_2600 №3','Ex_3600 №8','PC1250_№1','PC4000_№10','PC4000_№11','PC4000_№9',
		 'XCMG XE2000 №6','ЭКГ-5А(8185)') --список экскаваторов
		 AND cast(pass.shovel_id AS CHAR)||to_char(pass.begin_time,'dd.mm.yyyy hh24:mi:ss') IN 
			(SELECT cast(pass_1.shovel_id AS CHAR)
				|| to_char(max(BEGIN_time),'dd.mm.yyyy hh24:mi:ss') AS max_time
				FROM v8.vist_pit_shovelloadpassport pass_1 
				GROUP BY pass_1.shovel_id) -- последние па времени паспорта
