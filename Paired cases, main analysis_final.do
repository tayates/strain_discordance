** META-ANALYSIS OF PROPORTIONS WITH SUBGROUP ANALYSIS

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


* Load the dataset

* Inspect the variables

describe discordant_pairs total_household_pairs tbincidence_category study

* Set the colour scheme and run the meta-analysis by TB incidence

set scheme burd

label variable proportion "Proportion (n/N)"

*------------------------------------------------------------------
* Prevent graphs from overwriting by renamining the graph after each forestplot is created
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

* End of primary analysis

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
    hetinfo(isq h)          /// Display I≤ and H heterogeneity stats

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
‚Ä¢	extraline(yes) ‚Üí inserts a line break between groups/summary
‚Ä¢	hetinfo(isq h) ‚Üí reports I¬≤ and H heterogeneity metrics
 ****************************************************************************/

 
*Start of sensitivity analysis using random effects model

metan discordant_pairs total_household_pairs  , pr transform(ftukey, iv) study( study) by(tbincidence_category)  sortby(tbincidence_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_tbincidence_re.gph", replace


metan discordant_pairs total_household_pairs  , pr transform(ftukey, iv) study(study) by(typing_method_category) sortby(typing_method_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_typingmethod_re.gph", replace

metan discordant_pairs total_household_pairs  , pr transform(ftukey, iv) study( study) by(sampling_duration_category) sortby(sampling_duration_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_smplingduration_re.gph", replace

metan discordant_pairs total_household_pairs  , pr transform(ftukey, iv) study( study) by(preselection_indexcases) sortby(preselection_indexcases_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_preselection.gph", replace

metan discordant_pairs total_household_pairs  , pr transform(ftukey, iv) study( study ) by(risk_of_bias) sortby( riskofbiasid) lcols(proportion)  forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_riskofbias_re.gph", replace

*Start of sensitivity analysis excluding studies with broad definition of household (Verver et al., 2004(66) and  Faal-Jawara et al., 2017

drop in 11

drop in 25

metan discordant_pairs total_household_pairs, pr model(ivhet) transform(ftukey, iv) study(study) by(tbincidence_category) sortby(tbincidence_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_tbincidence_less2.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study(study) by(typing_method_category) sortby(typing_method_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_typingmethod_less2.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study) by(sampling_duration_category) sortby(sampling_duration_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_samplingduration_less2.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study) by(preselection_indexcases) sortby(preselection_indexcases_id) lcols(proportion) forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_preselection_less2.gph", replace

metan discordant_pairs total_household_pairs  , pr model(ivhet) transform(ftukey, iv) study( study ) by(risk_of_bias) sortby( riskofbiasid) lcols(proportion)  forestplot(astext(40) textsize(100) boxscale(50) spacing(1.2) leftjustify range(0 1) dp(2)) extraline(yes) hetinfo(isq h)
graph save "g_riskofbias_less2.gph", replace

/*end of sensitivity analysis
 
Load the dataset with all studies to run the sensitivity analysis with all studies using the commands for the primary analysis.

 References

1.	Harris RJ, Deeks JJ, Altman DG, Bradburn MJ, Harbord RM, Sterne JA. Metan: fixed-and random-effects meta-analysis. The Stata Journal. 2008;8(1):3-28.
2.	Barendregt JJ, Doi SA, Lee YY, Norman RE, Vos T. Meta-analysis of prevalence. J epidemiol community health. 2013;67(11):974‚Äì8.

 */
 
 
 
 
 
 
 
 
 

