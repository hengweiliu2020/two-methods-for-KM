/*******************************************************************************
XYZbioBIO, Global Macros
********************************************************************************
PROGRAM:        mean_stderr.sas  
AUTHOR:         Hengwei Liu
DATE:           Feb2022
PURPOSE:        plot the mean concentration with STDERR over timepoint
SAS VERSION :   SAS 9.4 FOR WINDOWS
********************************************************************************
THIS PART MUST BE FILLED IN FOR EVERY MODIFICATION THAT IS MADE
DATE         BY      DESCRIPTION

*******************************************************************************/

%m_init;

proc sql;
select distinct paramcd, param from adam.adlb;

proc sql;
select distinct trt01an, trt01a, count(*) from adam.adsl 
where effevfl='Y'
group by trt01an; 

select distinct trt01pn, trt01p, count(*) from adam.adsl 
where effevfl='Y'
group by trt01pn; 

data adsl; set adam.adsl;
where effevfl='Y' and 4<=trt01pn<=6; 

proc sql noprint;
select count(distinct usubjid) into :bign4 trimmed from adsl where trt01pn=4;
select count(distinct usubjid) into :bign5 trimmed from adsl where trt01pn=5;
select count(distinct usubjid) into :bign6 trimmed from adsl where trt01pn=6;

proc sort data=adam.adlb out=adlb;
by subjid; 
where paramcd='CA19_9AG' and anl01fl='Y' and 4<=trtpn<=6 and effevfl='Y'; 
run;

data adlb; set adlb;
if avisitn=0 then do; 
chg=0; 
pchg=0;
end;

proc means data=adlb nway noprint;
var pchg; 
class trtpn trtp avisit avisitn; 
output out=out1(drop=_type_ _freq_) n=n  median=median q1=q1 q3=q3;

proc sort data=out1;
	by trtpn trtp avisitn avisit;
run;

data out1;
	set out1;

	lower=q1;
	upper=q3;

run;


libname tfldata "D:\Clinical_Data\XYZbio120\XYZbio120-18-0402_unblinded\final\validation\data\tlf"; 
data tfldata.f_1_2_median_q1_q3_ca19_pchg; 
set out1; 
run;


proc sort data=out1; by avisitn avisit; 



proc sql ;
create table frame as 
select distinct  avisitn, avisit from out1; 

data frame; set frame; newvis=_n_;

proc sort data=out1; by avisitn avisit;
proc sort data=frame; by avisitn avisit;

data out1;
merge out1 frame;
by avisitn avisit;
run;

data out1; 
length trt $40.; 
set out1;
if n>=3 and avisitn ne 99999;

avisitn=newvis;

if trtpn=4 then avisitn2=avisitn;
if trtpn=5 then avisitn2=avisitn+0.05;
if trtpn=6 then avisitn2=avisitn+0.1;

if trtpn=4 then trt="XYZbio120 30 mg (N=&bign4)";
if trtpn=5 then trt="Randomized XYZbio120 100 mg (N=&bign5)";
if trtpn=6 then trt="Randomized Placebo 100 mg (N=&bign6)";
run;

proc sql;
create table fmt as 
select distinct avisitn, avisit from out1; 


proc format;
value trtf
4="XYZbio120 30 mg (N=&bign4)"
5="Randomized XYZbio120 100 mg (N=&bign5)"
6="Randomized Placebo 100 mg (N=&bign6)"
;


proc print data=out1;
run;

%macro create_fmt;
data _null_; 
set fmt end=eof;
j+1;
call symput(compress('avisitn'||put(j,best.)), trim(left(put(avisitn,best.)))); 
call symput(compress('avisit'||put(j, best.)), trim(left(avisit))); 
if eof then call symput("totvis", trim(left(put(_n_, best.))));
run;

proc format;
value visf
%do y=1 %to &totvis; 
&&avisitn&y="&&avisit&y"
%end;
;
run;
%mend;
%create_fmt; 




%ms_stl9a; 
proc template;
define statgraph mean_se;
begingraph;

discreteattrmap name = "TRTCOLOR";
 value "XYZbio120 30 mg (N=&bign4)" / fillattrs = (color = green ) lineattrs = (pattern=solid color = green) MARKERATTRS=(color = green) ;
 value "Randomized XYZbio120 100 mg (N=&bign5)" / fillattrs = (color = blue ) lineattrs = (pattern=solid color = blue) MARKERATTRS=(color = blue) ;
 value "Randomized Placebo 100 mg (N=&bign6)" / fillattrs = (color = red ) lineattrs = (pattern=solid color = red) MARKERATTRS=(color = red) ;

enddiscreteattrmap;

discreteattrvar attrvar = trt var = trt attrmap = "TRTCOLOR";


layout overlay/xaxisopts=(offsetmin=0.05 offsetmax=0.05
linearopts=(tickvaluelist= (1 2 3 4 5) tickvalueformat=visf.) label= 'Visit')

yaxisopts=(griddisplay=on gridattrs=(thickness= 0.05 color=lightgrey)
linearopts=(tickvaluepriority=true TICKVALUESEQUENCE=(START=-100 END=100
INCREMENT=50)) offsetmin=0.15 offsetmax=0.1 label='Median (Q1, Q3)');

seriesplot x= avisitn2 y= median /group =trt name= 'trt' ;

scatterplot x=avisitn2 y=median/ group=trt yerrorlower= lower
yerrorupper=upper markerattrs=(symbol= circle)
/*datalabel= mean datalabelattrs=(color=brown)*/;

drawtext textattrs=(size=9pt) "Number of Subjects"
/anchor=bottomleft width=22 widthunit=percent
xspace=wallpercent yspace=wallpercent x=1 y=13 justify=center;
innermargin/align=bottom pad=0.8;

axistable x=avisitn value=n / class=trt ;
endinnermargin;
discretelegend 'trt' / title= " " titleattrs= (size=9pt
weight=normal ) location= outside halign=left valign=bottom
valueattrs= (size=9pt) border=false;
endlayout;
endgraph;
end;
run;



options orientation=landscape;
goptions reset=goptions device=sasemf target=sasemf xmax=10in ymax=7.5in ftext='Arial' ;
ods graphics /reset=all width=850px height=480px noborder;

options nobyline nodate nonumber;
ods escapechar="~";
ods rtf file= "D:\Clinical_Data\XYZbio120\XYZbio120-18-0402_unblinded\final\validation\output\figure\figure_1_2_median_q1_q3_stderr_ca19_pchg.rtf" nogtitle nogfootnote style=stl9a;

	title1 font='Arial'  j=left "XYZbio Biopharmaceuticals, Inc."  j=right "Page ~{pageof}";
		title2 font='Arial'  j=left "Protocol: XYZbio120-18-0402" j=right "Final"; 
		title3 font='Arial'  j=center "Figure 1.2 Median (Q1, Q3) for Percent Change from baseline in Cancer Antigen 19-9 (U/mL) VS Visit";
		title4 font='Arial'  j=center "Efficacy Evaluable Set";
	
		footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";

		footnote2 font='Arial'  j=left "Program: D:\Clinical_Data\XYZbio120\XYZbio120-18-0402_unblinded\final\validation\program\figure\median_q1_q3_ca19_pchg.sas, generated at &sysdate &systime";
	run;


proc sgrender data=out1 template=mean_se;
format trtpn trtf. avisitn visf.; 
run;


ods rtf close; 






