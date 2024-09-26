data response;
	length visit trt $30;
	visit='Visit 4';
	visitnum=4; 
	response=20;
	trt='Placebo';
	output;
	visit='Visit 4';
	visitnum=4; 
	response=30;
	trt='drugabc';
	output;
	visit='Visit 8';
	visitnum=8; 
	response=25;
	trt='Placebo';
	output;
	visit='Visit 8';
	visitnum=8; 
	response=60;
	trt='drugabc';
	output;

	visit='Visit 12';
	visitnum=12; 
	response=30;
	trt='Placebo';
	output;
	visit='Visit 12';
	visitnum=12;
	response=77;
	trt='drugabc';
	output;


data response; set response;
if trt='Placebo' then visn=visitnum-0.5;
else visn=visitnum+0.5; 
lx1=response+3; 


proc template;
	define statgraph waterfall;
		begingraph;
			discreteattrmap name = "TRTCOLOR";
				value "Placebo" / fillattrs = (color = blue ) lineattrs = (pattern=solid color = blue) MARKERATTRS=(color = blue);
				value "drugabc" / fillattrs = (color = red ) lineattrs = (pattern=solid color = red) MARKERATTRS=(color = red);
			enddiscreteattrmap;
			discreteattrvar attrvar = trt var = trt attrmap = "TRTCOLOR";
			layout overlay/xaxisopts=(offsetmin=0  label = "Response rate (%)" type=linear 
      linearopts=(tickvaluesequence=(start=0 end=100 increment=10) viewmin=0 viewmax=100))



				yaxisopts =( offsetmin=0 offsetmax=0.25 label = "Visit" type=linear

				LINEAROPTS=(tickvaluepriority=true tickvaluesequence=(start=0

				end=20 increment=4) viewmin=0 viewmax=20));

                referenceline x=10 / lineattrs=(thickness=0.5);
  				referenceline x=20 / lineattrs=(thickness=0.5);
				referenceline x=30 / lineattrs=(thickness=0.5);
				referenceline x=40 / lineattrs=(thickness=0.5);
				referenceline x=50 / lineattrs=(thickness=0.5);
				referenceline x=60 / lineattrs=(thickness=0.5);
				referenceline x=70 / lineattrs=(thickness=0.5);
				referenceline x=80 / lineattrs=(thickness=0.5);
				referenceline x=90 / lineattrs=(thickness=0.5);

			
				barchart x=visn y=response/ group=trt barlabelattrs=(size=6pt)

					barwidth=1 name="BAR" orient=horizontal;
				discreteLegend "BAR"/ across=2 autoalign=(bottom) location=outside

					titleattrs=(size=10pt)

					valueattrs=(size=8pt) border=true borderattrs=(color=black)

					title="Treatment Group";
				textplot y=visn x=lx1 text=response;
			endlayout;
		endgraph;
	end;
run;

proc sgrender data=response template=waterfall;
run;

