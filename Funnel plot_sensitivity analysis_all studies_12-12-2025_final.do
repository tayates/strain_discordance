** META-ANALYSIS OF PROPORTIONS WITH SUBGROUP ANALYSIS
*Sensitivity analysis by including all studies

* Code written by Martha Chipinduro
* The metan command requires Stata 8 or higher, with the most complete functionality seen with Stata 12 and up

* Install and update metan


/***********************************************************************
Metaanalysis of proportions (discordant pairs / total pairs)
  Model: IVhet with Freeman-Tukey double arcsine transformation
  Output: Forest plots grouped by subgroups
  Subgroups: 	
		TB incidence category (tbincidence_category); 
		Strain typing method category (typing_method_category)
		Duration of sampling category, i.e., the longest interval between index and secondary patients that studies were designed to detect (sampling_duration_category)  
		Preselection of index patients category, i.e., characteristics used to select index patients, such as having smear-positive TB or pulmonary TB (preselection_indexcases_category)  
		Risk of bias (risk_of_bias_category)
  ****************************************************************************/


* Load the dataset with all included studies from the systematic searches

* Inspect the variables

describe discordant_pairs total_household_pairs tbincidence_category study

* Set the colour scheme and run the meta-analysis by TB incidence

set scheme burd

label variable proportion "Proportion (n/N)"

*------------------------------------------------------------------
* Prevent graphs from overwriting by renamining the graph after each forestplot is created
* Run the sensitivity analysis including all studies
*------------------------------------------------------------------


metan discordant_pairs total_household_pairs, pr model(ivhet) transform(ftukey, iv) study(study) by(tbincidence_category) sortby(tbincidence_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_tbincidence10.gph", replace

* Repeat analysis for the different stratifications

/***********************************************************************
To repeat the stratificaton analysis by
	strain typing method replace by(tbincidence_category) with by(typing_method_category) and replace sortby(tbincidence_id) with sortby(typing_method_id)
	duration of sampling replace by(tbincidence_category) with by(sampling_duration_category) and replace sortby(tbincidence_id) with sortby(sampling_duration_id)
	preselection of index patients replace by(tbincidence_category) with by(preselection_indexcases_category) and replace sortby(tbincidence_id) with sortby(preselection_indexcases_id)
	risk of bias replace by(tbincidence_category) with by(risk_of_bias_category)and replace sortby(tbincidence_id) with sortby(riskofbiasid) 

  ****************************************************************************/


metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study(study) by(typing_method_category) sortby(typing_method_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_typingmethod.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study) by(sampling_duration_category) sortby(sampling_duration_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_samplingduration.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study) by(preselection_indexcases) sortby(preselection_indexcases_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_preselection.gph", replace


metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study ) by(risk_of_bias) sortby( riskofbiasid) lcols(proportion)  forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_riskofbias.gph", replace

* End of sensitivity analysis using all included studies


/***********************************************************************
Syntax explanation
metan discordant_pairs total_household_pairs, ///
    pr                     /// Tells metan we are analysing proportions
    model(ivhet)           /// Use the inverse-variance heterogeneity model
    transform(ftukey, iv)  /// Apply Freeman-Turkey double-arcsine transformation
    study(study)           /// Label studies using the variable 'study'
by(tbincidence_category)	///Performs the subgroup metanalysis by tbincidence_category
sortby(tbincidence_id)		/// orders the subgroups by TB incidence in ascending order
    forestplot( ///
        astext(50)         /* Scaling for text/annotation area */ ///
        textsize(100)      /* Increase forest plot font size */ ///
        boxscale(55)       /* Size of the study effect boxes */ ///
        spacing(1.2)       /* Vertical spacing between rows */ ///
        leftjustify         /* Left-align study labels */ ///
        range(0.0 1.0)      /* X-axis minimum and maximum */ ///
        dp(2)               /* Decimal places displayed */ ///
    ) ///
    extraline(yes)          /// Add an extra line separating summary rows
    hetinfo(isq h)          /// Display I� and H heterogeneity stats

Explanation of each component
Main meta-analysis
	discordant_pairs total_household_pairs - numerator & denominator for proportion
	pr - tells metan this is a proportion meta-analysis
	model(ivhet) - IVhet model, more robust under heterogeneity
	transform(ftukey, iv) - Freeman-Tukey double arcsine for stabilising variance
	study(study) - uses variable study to label each row in plot
 
Forest plot options
Option	Meaning
astext(50)	Sets proportion of space allocated to the left text panel
textsize(100)	Enlarges font size
boxscale(55)	Controls size of study boxes
spacing(1.2)	Controls row spacing
leftjustify	Left-align labels
range(0.0 1.0)	Fix x-axis from 0 to 1
dp(2)	Display 2 decimal places
 
Other reporting
•	extraline(yes) → inserts a line break between groups/summary
•	hetinfo(isq h) → reports I² and H heterogeneity metrics
 ****************************************************************************/

 
*Start of funnel plot

gene p = discordant_pairs / _NN 

gene logodds = ln(p/(1-p))

gene var_logodds = (1 / ( _NN * p)) + (1 / ( _NN *(1 - p)))

twoway (scatter _NN logodds, xline( -0.3279 ) )

gene se_logodds = sqrt( var_logodds)

metabias logodds se_logodds , egger

/*end of funnel plot
Load the dataset with all studies to run the sensitivity analysis with all studies using the commands for the primary analysis.

 */
 
 
 
 
 
 
 
 
 

