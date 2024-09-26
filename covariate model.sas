/*******************************************************************************
NGMBIO, Global Macros
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

proc import datafile="D:\Clinical_Data\NGM438\NGM438-IO-101\final\prod\program\figure\data2.xlsx"
dbms=xlsx replace out=mydata;
run;

data mydata; set mydata;
if trt='1 mg' then weeks=weeks+0.1;
if trt='3 mg' then weeks=weeks+0.2; 


proc print data=mydata;
run;

proc template;
define statgraph mean_se;
begingraph;

discreteattrmap name = "TRTCOLOR";
 value "Placebo" / fillattrs = (color = green ) lineattrs = (pattern=solid color = green) MARKERATTRS=(color = green) ;
 value "1 mg" / fillattrs = (color = blue ) lineattrs = (pattern=solid color = blue) MARKERATTRS=(color = blue) ;
 value "3 mg" / fillattrs = (color = red ) lineattrs = (pattern=solid color = red) MARKERATTRS=(color = red) ;

enddiscreteattrmap;

discreteattrvar attrvar = trt var = trt attrmap = "TRTCOLOR";


layout overlay/xaxisopts=(offsetmin=0.05 offsetmax=0.05
linearopts=(tickvaluelist= (0 12 24 48) ) label= 'Visit (weeks)')

yaxisopts=(griddisplay=on gridattrs=(thickness= 0.05 color=lightgrey)
linearopts=(tickvaluepriority=true TICKVALUESEQUENCE=(START=-1 END=1
INCREMENT=0.1)) offsetmin=0.15 offsetmax=0.1 label='Mean ELF Change from Baseline');

seriesplot x=weeks y= chg /group =trt name= 'trt' ;

scatterplot x=weeks y=chg/ group=trt yerrorlower= lower
yerrorupper=upper markerattrs=(symbol= circle)
/*datalabel= mean datalabelattrs=(color=brown)*/;


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
ods rtf file= "D:\Clinical_Data\NGM438\NGM438-IO-101\final\prod\program\figure\covariate model.rtf" nogtitle nogfootnote style=NGMStyle;

	title1 font='Arial'  j=left "NGM Biopharmaceuticals, Inc."  j=right "Page ~{pageof}";
		title2 font='Arial'  j=left "NGM ELF Plot" j=right "Final"; 
		title3 font='Arial'  j=center "Figure 2: Mean ELF Change from Baseline with 95% CI over Visit";
		title4 font='Arial'  j=center "Covariate Model";
	
		footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";

		footnote2 font='Arial'  j=left "Program: covariate model.sas, generated at &sysdate &systime";
	run;


proc sgrender data=mydata template=mean_se;

run;


ods rtf close; 






