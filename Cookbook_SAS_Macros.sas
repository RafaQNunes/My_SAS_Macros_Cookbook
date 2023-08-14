/*----------------------------------------------------------------------------------+
------------------------------------------------------------------------------------+
| Descrition:      | SAS Macros Cookbook for reference and use
+---------------+-------------------------------------------------------------------+
| Date:  		   | 12/08/2023
| Developer:       | RAFAEL DE QUEIROZ NUNES <rafa.q.nunes@gmail.com>  
+---------------+-------------------+---------------+-------------------------------+
+---------------+-------------------+---------------+------------------------------*/




***************************************************************
*****************************************************
- FORMAT: MM_YY and M_YY
- EXAMPLE: 12_22 (december, 2022)
- UPDATED DATE (dd/mm/yyyy): 09/09/2022
*****************************************************;
proc format;
  picture M_YY (default=7)
    low - high = '%m_%y' (datatype=date)
  ;

  picture MM_YY (default=7)
    low - high = '%0m_%y' (datatype=date)
  ;
run;

/*
***** Exemple of format use:
proc format;
  picture M_YY (default=7)
    low - high = '%m_%y' (datatype=date)
  ;
  picture MM_YY (default=7)
    low - high = '%0m_%y' (datatype=date)
  ;
run;

%let data_test = '09SEP2022'd;

DATA _NULL_;
	CALL SYMPUT ('data_test_', PUT(INTNX('MONTH',&data_test.,0),DATE9.));
RUN;
DATA _NULL_;
	CALL SYMPUT ('test_mm_yy',PUT(INTNX('MONTH',"&data_test_."D,0),MM_YY.));
	CALL SYMPUT ('test_m_yy',PUT(INTNX('MONTH',"&data_test_."D,0),M_YY.));
RUN;

%put NOTE: formats -> &data_test_. &test_mm_yy. &test_m_yy.;
*/




***************************************************************
*****************************************************
- NAME: IsMacroVariableExists
- DESCRIPTION: checks if a macro variable exists
- UPDATED DATE (dd/mm/yyyy): 02/09/2022

------------ PARAMETERS ------------
- param: macro variable to be verified, without & and .

Example: %let var_flag = %IsMacroVariableExists(var1);*

------------ RETURN ------------
- Binary: 1 if exists, and 0 otherwise.
*****************************************************;

%macro IsMacroVariableExists(param);
	%local retmacro;
	%if %symexist(&param.) %then %do;
		%if %length(&&&param..) > 0
			%then %let retmacro = 1;
			%else %let retmacro = 0;
	%end; %else %let retmacro = 0;

	%if &retmacro. = 1
		%then 1;
		%else 0;
%mend IsMacroVariableExists;



***************************************************************
*****************************************************
- NAME: delete_file
- DESCRIPTION: deletes a file if it exists
- REFERENCE: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/mcrolref/n108rtvqj4uf7tn13tact6ggb6uf.htm
- UPDATED DATE (dd/mm/yyyy): 11/02/2022

------------ PARAMETERS ------------
- file: file to be deleted
*****************************************************;

%macro delete_file(file);
	%if %length(&file.) > 0 %then %do;
		%if %sysfunc(fileexist(&file.)) ge 1 %then %do;
		   %let rc=%sysfunc(filename(temp,&file.));
		   %let rc=%sysfunc(fdelete(&temp.));
		%end; %else %put The file &file. does not exist;
	%end; %else %put Insert a valid parameter value;
%mend delete_file; 



***************************************************************
*****************************************************
- NAME: ListFilesInFolder
- DESCRIPTION: creates a SAS table, _FILES, with the files on the informed path string
- UPDATED DATE (dd/mm/yyyy): 11/02/2022

------------ PARAMETERS ------------
* Path: string where you inform the folder path to check

------------ OUTPUT ------------
* SAS Table: _FILES
*****************************************************;

%macro ListFilesInFolder(Path);
%macro a();
%mend a;

	data _files;
		length fref $8 fname $200 _dir $50;
		did = filename(fref,"&Path.");
		did = dopen(fref);
		do i = 1 to dnum(did);
		  fname = dread(did,i);
		  output;
		end;
		did = dclose(did);
		did = filename(fref);
		keep fname;
	run;

%mend ListFilesInFolder;



***************************************************************
*****************************************************
- NAME: charColLength
- DESCRIPTION: reduces the size of a variable in a dataset according to the maximum number of characters in it
- UPDATED DATE (dd/mm/yyyy): 21/01/2021

------------ PARAMETERS ------------
- dsn: dataset to be checked
- col: column to be checked (if it's character)

*****************************************************;

%macro charColLength(dsn, col);
	%local length msgtype link;
	
	*Notes and logs errors;
   %let link=%STR(https://raw.githubusercontent.com/SASJedi/sas-macros/master/charcollength.sas);
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens a specified character column to fit the largest actual value.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
      %put &msgtype- dsn:    Name of the dataset to modified. Required.;
      %put;
      %put NOTE:   &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE-   Use ? or !HELP to print these notes.;
      %put NOTE-   Reference: &link;
      %return;
   %end; 
   %if %superq(dsn)=%str(?) %then %goto syntax;
   %let dsn=%qupcase(%superq(dsn));
   %if %superq(dsn)=%str(!HELP) %then %goto syntax;
   %if %superq(col)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a column name;
      %put;
      %goto syntax;
   %end;
   
   *Applying the macro length reduction;
	proc sql noprint;
		select max(length(&col)) 
		   into :Length
		  from &dsn
		;
		alter table &dsn modify &col char(&length);
	quit;
%mend;



***************************************************************
*****************************************************
- NAME: charColLengths
- DESCRIPTION: reduces the size of all variables in a dataset according to the maximum number of characters in them
- UPDATED DATE (dd/mm/yyyy): 21/01/2021

------------ PARAMETERS ------------
- dsn: dataset to be checked

------------ DEPENDENT MACROS ------------
- charColLength: this macro performs the reduction in columns for the dataset

*****************************************************;

%macro charColLengths(dsn);
   %local lib i msgtype link;
   
   *Notes and logs errors;
   %let link=%STR(https://raw.githubusercontent.com/SASJedi/sas-macros/master/charcollengths.sas);
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens all character columns in a table to fit largest actual value.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
      %put &msgtype- dsn:    Name of the dataset to modified. Required.;
      %put;
      %put NOTE:   &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE-   Use ? or !HELP to print these notes.;
      %put NOTE-   Reference: &link;
      %return;
   %end;
   
   %if %superq(dsn)=%str(?) %then %goto syntax;
   %let dsn=%qupcase(%superq(dsn));
   %if %superq(dsn)=%str(!HELP) %then %goto syntax;
   %let lib=%qscan(%superq(dsn),-1,.);
   %if %superq(dsn)=%superq(lib) %then %let lib=WORK;
   %let dsn=%qscan(%superq(dsn),-1,.);
   
   *Getting the quantity of data from the table and get it to &sqlobs;
   proc sql noprint;
	   select name 
	     into: name1- 
	     from dictionary.columns
	     where libname="&lib"
	       and memname="&dsn"
	       and type ='char' 
	   ;
   quit;
   
   * Iteratively call the charColLength macro ;
   %do i=1 %to &sqlobs;
   		%charColLength(&lib..&dsn,&&name&i)
   %end;
%mend;




***************************************************************
*****************************************************
- NAME: removeMetadata
- DESCRIPTION: macro which removes format, informat, and label from columns
- UPDATED DATE (dd/mm/yyyy): 21/01/2021
- SOURCE:
     Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
     This macro program (remove_metadata.sas) should be placed in your AUTOCALL path
 
------------ PARAMETERS ------------
- dsn: dataset whose metadata will be removed
- attribs: columns/parameters that will be reset
	* F: format, I: informat, L: label

*****************************************************;
%macro removeMetadata(dsn,attribs);

   %let MSGTYPE=NOTE;
   %if %SUPERQ(dsn)= %then %do;
         %let MSGTYPE=ERROR;
         %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
         %PUT &MSGTYPE-  You must specify the name of the data set to be modified;
         %PUT;

   %syntax:
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
         %put;
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%remove_metadata%(dsn,attribs%));
         %PUT &MSGTYPE-        DSN=data set to be modified;
         %PUT &MSGTYPE-    attribs=(optional) attributes to be modified, default is FIL;
         %PUT &MSGTYPE-            F=formats;
         %PUT &MSGTYPE-            I=informats;
         %PUT &MSGTYPE-            L=Labels;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  Remove all formats, informats and labels;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars%));
         %PUT;
         %PUT &MSGTYPE-  Remove informats and labels only;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars,LI%));
         %PUT;
         %PUT &MSGTYPE-  Remove only labels;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars,L%));
         %PUT;
         %PUT;
         %PUT &MSGTYPE-  *************************************************************;

         %RETURN;
   %end;
   %if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? %then %goto Syntax;
   %if %superq(attribs)= %then %let attribs=FIL;
   %else %let attribs=%qupcase(%superq(attribs));
   %let lib=%scan(%superq(dsn),1);
   %if %superq(lib)=%superq(dsn) %then %do;
         %let lib=WORK;
   %end; %else %do;
         %let dsn=%scan(%superq(dsn),-1);
   %end;

   proc datasets library=&lib nolist;
      modify &dsn;
      %if %index(%superq(attribs),F) %then %do;
            attrib _all_ format=;
      %end;
      %if %index(%superq(attribs),I) %then %do;
            attrib _all_ informat=;
      %end;
      %if %index(%superq(attribs),L) %then %do;
            attrib _all_ label="";
      %end;
   run;

   quit;

%mend;



***************************************************************
*****************************************************
- NAME: standard_columns
- DESCRIPTION: standardizes the column names of a SAS table, making them lowercase or numbers, without spaces, accents, or special characters
- UPDATED DATE (dd/mm/yyyy): 01/08/2022

------------ PARAMETERS ------------
- vtablename: dataset to have its column names standardized (including libname)

- EXAMPLE: standard_columns(LIB_NAME.TABLE_TEST)

*****************************************************;
%MACRO standard_columns(vtablename);
	%LOCAL vtablename temp_header check_counter list_rename;

	%if %sysfunc(exist(&vtablename.)) %then %do;

		*Create the table with the variables names of table;
		proc transpose data=&vtablename.(obs=0) out=temp_header;
			var _all_;
		run;
		
		*Standarize the variables names;
		data temp_header;
			set temp_header;
			_NAME_NEW1_ = BASECHAR(_NAME_);
			_NAME_NEW1_ = COMPRESS(_NAME_NEW1_, , 'kads');
			_NAME_NEW1_ = UPCASE(TRANWRD(STRIP(_NAME_NEW1_)," ","_"));
			_NAME_OLD_ = "'" || STRIP(_NAME_) || "'n";
		run;

		*Treat possible duplicated variables names;
		proc sort data=temp_header;
			by _NAME_NEW1_;
		run;
		data temp_header; set temp_header;
			retain counter 0; by _NAME_NEW1_;
			if first._NAME_NEW1_ then counter = 0; else counter + 1;
			if counter > 0 then str_counter = "_" || COMPRESS(counter+1); else str_counter = "";
			_NAME_NEW2_ = cats(_NAME_NEW1_,str_counter);
			_NAME_NEW2_ = "'" || STRIP(_NAME_NEW2_) || "'n";
			drop counter str_counter;
		run;

		*Update the variable names of the table;
		PROC SQL NOPRINT;
			SELECT COUNT(*)
				INTO :check_counter
				FROM temp_header (PW=POBJ2021)
				WHERE NOT _NAME_ = _NAME_NEW2_ ;
		QUIT;
		
		%IF &check_counter. > 0 %THEN %DO;
		
			PROC SQL NOPRINT;
				SELECT CATX("=", _NAME_OLD_, _NAME_NEW2_)
					INTO :list_rename SEPARATED BY " "
					FROM temp_header
					WHERE NOT _NAME_ = _NAME_NEW2_;
			QUIT;
			
			DATA &vtablename.; SET &vtablename.;
				RENAME &list_rename.;
				ATTRIB _all_ label=' ';
			RUN;
			
		%END;
		proc delete data=temp_header; run;

	%end; %else %put WARNING: table &vtablename does not exist.;
	
%MEND standard_columns;



***************************************************************
*****************************************************
- NAME: drop_empty_columns
- DESCRIPTION: clean empty columns from a dataset
- UPDATED DATE (dd/mm/yyyy): 06/04/2022
- SOURCE: https://communities.sas.com/t5/SAS-Programming/Delete-empty-columns/td-p/279878

------------ PARAMETERS ------------
- vtablename: dataset que vai ser colunas vazias limpas

------------ EXAMPLE ------------
%drop_empty_columns(LIB_NAME.TABLE_TEST)

*****************************************************;

%MACRO drop_empty_columns(vtablename);
	%LOCAL vtablename temp_drop_empty_column count_rows var_drop_empty_column;
	
	%if %sysfunc(exist(&vtablename.)) %then %do;
	
		*Counting rows and checking if there is some for the checking process;
		proc sql noprint;
			select count(*) into: count_rows
			from &vtablename.;
		quit;
		
		%if &count_rows. > 1 %then %do;

			*Create the frequency table;
			ods select none;
			ods output nlevels=temp_drop_empty_column;
			proc freq data=&vtablename. nlevels;
				tables _all_;
			run;
			ods select all;
			
			*Check how many columns should be cleaned;
			proc sql noprint;
				select tablevar into : var_drop_empty_column separated by ' '
				from temp_drop_empty_column 
				where NNonMissLevels=0;
			quit;
			
			*Drop empty columns;
			data &vtablename.;
				set &vtablename.(drop=&var_drop_empty_column);
			run;
			
			*drop temporary dataset;
			proc delete data=temp_drop_empty_column;
			run; 

		%end; %else %put NOTE: table &vtablename does not have lines to be checked.;
	%end; %else %put WARNING: table &vtablename does not exist.;

%MEND drop_empty_columns;




***************************************************************
*****************************************************
- NAME: clean_empty_rows
- DESCRIPTION: remove rows with no values
- UPDATED DATE (dd/mm/yyyy): 24/03/2022
- SOURCE: https://www.geeksforgeeks.org/sas-delete-empty-rows/

------------ PARAMETERS ------------
* vtablename: tabela SAS a ser verificada
*****************************************************;
%macro clean_empty_rows(vtablename);
	%if %sysfunc(exist(&vtablename.)) %then %do;
		OPTIONS missing = ' ';
		data &vtablename.; set &vtablename.;
		    if missing(cats(of _all_)) then delete;
		run;
	%end; %else %put WARNING: table &vtablename does not exist.;
%mend clean_empty_rows;




***************************************************************
*****************************************************
- NAME: column_ds_pos
- DESCRIPTION: check if a column exists on SAS Table
- UPDATED DATE (dd/mm/yyyy): 30/03/2022
- SOURCE: https://stackoverflow.com/questions/53622451/return-true-value-if-column-exists-in-sas-table

------------ PARAMETERS ------------
* ds: SAS Table to be checked
* var: column from SAS table to be checked

---------- OUTPUT ------------------
* Natural value of position on SAS value

---------- EXAMPLE ------------------
%LET COL_POS = %column_ds_pos(WORK.TABLESAS,COLUMN_NAME);

*****************************************************;
%macro column_ds_pos(ds,var);
	%local dsid ;
	%let dsid = %sysfunc(open(&ds));
	%if (&dsid)
		%then %sysfunc(varnum(&dsid,&var));
		%else 0;
	%let dsid = %sysfunc(close(&dsid));
%mend column_ds_pos;




***************************************************************
*****************************************************
- NAME: create_folder
- DESCRIPTION: create folder on right local. The previous folder must exist to work.
- UPDATED DATE (dd/mm/yyyy): 30/03/2022
- SOURCE: https://stackoverflow.com/questions/53622451/return-true-value-if-column-exists-in-sas-table

------------ PARAMETERS ------------
* dir_folder: path text of folder to be created
*****************************************************;
%macro create_folder(dir_folder);
	options dlcreatedir;
	LIBNAME _tmp_lib "&dir_folder.";
	LIBNAME _tmp_lib clear;
%mend create_folder;




***************************************************************
*****************************************************
- NAME: file_fix_uplowcase_extension
- DESCRIPTION: file' extension text becomes to lowcase. That's made for ease files proccess
- UPDATED DATE (dd/mm/yyyy): 07/06/2022
- SOURCE: N/A

------------ PARAMETERS ------------
* file_old: file name to be converted
*****************************************************;
%macro file_fix_uplowcase_extension(file_old);
	%local rc file_old file_new;
	data _NULL_;
		file_old = "&file_old.";
		if fileexist(file_old) then do;
			ext = lowcase(scan(strip(file_old),-1,"."));
			noext = substr(strip(file_old),1,length(strip(file_old))-length(strip(ext))-1);
			file_new = strip(noext) || "." || strip(ext);
			rc = rename(file_old, file_new, 'file');
			if strip(file_old) ~= strip(file_new) then 
				put 'NOTE: file ' file_old 'has been renamed to ' file_new '.';
		end; else put 'WARNING: File ' file_old ' does not exist.';
	run;
%mend file_fix_uplowcase_extension;



***************************************************************
*****************************************************
- NAME: excelworksheetexist
- DESCRIPTION: checks if a sheet on an Excel file exists
- UPDATED DATE (dd/mm/yyyy): 30/03/2022

------------ PARAMETERS ------------
* vworkbook: Excel file path
* vworksheet: Excel worksheet name

------------ EXAMPLES ------------
%LET EXIST = %excelworksheetexist(/home/rafaqnunes0/Studies/Cookbook/Cookbook 2.0/Data_Example/PESQ_QUAL_202209.xlsx, SUPER CLASSIC)

------------ OUTPUT MACRO VARIABLES ------------
vexist_sheet -> (0 OR 1)

*****************************************************;
%macro excelworksheetexist(vworkbook,vworksheet);
	%local vworkbook vworksheet; %global vexist_sheet;

	%if %sysfunc(fileexist(&vworkbook.)) ge 1 %then %do;
		libname _EXCEL xlsx "&vworkbook.";
		proc sql noprint;
			select count(*)
				into: vexist_sheet
				from (select * from dictionary.tables
				where
					upcase(strip(libname)) = '_EXCEL'
					and upcase(strip(memname)) = upcase(strip("&vworksheet."))
					) as data
					;
		quit;
		libname _EXCEL clear;
		%if (&vexist_sheet. > 0) %then %let vexist_sheet = 1;
	%end; %else %let vexist_sheet = 0;
	
	%put 'vexist_sheet = ' &vexist_sheet.;
	
%mend excelworksheetexist;



***************************************************************
*****************************************************
- NAME: count_obs
- DESCRIPTION: check the amount of the rows/registers from a SAS table
- UPDATED DATE (dd/mm/yyyy): 17/05/2022

------------ PARAMETERS ------------
* ds: LIB.DATASET

------------ NATURAL OUTPUT ------------
the amount of rows of SAS Table

*****************************************************;
%macro count_obs(ds);
	%let NOBS = -1;
	
	%if not %sysfunc(exist(&DS.)) %then %do;
		%put WARNING: dataset &DS. does not exist.;
		&NOBS
		%return;
	%end;

    %let DSID=%sysfunc(OPEN(&DS.,IN));
    %let NOBS=%sysfunc(ATTRN(&DSID.,NOBS));
    %let RC=%sysfunc(CLOSE(&DSID.));
    &NOBS
%mend count_obs;



***************************************************************
*****************************************************
- NAME: timer
- DESCRIPTION: it simulates a timer and gets time that is saved into vars
- UPDATED DATE (dd/mm/yyyy):

------------ PARAMETERS ------------
  * 1: It starts the timer
  * 2: It creates a partial time and/or a final time if it's the last one

------------ OUTPUT MACRO VARIABLES ------------
  - _TIMER_INITIAL: time which starts everything
  - _TIMER_FINAL: final time of all
  - _TIMER_PARC_ANT: previous partial time
  - _TIMER_DIF_T: difference between the final time and initial time
  - _TIMER_DIF_P: difference between the final time and previous partial time
******************************************************************************;

%MACRO timer(_OPTION);

	%GLOBAL _TIMER_INITIAL _TIMER_FINAL _TIMER_PARC_ANT _TIMER_DIF_T _TIMER_DIF_P;

	/* STARTS TIMER */
	%IF &_OPTION EQ 1 %THEN %DO;
		%LET _TIMER_INITIAL = %SYSFUNC(DATETIME());
		%LET _TIMER_PARC_ANT = %SYSFUNC(DATETIME());
		%LET _TIMER_FINAL = %SYSFUNC(DATETIME());
		
	/* PARCIAL TIME */
	%END; %ELSE %IF &_OPTION EQ 2 %THEN %DO;
		%LET _TIMER_PARC_ANT = &_TIMER_FINAL.;
		%LET _TIMER_FINAL = %SYSFUNC(DATETIME());
		%LET _TIMER_DIF_P = %SYSFUNC(SUM(&&_TIMER_FINAL., -&&_TIMER_PARC_ANT.));
		%LET _TIMER_DIF_T = %SYSFUNC(SUM(&&_TIMER_FINAL., -&&_TIMER_INITIAL.));
		
	%END; %ELSE %PUT WARNING: you must insert 1 or 2 on timer macro parameter;

%MEND timer;



***************************************************************
*****************************************************
- NAME: xcheck_column
- DESCRIPTION: Performs specific integrity checks on specific columns, based on verification type, with binary return and log in case of success or failure
- UPDATED DATE (dd/mm/yyyy): 22/09/2022

------------ PARAMETERS ------------
* 1 - DS - SAS Table to be checked
* 2 - COL - Columns that will undergo the check
* 3 - CHECK_TYPE - Verification type according to codes below:
    1 - If columns have only unique values (each)
    2 - If columns have only unique values (together)
    3 - If columns are not empty (each)
    4 - If columns are binary (0,1) (each)
* 4 - DS_LOG - SAS Table for log to save information
* 5 - COL_LOG - Column in the SAS Table for log to save column integrity inconsistencies

------------ RETURN ------------
* return: 0 or 1, with 1 for correct verification and 0 for errors based on verification type
* DS_LOG/COL_LOG: SAS Table and column for possible logs
****************************************************************;

%macro xcheck_column(DS,COL,CHECK_TYPE,DS_LOG,COL_LOG);
%macro aux(); %mend aux;
	%local clean_check string_var col_pos check_count values_var COL2;

	%let return=0;
	%let clean_check=1;

	%put NOTE: teste sendo feito com os seguintes parâmetros:
		&DS., &COL., &CHECK_TYPE., &DS_LOG., &COL_LOG.;

    **********************************************************************************
    **** Macro for saving errors or non-compatibilities on checks;
	%macro save_ds_log(_TEXT_LOG,_DS_LOG,_COL_LOG);
	%macro aux(); %mend aux;
		%local _col_pos;
		
		* Check if SAS table log exist;
		%if %sysfunc(exist(&_DS_LOG.)) %then %do;
			* Check if col on SAS log exists. If not, create it.;
			%let _col_pos = %column_ds_pos(&_DS_LOG.,&_COL_LOG.);
			%if &_col_pos. <= 0 %then %do;
				data &_DS_LOG.; set &_DS_LOG.;
					length &_COL_LOG. $300;
					stop;
				run;
			%end;
		%end; %else %do;
			* Create SAS Table if it does not exist;
			data &_DS_LOG.;
				length &_COL_LOG. $300;
				stop;
			run;
		%end;
		* Insert info on log table;
		data temp_log;
			length &_COL_LOG. $300;
			&_COL_LOG. = "&_TEXT_LOG.";
		data &_DS_LOG.; set &_DS_LOG. temp_log;
		proc delete data=temp_log;
		run;

	%mend save_ds_log;

	**********************************************************************************
	**** Check if SAS Table exist;
	%if %sysfunc(exist(&DS.)) = 0 %then %do;
		%put NOTE: SAS Table &DS. does not exist;
		%let clean_check=0;
		%let values_var = SAS Table: &DS.| SAS Table &DS. does not exist;
		%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
		%return;
	%end;


	**********************************************************************************
	**** Check by each column;

	%do i = 1 %To %eval(%sysfunc(Count(&COL.,%str( )))+1);

	* Loop through each column separated by space;
		%local var_t_&i.;
		%let var_t_&i. = %sysfunc(Scan(&COL., &i., %str( )));
		%let col_pos = %column_ds_pos(&ds.,&&var_t_&i..);

		* Checking if each column exists;
		%if &col_pos. >= 1 %then %do;

            *------------------------------------------------------------;
            * Check 1 - Unique values column (Each one);
			%if &CHECK_TYPE. = 1 %then %do;
				options nonotes;
				proc sort data=&DS. (keep=&&var_t_&i..) nouniquekey out=dstest1;
					by &&var_t_&i..;
				proc sort data=dstest1 nodupkey;
					by &&var_t_&i..;
				run;

				proc sql noprint;
					select count(*) into:check_count from dstest1;
					select &&var_t_&i.. into: values_var separated by ' | ' from dstest1;
				quit;

				* Log the verification of inconsistencies;
				%if &check_count. > 0 %then %do;
					%let clean_check=0;
					%let values_var = Dataset: &DS.| Coluna: &&var_t_&i..| Problema: valores duplicados| Valores problemáticos: &values_var..;
					%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
				%end;

				proc delete data=dstest1;
				run;
				options notes;

           *------------------------------------------------------------;
            * Check 3 - Non-empty columns (Each);
			%end; %else %if &CHECK_TYPE. = 3 %then %do;

				options nonotes;
				proc sql noprint;
					select count(*) into: check_count
						from &DS. where missing(&&var_t_&i..);
				quit;

				* Log the verification of inconsistencies;
				%if &check_count. > 0 %then %do;
					%let clean_check=0;
					%let values_var = Dataset: &DS.| Coluna: &&var_t_&i..| Problema: valores vazios indevidos;
					%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
				%end;
				options notes;

            *------------------------------------------------------------;
            * Check 4 - Columns are binary (0,1) (Each);
			%end; %else %if &CHECK_TYPE. = 4 %then %do;

				options nonotes;
				data _NULL_; set &DS. (obs=1);
				   call symput('values_var',strip(vtype(&&var_t_&i..)));
				run;
				 %if &values_var. = N %then %do;

					proc sql noprint;
						select count(*) into: check_count
							from &DS. where &&var_t_&i.. not in (0,1,.);
						select distinct &&var_t_&i.. into: values_var separated by ' | '
							from &DS. where &&var_t_&i.. not in (0,1,.);
					quit;

					* Log the verification of inconsistencies;
					%if &check_count. > 0 %then %do;
						%let clean_check=0;
						%let values_var = Dataset: &DS.| Coluna: &&var_t_&i..| Problema: coluna não é binária| Valores problemáticos: &values_var..;
						%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
					%end;
					
				%end; %else %do;
				
					* Log the verification of inconsistencies;
					%if &check_count. > 0 %then %do;
						%let clean_check=0;
						%let values_var = Dataset: &DS.| Coluna: &&var_t_&i..| Problema: coluna não é binária| Valores problemáticos: &values_var..;
						%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
					%end;

				%end;

				options notes;
			
			%end;

        *------------------------------------------------------------;
        * Column does not exist in the dataset;
		%end; %else %do;
			%let clean_check=0;
			%let values_var = Dataset: &DS.| Coluna: &&var_t_&i..| Problema: coluna do dataset não existe;
			%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
		%end;
	%end;


	**********************************************************************************
	**** Checks for all columns simultaneously;
	
	%if &clean_check. = 1 %then %do; *Verificação das colunas válidass;

        *------------------------------------------------------------;
        * Check 2 - Columns with only unique values (together);
		%if &CHECK_TYPE. = 2 %then %do;
			options nonotes;

			proc sort data=&DS. (keep=&COL.) nouniquekey out=dstest1;
				by &COL.;
			proc sort data=dstest1 nodupkey;
				by &COL.;
			run;

			%let COL2 = %sysfunc(tranwrd(&COL.,%STR( ),%STR(,)));

			proc sql noprint;
				select count(*) into:check_count from dstest1;
				select distinct catx(";",&COL2.) into:values_var separated by ' | ' from dstest1;
			quit;

			* Log the verification of inconsistencies;
			%if &check_count. > 0 %then %do;
				%let values_var = Dataset: &DS.| Coluna: &COL.| Problema: colunas não são únicas ao mesmo tempo | Valores problemáticos: &values_var..;
				%save_ds_log(&values_var.,&DS_LOG.,&COL_LOG.);
				%let clean_check=0;
			%end;

			proc delete data=dstest1;
			run;

			options notes;
		%end;
	%end;
	
    **********************************************************************************
    * Positive result if we have a positive return;
	%if &clean_check. = 1 %then %let return=1;

%mend xcheck_column;



***************************************************************
*****************************************************
- NAME: isinteger
- SOURCE: https://communities.sas.com/t5/SAS-Programming/Checking-if-macro-variable-is-numeric-or-not/td-p/512425
- DESCRIPTION: Check if it's an integer
- UPDATED DATE (dd/mm/yyyy): 22/09/2022

------------ PARAMETERS ------------
* 1 - str - macro variable or string to be verified

------------ RETURN ------------
* The macro itself

****************************************************************;

%macro isinteger(var); 
	%if %sysfunc(prxmatch('^-?\d+$',&var.)) = 1 %then 1; %else 0;
%mend; 




***************************************************************
*****************************************************
- NAME: copy_cut_paste_files
- DESCRIPTION: Copy or cut files from one path to another
- UPDATED DATE (dd/mm/yyyy): 12/08/2023
- AUTHOR: Rafael de Queiroz Nunes

------------ PARAMETERS ------------
* type: 1 -> copy file, 2 -> cut file
* path_from: folder path where the original file is
* path_to: folder path where the original file will be cut or copied
* filename_text: file name with extension

****************************************************************;

%macro copy_cut_paste_files(type,path_from,path_to,filename_text);
%macro aux(); %mend aux;
	%local vartemp1 vartemp2 file_from file_to;

	%let vartemp1 = %sysfunc(length(&path_from.));
	%let vartemp2 = %sysfunc(substr(&path_from., &vartemp1., 1));
	%if "&vartemp2." ~= "/" %then
		%let file_from = &path_from.%str(/)&filename_text.;
	%else %let file_from = &path_from.&filename_text.;

	%let vartemp1 = %sysfunc(length(&path_to.));
	%let vartemp2 = %sysfunc(substr(&path_to., &vartemp1., 1));
	%if "&vartemp2." ~= "/" %then
		%let file_to = &path_to.%str(/)&filename_text.;
	%else %let file_to = &path_to.&filename_text.;

	%let file_from = &file_from.;
	%let file_to = &file_to.;

	%if %sysfunc(fileexist(&file_from.)) %then %do;
		filename src "&file_from.";
		filename dest "&file_to.";

		* Copy the records of SRC to DEST. ;
		%if &type. = 1 %then %do;
			data _NULL_;
			   length msg $ 384;
			   
			   rc = fcopy('src', 'dest');
			   if rc=0 then
			      put "Copied file from &file_from. to &file_to..";
			   else do;
			      msg=sysmsg();
			      put rc= msg=;
			   end;
			run;
			%put NOTE: File &filename_text. was copied with success from &path_from. to &path_to..;
			
		* Cut the file to the destiny;
		%end; %else %if &type. = 2 %then %do; 
			data _NULL_;
			   length msg $ 384;
			   
			   rc = rename("&file_from.","&file_to.",'file');
			   if rc=0 then
			      put "Copied file from &file_from. to &file_to..";
			   else do;
			      msg=sysmsg();
			      put rc= msg=;
			   end;
			run;
			%put NOTE: File &filename_text. was cut with success from &path_from. to &path_to..;
			
		%end; %else %put WARNING: type parameter is different from 1 and 2.;
	%end; %else %put WARNING: File &file_from. does not exist.;
	
%mend copy_cut_paste_files;




***************************************************************
*****************************************************
- NAME: PRINT_MESSAGE
- DESCRIPTION: Send a message from a double quotation marks string on parameter
- UPDATED DATE (dd/mm/yyyy): 04/05/2023

------------ EXAMPLES ------------
- %PRINT_MESSAGE("This is a message test")
- %PRINT_MESSAGE("&VARIABLE.")

****************************************************************;
%macro PRINT_MESSAGE(var_msg);
%macro a();
%mend a;
	data tbl_tmp_msg;
		var_msg = strip(&var_msg.);
		output;
		stop;
	run;

	proc report data=tbl_tmp_msg nowindows noheader nocenter
		style(column)=[
			fontsize=12pt
			font_weight=bold
			borderleftwidth=0
			borderleftstyle=hidden
			borderrightwidth=0
			borderrightstyle=hidden
			borderbottomwidth=0
			borderbottomstyle=hidden
			bordertopwidth=0
			bordertopstyle=hidden];
	run;

	proc delete data=tbl_tmp_msg;
	run;

%mend PRINT_MESSAGE;

