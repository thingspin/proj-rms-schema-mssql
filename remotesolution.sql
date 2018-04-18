/*=======================================================================*/
/* Remote Solution Database 생성 */
/*=======================================================================*/
-- Create Database
If (db_id(N'thingspin-v0') IS NULL)
BEGIN
	CREATE DATABASE "thingspin-v0"
END
GO
/*=======================================================================*/
/* Remote Solution User 생성 */
/*=======================================================================*/
-- Check SQL Server Login
IF SUSER_ID('thingspin') IS NULL
    CREATE LOGIN thingspin WITH PASSWORD = 'qwe123!!';
-- Check database user
IF USER_ID('thingspin') IS NULL
    CREATE USER thingspin FOR LOGIN thingspin;
GO
/*=======================================================================*/
/* Remote Solution 필수 Table 생성 */
/*=======================================================================*/
use "thingspin-v0"
--------------------------------------------------------------------------
-- 상위(ThingSPIN)에서 내려 주는 데이터
--------------------------------------------------------------------------
-- 제품 모델 Table
IF OBJECT_ID(N't_model', N'U') IS NULL
BEGIN
	CREATE TABLE t_model (
		MODEL_ID 	varchar(32)		NOT NULL PRIMARY KEY,
		DESCRIPTION	nvarchar(128)	NOT NULL,
	)
END
GO
-- 검사 항목 Table
IF OBJECT_ID(N't_inspection_property', N'U') IS NULL
BEGIN
	CREATE TABLE t_inspection_property (
		INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULL PRIMARY KEY,
		INSPECTION_PROPERTY_NAME	NVARCHAR(64)	NOT NULL,
		DESCRIPTION	nvarchar(128)	NOT NULL,
	)
END
GO
-- 모델별 조치기준
IF OBJECT_ID(N't_model_inspection_property', N'U') IS NULL
BEGIN
	CREATE TABLE t_model_inspection_property (
		MODEL_ID 					varchar(32)		NOT NULL FOREIGN KEY REFERENCES t_model(MODEL_ID),
		INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULL FOREIGN KEY REFERENCES t_inspection_property(INSPECTION_PROPERTY_INDEX),

		ALARM_CONTINUOUS_FAILED_MAX	decimal(2,0)	NULL,
		ALARM_CPK_MIN				FLOAT			NULL,
		ALARM_CPK_MAX				FLOAT			NULL,
		
		PRIMARY KEY(MODEL_ID, INSPECTION_PROPERTY_INDEX)
	)
END
GO
--------------------------------------------------------------------------
-- 검사기 프로그램에서 발생 시키는 데이터
--------------------------------------------------------------------------
-- 모델별 검사 설정 Table
IF OBJECT_ID(N't_quality_spec_values', N'U') IS NULL
BEGIN
	CREATE TABLE t_quality_spec_values (
		MODEL_ID					varchar(32) 	NOT NULL	FOREIGN KEY REFERENCES t_model(MODEL_ID),
		INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULL	FOREIGN KEY REFERENCES t_inspection_property(INSPECTION_PROPERTY_INDEX),
	
		SPEC_MIN					FLOAT			NULL,
		SPEC_MAX					FLOAT			NULL,
		
		-- thingspin manage field
		SDATE 			datetime 		NULL,
		
		PRIMARY KEY(MODEL_ID, INSPECTION_PROPERTY_INDEX)
	)
END
GO
-- 테스트 결과 Table
IF OBJECT_ID(N't_inspection', N'U') IS NULL
BEGIN
	CREATE TABLE t_inspection (
		ID					DECIMAL(32,0)	NOT NULL PRIMARY KEY,

		MODEL_ID			varchar(32)		NOT NULL FOREIGN KEY REFERENCES t_model(MODEL_ID),
		TIME_START			DATETIME		DEFAULT(getdate()),
		TIME_END			DATETIME		DEFAULT(getdate()),
		MACHINE				NVARCHAR(16)	NOT NULL,
		CHANNEL				TINYINT			NOT NULL,
		PASS				BIT				NULL,
		DEVICE_BLUETOOTH	VARCHAR(32)		NULL,
		DEVICE_MAC			VARCHAR(32)		NULL,
		DEVICE_BARCODE		VARCHAR(32)		NULL,

		-- thingspin manage field
		SDATE 				datetime 		NULL,
	)
END
GO
-- 테스트 결과 상세 Table
IF OBJECT_ID(N't_inspection_detail', N'U') IS NULL
BEGIN
	CREATE TABLE t_inspection_detail (
		INSPECTION_ID				DECIMAL(32,0)	NOT NULL	FOREIGN KEY REFERENCES t_inspection(ID), 
		INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULL	FOREIGN KEY REFERENCES t_inspection_property(INSPECTION_PROPERTY_INDEX),
		
		MEASUREMENT_VALUE			FLOAT			NULL,
		PASS						BIT				NOT NULL,
		LOGMSG						NVARCHAR(128)	NULL,

		PRIMARY KEY(INSPECTION_ID, INSPECTION_PROPERTY_INDEX)
	)
END
GO
/*=======================================================================*/
/* Remote Solution ThingSPIN 관리 Table 생성 */
/*=======================================================================*/
-- ThingSPIN Client(Beats) logging table
IF OBJECT_ID(N't_ws_log', N'U') IS NULL
BEGIN
	CREATE TABLE t_ws_log (
		WS_ID 		int 		identity(1,1) NOT NULL PRIMARY KEY,
		WS_TYPE 	varchar(4)	NOT NULL, /* 송신 or 수신 */
		REGDATE 	datetime	DEFAULT(getdate()),
	
		SRC			varchar(20)	NOT NULL,
		DEST		varchar(20)	NOT NULL,
		CONTENTS	text		NOT NULL,
	
		PASS		bit			NOT NULL,
		ERROR		text		NULL,
	)
END
GO
/*=======================================================================*/
