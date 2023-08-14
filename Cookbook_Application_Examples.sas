/************************************************************
	%FILES
************************************************************/

%INCLUDE "/home/rafaqnunes0/Studies/Cookbook/Cookbook SAS Macros/Cookbook_SAS_Macros.sas";
%INCLUDE "/home/rafaqnunes0/Studies/Cookbook/Cookbook SAS Macros/Cookbook_Sets.sas";



/************************************************************
	%PRINT_MESSAGE
	SEND A CUSTOM MESSAGE
************************************************************/

%PRINT_MESSAGE("THIS IS MY SAS' MACROS COOKBOOKs! ENJOY IT!");
%PRINT_MESSAGE("AUTHOR: RAFAEL DE QUEIROZ NUNES");
%PRINT_MESSAGE("");



/************************************************************
	%timer(_OPCAO);
	SEND A CUSTOM MESSAGE
************************************************************/
%timer(1);
%PRINT_MESSAGE("Starting timer at %sysfunc(putn(&_TIMER_INITIAL., datetime20.))");


/************************************************************
	%isinteger(var); 
	SEND A CUSTOM MESSAGE
************************************************************/

%let var1 = %isinteger(934); 
%let var2 = %isinteger(934.0); 
%let var3 = %isinteger(93.4); 
%let var4 = %isinteger(amor);
%let var5 = %isinteger(5);
%PRINT_MESSAGE("Checking if the vars are integers from isinteger macro: 934 -> &var1., 934.0 -> &var2., 93.4 ->  &var3., amor ->  &var4., 5 ->  &var5.");
%PRINT_MESSAGE("");


/************************************************************
	%IsMacroVariableExists
	CHECK IF A MACRO VAR EXIST
************************************************************/
%LET CHECK1 = %IsMacroVariableExists(path_data);
%LET CHECK2 = %IsMacroVariableExists(path);

%PRINT_MESSAGE("Result of checking of Macro vars from %IsMacroVariableExists macro: path_data = &CHECK1. and path = &CHECK2.");
%PRINT_MESSAGE("That means just 'path_data' macro variable exists.");
%PRINT_MESSAGE("");



/************************************************************
	%ListFilesInFolder
	List all files from a path
************************************************************/

%ListFilesInFolder(&path_data.);

TITLE DATA LIST WITH ListFilesInFolder MACRO FROM &path_data. PATH ;
PROC PRINT DATA=_FILES;
PROC DELETE DATA=_FILES;
RUN;
TITLE;

%PRINT_MESSAGE("");



/************************************************************
	%create_folder
	Create a folder on the specific path
************************************************************/

%create_folder(&path_data./testfolder);

%PRINT_MESSAGE("Folder &path_data./testfolder was created.");
%PRINT_MESSAGE("");




/************************************************************
	%charColLength
	REDUCING THE SIZE OF COLUMN 'NAME' FROM 'TEST TABLE
************************************************************/

DATA TEST;
	INFILE DATALINES DSD MISSOVER DELIMITER="|";
	LENGTH ID 8 NAME $30 JOB $30;
	INPUT ID NAME JOB;
	DATALINES;
1|FERNANDA|RECEPCIONISTA
2|ANDRÉ|EMPREGADO
3|LEANDRO|ADVOGADO
4|ELIAS|MOTORISTA
5|IVANA|SECRETARIA
	;
RUN;

TITLE "CONTENT FROM 'TEST' TABLE BEFORE APPLYING charColLength FUNCTION";
ods select Variables;
proc contents data=TEST;
run;
ods select default;
TITLE;

%charColLength(TEST,NAME); /* REDUCING THE SIZE OF COLUMN 'NAME' FROM 'TEST TABLE*/

TITLE "CONTENT FROM 'TEST' TABLE BEFORE APPLYING charColLength FUNCTION (LENGTH OF 'NAME' IS REDUZED)";
ods select Variables;
proc contents data=TEST;
run;
ods select default;
TITLE;

/* REMOVE IT LATER*/
PROC DELETE DATA=TEST;
RUN;

%PRINT_MESSAGE("");



/************************************************************
	%charColLengths
	REDUCING THE SIZE OF ALL COLUMNS FROM 'TEST TABLE
************************************************************/

DATA TEST;
	INFILE DATALINES DSD MISSOVER DELIMITER="|";
	LENGTH ID 8 NAME $30 JOB $30;
	INPUT ID NAME JOB;
	DATALINES;
1|FERNANDA|RECEPCIONISTA
2|ANDRÉ|EMPREGADO
3|LEANDRO|ADVOGADO
4|ELIAS|MOTORISTA
5|IVANA|SECRETARIA
	;
RUN;

TITLE "CONTENT FROM 'TEST' TABLE BEFORE APPLYING charColLengths FUNCTION";
ods select Variables;
proc contents data=TEST;
run;
ods select default;
TITLE;

%charColLengths(TEST); /* REDUCING THE SIZE OF ALL COLUMNS FROM 'TEST TABLE */

TITLE "CONTENT FROM 'TEST' TABLE AFTER APPLYING charColLengths FUNCTION";
ods select Variables;
proc contents data=TEST;
run;
ods select default;
TITLE;

/*
- CHECK THAT THE LENGTH OF COLUMN 'NAME' FROM 'TEST TABLE WAS REDUCED FROM 30 TO 8
- CHECK THAT THE LENGTH OF COLUMN 'NAME' FROM 'TEST TABLE WAS REDUCED FROM 30 TO 13
*/

/* REMOVE IT LATER*/

%PRINT_MESSAGE("");



/************************************************************
	%column_ds_pos
	GET COLUMNS POSITION
************************************************************/

/* USE 'TEST' TABLE FROM PREVIOUS RUN */

%LET VAR1 = %column_ds_pos(TEST,ID);
%LET VAR2 = %column_ds_pos(TEST,NAME);
%LET VAR3 = %column_ds_pos(TEST,JOB);
%LET VAR4 = %column_ds_pos(TEST,AGE);
%PUT &=VAR1 &=VAR2 &=VAR3 &=VAR4;

%PRINT_MESSAGE("Position of the columns of TEST table ID, NAME, JOB and AGE are respectfully (gotten from column_ds_pos macro): &VAR1, &VAR2., &VAR3. and &VAR4.. AGE is zero because is not on the table.");
%PRINT_MESSAGE("");




/************************************************************
	%file_fix_uplowcase_extension
	MAKES A EXTENSION FROM UPCASE TO LOWCASE (EXAMPLE: file.CSV -> file.csv)
************************************************************/

/* USE 'TEST' TABLE FROM PREVIOUS RUN */

PROC EXPORT DATA=TEST
    OUTFILE="&path_data./TEST.CSV"
    DBMS=csv
    REPLACE;
    DELIMITER=",";
RUN;

TITLE FILE &path_data./TEST.CSV was created from TEST data.;
PROC PRINT DATA=TEST;
RUN;
TITLE;

/* DELETE 'TEST' TABLE */
PROC DELETE DATA=TEST;
RUN;

%file_fix_uplowcase_extension(&path_data./TEST.CSV);

%PRINT_MESSAGE("TEST.CSV became TEST.csv.");
%PRINT_MESSAGE("");



/************************************************************
	%copy_paste_files(path_from,path_to,filename_text);
	Cut a file to another folder
************************************************************/

/* USE 'TEST' TABLE FROM PREVIOUS RUN */

%copy_cut_paste_files(2,&path_data.,&path_data./testfolder/,TEST.csv);

%PRINT_MESSAGE("TEST.csv was cut to &path_data./testfolder/");
%PRINT_MESSAGE("");



/************************************************************
	%copy_paste_files(path_from,path_to,filename_text);
	Copy a file to another folder
************************************************************/

/* USE 'TEST' TABLE FROM PREVIOUS RUN */

%copy_cut_paste_files(1,&path_data./testfolder/,&path_data.,TEST.csv);

%PRINT_MESSAGE("TEST.csv was copied to &path_data.");
%PRINT_MESSAGE("");



/************************************************************
	%delete_file
	DELETE 'TEST.CSV' EXPORTED FROM 'TEST' SAS TABLE
************************************************************/

/* USE 'TEST.csv' TABLE FROM PREVIOUS RUN */

%delete_file(&path_data./testfolder/TEST.csv);
%delete_file();

%PRINT_MESSAGE("&path_data./testfolder/TEST.csv was deleted with delete_file macro.");
%PRINT_MESSAGE("");



/************************************************************
	%excelworksheetexist
	CHECK IF EXCEL SHEET EXISTS
************************************************************/

* Correct sheet name;
%excelworksheetexist(/home/rafaqnunes0/Studies/Cookbook/Cookbook 2.0/Data_Example/People_Analytics.xlsx,BaseDados);
%put &=vexist_sheet; /* It will return 1 on log*/

%PRINT_MESSAGE("'BaseDados' sheet exists from People_Analytics.xlsx, because vexist_sheet = &vexist_sheet.");

* Incorrect sheet name;
%excelworksheetexist(/home/rafaqnunes0/Studies/Cookbook/Cookbook 2.0/Data_Example/People_Analytics.xlsx,BaseDadoss);
%put &=vexist_sheet; /* It will return 0 on log*/

%PRINT_MESSAGE("'BaseDadoss' sheet does not exist from People_Analytics.xlsx, because vexist_sheet = &vexist_sheet.");


%PRINT_MESSAGE("");



/************************************************************

	%standard_columns(vtablename);
	REDUCING THE SIZE OF ALL COLUMNS FROM 'PEOPLE_ANALYTICS' TABLE
	
	%clean_empty_rows(vtablename);
	REMOVE ROWS WITHOUT VALUES FROM 'PEOPLE_ANALYTICS' TABLE
	
	%drop_empty_columns(vtablename);
	DROP COLUMNS WITHOUT VALUES FROM 'PEOPLE_ANALYTICS' TABLE
	
************************************************************/

PROC IMPORT DATAFILE= "&path_data./People_Analytics.xlsx" 
	OUT= PEOPLE_ANALYTICS
	DBMS=XLSX
	REPLACE;
	SHEET="BaseDados"; 
	GETNAMES=YES;
RUN;

TITLE "'PEOPLE ANALYTCS' TABLE BEFORE APPLYING THE TREATING FUNCTIONS";
PROC PRINT DATA=PEOPLE_ANALYTICS;
RUN;

%standard_columns(PEOPLE_ANALYTICS); /* REDUCING THE SIZE OF ALL COLUMNS FROM 'PEOPLE_ANALYTICS' TABLE AND CLEAR LABELS*/
%clean_empty_rows(PEOPLE_ANALYTICS); /* REMOVE ROWS WITHOUT VALUES FROM 'PEOPLE_ANALYTICS' TABLE */
%drop_empty_columns(PEOPLE_ANALYTICS); /* DROP COLUMNS WITHOUT VALUES FROM 'PEOPLE_ANALYTICS' TABLE */

TITLE "'PEOPLE ANALYTCS' TABLE AFTER APPLYING THE TREATING FUNCTIONS";
PROC PRINT DATA=PEOPLE_ANALYTICS;
RUN;
TITLE;

%PRINT_MESSAGE("");



/************************************************************
	%removeMetadata
	REDUCING THE SIZE OF ALL COLUMNS FROM 'TEST TABLE
************************************************************/

/* LOAD PEOPLE_ANALYTICS IN PREVIOUS EXECUTION */

data PEOPLE_ANALYTICS; SET PEOPLE_ANALYTICS;
	LABEL
		N='Nº'
		ESTADO_CIVIL='Estado Civil'
		GRAU_INSTRUCAO='Grau de Instrução'
		N_FILHOS='Nº de filhos'
		SALARIO='Salário'
		IDADE_ANOS='Idade Anos'
		REG_PROCEDENCIA='Regime de Procedência'
		;
RUN;

TITLE PEOPLE ANALYTCS TABLE BEFORE REMOVING METADATA WITH removeMetadata FUNCTION;
proc sql;
   select name , FORMAT, INFORMAT, LABEL
	   from dictionary.columns
	   where libname='WORK' and memname='PEOPLE_ANALYTICS'
	;
run;
TITLE;

%removeMetadata(PEOPLE_ANALYTICS,FIL);

TITLE PEOPLE ANALYTCS TABLE AFTER REMOVING METADATA WITH removeMetadata FUNCTION;
proc sql;
   select name , FORMAT, INFORMAT, LABEL
	   from dictionary.columns
	   where libname='WORK' and memname='PEOPLE_ANALYTICS'
	;
run;
TITLE;

%PRINT_MESSAGE("");



/************************************************************
	%count_obs
	Counting the quantity of rows from 'PEOPLE_ANALYTICS' table
************************************************************/

/* LOAD PEOPLE_ANALYTICS IN PREVIOUS EXECUTION */

%let var_count = %count_obs(PEOPLE_ANALYTICS);

%PRINT_MESSAGE("Rows in 'People_Analytics' table (count_obs macro): &var_count.");
%PRINT_MESSAGE("");



/************************************************************
	%xcheck_column(DS,COL,CHECK_TYPE,DS_LOG,COL_LOG);
	Making checks on PEOPLE_ANALYTICS SAS Table with xcheck_column macro
************************************************************/

/* LOAD PEOPLE_ANALYTICS IN PREVIOUS EXECUTION */
%PRINT_MESSAGE("Using xcheck_column macro for check standard on 'PEOPLE_ANALYTICS' columns.");

%PRINT_MESSAGE("1. Check if column 'N' has only unique values.");
%xcheck_column(PEOPLE_ANALYTICS,N,1,TBL_CHECK_RETURN,LOGS); * Check if column 'N' has only unique values;

%PRINT_MESSAGE("2. Check if column 'ESTADO_CIVIL' has only unique values.");
%xcheck_column(PEOPLE_ANALYTICS,ESTADO_CIVIL,1,TBL_CHECK_RETURN,LOGS); * Check if column 'ESTADO_CIVIL' has only unique values;

%PRINT_MESSAGE("3. Check if column 'ESTADO_CIVIL' has only unique values together.");
%xcheck_column(PEOPLE_ANALYTICS,ESTADO_CIVIL REG_PROCEDENCIA,2,TBL_CHECK_RETURN,LOGS); * Check if column 'ESTADO_CIVIL' has only unique values together;

%PRINT_MESSAGE("4. Check if column 'N_FILHOS' has no empty values.");
%xcheck_column(PEOPLE_ANALYTICS,N_FILHOS,3,TBL_CHECK_RETURN,LOGS); * Check if column 'N_FILHOS' has no empty values;

%PRINT_MESSAGE("5. Check if column 'SALARIO' has no empty values.");
%xcheck_column(PEOPLE_ANALYTICS,SALARIO,3,TBL_CHECK_RETURN,LOGS); * Check if column 'SALARIO' has no empty values;

%PRINT_MESSAGE("6. Check if column 'N_FILHOS' has only 0 and 1.");
%xcheck_column(PEOPLE_ANALYTICS,N_FILHOS,4,TBL_CHECK_RETURN,LOGS); * Check if column 'N_FILHOS' has only 0 and 1;


TITLE Erros of checks return;
PROC PRINT DATA=TBL_CHECK_RETURN;

PROC DELETE DATA=TBL_CHECK_RETURN;

RUN;
TITLE;
%PRINT_MESSAGE("");



/************************************************************
	%timer(_OPCAO);
	SEND A CUSTOM MESSAGE
************************************************************/
%timer(2);
%PRINT_MESSAGE("It ended at %sysfunc(putn(&_TIMER_FINAL., datetime20.)), with seconds %sysfunc(putn(&_TIMER_DIF_T., commax21.0)) of proccess.");




