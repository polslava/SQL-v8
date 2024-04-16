SELECT sp.*,
	sv.volume
	,sv.day
	, (sp.date+ sv.day-1) AS shiftdate
	,sv.number AS shiftnum
	,veh.name AS shovel_name
	 FROM v8.vist_pit_shiftmonthplan sp
/* TABLE "vist_pit_shiftmonthplan" (
	"id" SERIAL NOT NULL,
	"date" DATE NOT NULL,
	"approved" BOOLEAN NOT NULL,
	"shovel_id" INTEGER NOT NULL,
	"work_place_id" INTEGER NULL DEFAULT NULL,
	"work_type_id" INTEGER NOT NULL,
	"load_type_id" INTEGER NOT NULL*/
	LEFT JOIN v8.vist_pit_shiftmonthplanfactvolume sv
		ON sv.plan_id = sp.id
	/*TABLE "vist_pit_shiftmonthplanfactvolume" (
	"id" SERIAL NOT NULL,
		"id" SERIAL NOT NULL,
	"number" SMALLINT NOT NULL,
	"day" SMALLINT NOT NULL,
	"volume" DOUBLE PRECISION NOT NULL,
	"distance" NUMERIC(6,2) NOT NULL,
	"quality" VARCHAR(256) NULL DEFAULT NULL,
	"is_default" BOOLEAN NOT NULL,
	"plan_id" INTEGER NOT NULL,
	"plan_details_id" INTEGER NULL DEFAULT NULL,
	"unload_id" INTEGER NULL DEFAULT NULL,
	"block_number" SMALLINT NULL DEFAULT NULL,
	"created_at" TIMESTAMPTZ NOT NULL
	*/
		LEFT JOIN v8.vist_core_vehicle veh
 		ON veh.id = sp.shovel_id  
 	WHERE veh.name IN ('06292№4','06322_№7','20292№2','Bucyrus1','Bucyrus2',
		 'Ex_2500 №5','Ex_2600 №3','Ex_3600 №8','PC1250_№1','PC4000_№10','PC4000_№11','PC4000_№9',
		 'XCMG XE2000 №6','ЭКГ-5А(8185)')
		 AND sv.volume >0
		 AND veh.id = 146
