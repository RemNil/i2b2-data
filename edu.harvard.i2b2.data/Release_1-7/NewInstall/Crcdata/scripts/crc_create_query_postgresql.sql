/*==============================================================*/
/* PostgreSQL Database Script to create CRC query tables         */
/*==============================================================*/


/*============================================================================*/
/* Table: QT_QUERY_MASTER 											          */
/*============================================================================*/
CREATE TABLE QT_QUERY_MASTER (
	QUERY_MASTER_ID		SERIAL PRIMARY KEY,
	NAME				VARCHAR(250) NOT NULL,
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	MASTER_TYPE_CD		VARCHAR(2000),
	PLUGIN_ID			INT,
	CREATE_DATE			TIMESTAMP NOT NULL,
	DELETE_DATE			TIMESTAMP,
	DELETE_FLAG			VARCHAR(3),
	REQUEST_XML			TEXT,
	GENERATED_SQL		TEXT,
	I2B2_REQUEST_XML	TEXT,
	PM_XML				TEXT
)
;
CREATE INDEX QT_IDX_QM_UGID ON QT_QUERY_MASTER(USER_ID,GROUP_ID,MASTER_TYPE_CD);


/*============================================================================*/
/* Table: QT_QUERY_RESULT_TYPE										          */
/*============================================================================*/
CREATE TABLE QT_QUERY_RESULT_TYPE (
	RESULT_TYPE_ID				INT   PRIMARY KEY,
	NAME						VARCHAR(100),
	DESCRIPTION					VARCHAR(200),
	DISPLAY_TYPE_ID				VARCHAR(500),
	VISUAL_ATTRIBUTE_TYPE_ID	VARCHAR(3)
)
;


/*============================================================================*/
/* Table: QT_QUERY_STATUS_TYPE										          */
/*============================================================================*/
CREATE TABLE QT_QUERY_STATUS_TYPE (
	STATUS_TYPE_ID	INT   PRIMARY KEY,
	NAME			VARCHAR(100),
	DESCRIPTION		VARCHAR(200)
)
;


/*============================================================================*/
/* Table: QT_QUERY_INSTANCE 										          */
/*============================================================================*/
CREATE TABLE QT_QUERY_INSTANCE (
	QUERY_INSTANCE_ID	SERIAL PRIMARY KEY,
	QUERY_MASTER_ID		INT,
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	BATCH_MODE			VARCHAR(50),
	START_DATE			TIMESTAMP NOT NULL,
	END_DATE			TIMESTAMP,
	DELETE_FLAG			VARCHAR(3),
	STATUS_TYPE_ID		INT,
	MESSAGE				TEXT,
	CONSTRAINT QT_FK_QI_MID FOREIGN KEY (QUERY_MASTER_ID)
		REFERENCES QT_QUERY_MASTER (QUERY_MASTER_ID),
	CONSTRAINT QT_FK_QI_STID FOREIGN KEY (STATUS_TYPE_ID)
		REFERENCES QT_QUERY_STATUS_TYPE (STATUS_TYPE_ID)
)
;
CREATE INDEX QT_IDX_QI_UGID ON QT_QUERY_INSTANCE(USER_ID,GROUP_ID)
;
CREATE INDEX QT_IDX_QI_MSTARTID ON QT_QUERY_INSTANCE(QUERY_MASTER_ID,START_DATE)
;


/*=============================================================================*/
/* Table: QT_QUERY_RESULT_INSTANCE   								          */
/*============================================================================*/
	CREATE TABLE QT_QUERY_RESULT_INSTANCE (
	RESULT_INSTANCE_ID	SERIAL PRIMARY KEY,
	QUERY_INSTANCE_ID	INT,
	RESULT_TYPE_ID		INT NOT NULL,
	SET_SIZE			INT,
	START_DATE			TIMESTAMP NOT NULL,
	END_DATE			TIMESTAMP,
	STATUS_TYPE_ID		INT NOT NULL,
	DELETE_FLAG			VARCHAR(3),
	MESSAGE				TEXT,
	DESCRIPTION			VARCHAR(200),
	REAL_SET_SIZE		INT,
	OBFUSC_METHOD		VARCHAR(500),
	CONSTRAINT QT_FK_QRI_RID FOREIGN KEY (QUERY_INSTANCE_ID)
		REFERENCES QT_QUERY_INSTANCE (QUERY_INSTANCE_ID),
	CONSTRAINT QT_FK_QRI_RTID FOREIGN KEY (RESULT_TYPE_ID)
		REFERENCES QT_QUERY_RESULT_TYPE (RESULT_TYPE_ID),
	CONSTRAINT QT_FK_QRI_STID FOREIGN KEY (STATUS_TYPE_ID)
		REFERENCES QT_QUERY_STATUS_TYPE (STATUS_TYPE_ID)
)
;


/*============================================================================*/
/* Table: QT_PATIENT_SET_COLLECTION									          */
/*============================================================================*/
CREATE TABLE QT_PATIENT_SET_COLLECTION ( 
	PATIENT_SET_COLL_ID	BIGSERIAL PRIMARY KEY,
	RESULT_INSTANCE_ID	INT,
	SET_INDEX			INT,
	PATIENT_NUM			INT,
	CONSTRAINT QT_FK_PSC_RI FOREIGN KEY (RESULT_INSTANCE_ID )
		REFERENCES QT_QUERY_RESULT_INSTANCE (RESULT_INSTANCE_ID)
)
;
CREATE INDEX QT_IDX_QPSC_RIID ON QT_PATIENT_SET_COLLECTION(RESULT_INSTANCE_ID)
;


/*============================================================================*/
/* Table: QT_PATIENT_ENC_COLLECTION									          */
/*============================================================================*/
CREATE TABLE QT_PATIENT_ENC_COLLECTION (
	PATIENT_ENC_COLL_ID	SERIAL PRIMARY KEY,
	RESULT_INSTANCE_ID	INT,
	SET_INDEX			INT,
	PATIENT_NUM			INT,
	ENCOUNTER_NUM		INT,
	CONSTRAINT QT_FK_PESC_RI FOREIGN KEY (RESULT_INSTANCE_ID)
		REFERENCES QT_QUERY_RESULT_INSTANCE(RESULT_INSTANCE_ID)
)
;


/*============================================================================*/
/* Table: QT_XML_RESULT												          */
/*============================================================================*/
CREATE TABLE QT_XML_RESULT (
	XML_RESULT_ID		SERIAL PRIMARY KEY,
	RESULT_INSTANCE_ID	INT,
	XML_VALUE			TEXT,
	CONSTRAINT QT_FK_XMLR_RIID FOREIGN KEY (RESULT_INSTANCE_ID)
		REFERENCES QT_QUERY_RESULT_INSTANCE (RESULT_INSTANCE_ID)
)
;


/*============================================================================*/
/* Table: QT_ANALYSIS_PLUGIN										          */
/*============================================================================*/
CREATE TABLE QT_ANALYSIS_PLUGIN (
	PLUGIN_ID			INT NOT NULL,
	PLUGIN_NAME			VARCHAR(2000),
	DESCRIPTION			VARCHAR(2000),
	VERSION_CD			VARCHAR(50),	--support for version
	PARAMETER_INFO		TEXT,			-- plugin parameter stored as xml
	PARAMETER_INFO_XSD	TEXT,
	COMMAND_LINE		TEXT,
	WORKING_FOLDER		TEXT,
	COMMANDOPTION_CD	TEXT,
	PLUGIN_ICON         TEXT,
	STATUS_CD			VARCHAR(50),	-- active,deleted,..
	USER_ID				VARCHAR(50),
	GROUP_ID			VARCHAR(50),
	CREATE_DATE			TIMESTAMP,
	UPDATE_DATE			TIMESTAMP,
	CONSTRAINT ANALYSIS_PLUGIN_PK PRIMARY KEY(PLUGIN_ID)
)
;
CREATE INDEX QT_APNAMEVERGRP_IDX ON QT_ANALYSIS_PLUGIN(PLUGIN_NAME,VERSION_CD,GROUP_ID);


/*============================================================================*/
/* Table: QT_ANALYSIS_PLUGIN_RESULT_TYPE							          */
/*============================================================================*/
CREATE TABLE QT_ANALYSIS_PLUGIN_RESULT_TYPE (
	PLUGIN_ID		INT,
	RESULT_TYPE_ID	INT,
	CONSTRAINT ANALYSIS_PLUGIN_RESULT_PK PRIMARY KEY(PLUGIN_ID,RESULT_TYPE_ID)
)
;


/*============================================================================*/
/* Table: QT_PRIVILEGE												          */
/*============================================================================*/
CREATE TABLE QT_PRIVILEGE(
	PROTECTION_LABEL_CD		VARCHAR(1500),
	DATAPROT_CD				VARCHAR(1000),
	HIVEMGMT_CD				VARCHAR(1000),
	PLUGIN_ID				INT
)
;


/*============================================================================*/
/* Table: QT_BREAKDOWN_PATH											          */
/*============================================================================*/
CREATE TABLE QT_BREAKDOWN_PATH (
	NAME			VARCHAR(100), 
	VALUE			VARCHAR(2000), 
	CREATE_DATE		TIMESTAMP,
	UPDATE_DATE		TIMESTAMP,
	USER_ID			VARCHAR(50)
)
;


/*============================================================================*/
/* Table:QT_PDO_QUERY_MASTER 										          */
/*============================================================================*/
CREATE TABLE QT_PDO_QUERY_MASTER (
	QUERY_MASTER_ID		SERIAL PRIMARY KEY,
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	CREATE_DATE			TIMESTAMP NOT NULL,
	REQUEST_XML			TEXT,
	I2B2_REQUEST_XML	TEXT
)
;
CREATE INDEX QT_IDX_PQM_UGID ON QT_PDO_QUERY_MASTER(USER_ID,GROUP_ID);



-- DX
CREATE GLOBAL TEMPORARY TABLE DX  (
	ENCOUNTER_NUM	INT,
	PATIENT_NUM		INT,
	INSTANCE_NUM	INT,
	CONCEPT_CD 		varchar(50), 
	START_DATE 		TIMESTAMP,
	PROVIDER_ID 	varchar(50), 
	temporal_start_date TIMESTAMP, 
	temporal_end_date TIMESTAMP	
	
 ) on COMMIT PRESERVE ROWS
;

create  GLOBAL TEMPORARY TABLE TEMP_PDO_INPUTLIST    ( 
char_param1 varchar(100)
 ) ON COMMIT PRESERVE ROWS
;


-- QUERY_GLOBAL_TEMP
CREATE GLOBAL TEMPORARY TABLE QUERY_GLOBAL_TEMP   ( 
	ENCOUNTER_NUM	INT,
	PATIENT_NUM		INT,
	INSTANCE_NUM	INT ,
	CONCEPT_CD      VARCHAR(50),
	START_DATE	    DATE,
	PROVIDER_ID     VARCHAR(50),
	PANEL_COUNT		INT,
	FACT_COUNT		INT,
	FACT_PANELS		INT
 ) on COMMIT PRESERVE ROWS
;

-- GLOBAL_TEMP_PARAM_TABLE
 CREATE GLOBAL TEMPORARY TABLE GLOBAL_TEMP_PARAM_TABLE   (
	SET_INDEX	INT,
	CHAR_PARAM1	VARCHAR(500),
	CHAR_PARAM2	VARCHAR(500),
	NUM_PARAM1	INT,
	NUM_PARAM2	INT
) ON COMMIT PRESERVE ROWS
;

-- GLOBAL_TEMP_FACT_PARAM_TABLE
CREATE GLOBAL TEMPORARY TABLE GLOBAL_TEMP_FACT_PARAM_TABLE   (
	SET_INDEX	INT,
	CHAR_PARAM1	VARCHAR(500),
	CHAR_PARAM2	VARCHAR(500),
	NUM_PARAM1	INT,
	NUM_PARAM2	INT
) ON COMMIT PRESERVE ROWS
;

-- MASTER_QUERY_GLOBAL_TEMP
CREATE GLOBAL TEMPORARY TABLE MASTER_QUERY_GLOBAL_TEMP    ( 
	ENCOUNTER_NUM	INT,
	PATIENT_NUM		INT,
	INSTANCE_NUM	INT ,
	CONCEPT_CD      VARCHAR(50),
	START_DATE	    DATE,
	PROVIDER_ID     VARCHAR(50),
	MASTER_ID		VARCHAR(50),
	LEVEL_NO		INT,
	TEMPORAL_START_DATE DATE,
	TEMPORAL_END_DATE DATE
 ) ON COMMIT PRESERVE ROWS
;



--------------------------------------------------------
--INIT WITH SEED DATA
--------------------------------------------------------
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(1,'QUEUED',' WAITING IN QUEUE TO START PROCESS');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(2,'PROCESSING','PROCESSING');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(3,'FINISHED','FINISHED');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(4,'ERROR','ERROR');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(5,'INCOMPLETE','INCOMPLETE');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(6,'COMPLETED','COMPLETED');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(7,'MEDIUM_QUEUE','MEDIUM QUEUE');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(8,'LARGE_QUEUE','LARGE QUEUE');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(9,'CANCELLED','CANCELLED');
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(10,'TIMEDOUT','TIMEDOUT');


insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(1,'PATIENTSET','Patient set','LIST','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(2,'PATIENT_ENCOUNTER_SET','Encounter set','LIST','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(3,'XML','Generic query result','CATNUM','LH');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(4,'PATIENT_COUNT_XML','Number of patients','CATNUM','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(5,'PATIENT_GENDER_COUNT_XML','Gender patient breakdown','CATNUM','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(6,'PATIENT_VITALSTATUS_COUNT_XML','Vital Status patient breakdown','CATNUM','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(7,'PATIENT_RACE_COUNT_XML','Race patient breakdown','CATNUM','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(8,'PATIENT_AGE_COUNT_XML','Age patient breakdown','CATNUM','LA');
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(9,'PATIENTSET','Timeline','LIST','LA');


insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('PDO_WITHOUT_BLOB','DATA_LDS','USER');
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('PDO_WITH_BLOB','DATA_DEID','USER');
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('SETFINDER_QRY_WITH_DATAOBFSC','DATA_OBFSC','USER');
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('SETFINDER_QRY_WITHOUT_DATAOBFSC','DATA_AGG','USER');
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('UPLOAD','DATA_OBFSC','MANAGER');
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD,DATAPROT_CD,HIVEMGMT_CD) values ('SETFINDER_QRY_WITH_LGTEXT','DATA_DEID','USER'); 
















