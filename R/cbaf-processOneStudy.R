#' @title Checking Expression/methylation Profile for various subgroups of a cancer study.
#'
#' @description This function Obtains the requested data for the given genes across multiple subgroups of a cancer. It can
#' check whether or not all genes are included in subgroups of a cancer study and, if not, looks for the alternative gene names.
#' The main part of function calculates frequency percentage, frequency ratio, mean expression and median of samples greather than
#' specific value in the selected subgroups of the cancer. Furthermore, it looks for the genes that comprise the highest values
#' in each cancer subgroup.
#'
#' @details
#' \tabular{lllll}{
#' Package: \tab cBioAutomatedTools \cr
#' Type: \tab Package \cr
#' Version: \tab 0.99.0 \cr
#' Date: \tab 2017-06-22 \cr
#' License: \tab Artistic-2.0 \cr
#' }
#'
#' @import cgdsr xlsxjars xlsx gplots RColorBrewer rafalib Biobase genefilter
#'
#' @usage processOneStudy <- function(genesList, submissionName, studyName, desiredTechnique, desiredCaseList = FALSE,
#' validateGenes = TRUE, calculate = c("frequencyPercentage", "frequencyRatio", "meanValue", "medianValue"), cutoff=NULL,
#' round=TRUE, topGenes = TRUE, shortenStudyNames = TRUE, genelimit = "none", resolution = 600, RowCex = 0.8, ColCex = 0.8,
#' heatmapMargines = c(10,10), angleForYaxisNames = 45, heatmapColor = "RdBu", reverseColor = TRUE, transposedHeatmap = FALSE,
#' simplify = FALSE, simplifictionCuttoff = FALSE)
#'
#'
#'
#' @param genesList a list that contains at least one gene group
#'
#' @param submissionName a character string containing name of interest. It is used for naming the process.
#'
#' @param studyName a character string showing the desired cancer name. It is an standard cancer study name that can be found on
#' cbioportal.org, such as 'Acute Myeloid Leukemia (TCGA, NEJM 2013)'.
#'
#' @param desiredTechnique a character string that is one of the following techniques: 'RNA-seq', 'microRNA-Seq', 'microarray.mRNA',
#' 'microarray.microRNA' or 'methylation'.
#'
#' @param desiredCaseList a numeric vector that contains the index of desired cancer subgroups, assuming the user knows index of
#' desired subgroups. If not, desiredCaseList must be set as 'none', function will show the available subgroups and ask the
#' user to enter the desired ones during the process. The default value is 'none'.
#'
#' @param validateGenes a logical value that, if set to be 'TRUE', function will check each cancer study to find whether
#' or not each gene has a record. If the given cancer doesn't have a record for specific gene, it checks for alternative gene
#' names that cbioportal might use instead of the given gene name.
#'
#' @param obtainedDataType a character string that specifies the type of input data to function. Two options are availabe:
#' 'single study' and 'multiple studies'. The function uses 'obtainedDataType' and 'submissionName' to construct
#' the name of input data. Default value is 'multiple studies'.
#'
#' @param calculate a character vector that containes the statistical precedures users prefer the function to compute.
#' Default input is \code{c("frequencyPercentage", "frequencyRatio", "Mean.Value", "medianValue")}. This will tell the function to
#' compute the following:
#' 'frequencyPercentage', which is the number of samples having the value greather than specific cutoff divided by the total sample
#' size for every study / study subgroup;
#' 'frequency ratio', which shows the number of selected samples divided by the total number of samples that give the frequency
#' percentage for every study / study subgroup -to know selecected and total sample sizes only;
#' 'Mean Value', that contains mean value of selected samples for each study;
#' 'Median Value', which shows the median value of selected samples for each study.
#'
#' @param cutoff a number used to limit samples to those that are greather than specific number (cutoff). The default value for
#' methylation data is 0.6 while gene expression studies use default value of 2. For methylation studies, it is
#' \code{observed/expected ratio}, for the rest, it is 'z-score'. TO change the cutoff to any desired number, change the
#' option to \code{cutoff = desiredNumber} in which desiredNumber is the number of interest.
#'
#' @param round a logical value that, if set to be TRUE, will force the function to round all the calculated values
#' to two decimal places. The default value is TRUE.
#'
#' @param topGenes a logical value that, if set as TRUE, causes the function to create three data.frame that contain the five
#' top genes for each cancer. To get all the three data.frames, "Frequency.Percentage", "Mean.Value" and "Median" must have been
#' included for \code{calculate}.
#'
#' @param shortenStudyNames a logical vector. If the value is set as true, function will try to remove the end part of
#' cancer names aiming to shorten them. The removed segment usually contains the name of scientific group that has conducted
#' the experiment.
#'
#' @param genelimit if large number of genes exist in at least one gene group, this option can be used to limit the number of
#' genes that are shown on hitmap. For instance, \code{genelimit=50} will limit the heatmap to 50 genes showing the most variation
#' across multiple study / study subgroups.
#' The default value is \code{none}.
#'
#' @param resolution a number. This option can be used to adjust the resolution of the output heatmaps as 'dot per inch'.
#' The defalut value is 600.
#'
#' @param RowCex a number that specifies letter size in heatmap row names.
#'
#' @param ColCex a number that specifies letter size in heatmap column names.
#'
#' @param heatmapMargines a numeric vector that can be used to set heatmap margins. The default value is
#' \code{heatmapMargines=c(15,07)}.
#'
#' @param angleForYaxisNames a number that determines the angle with which the studies/study subgroups names are shown in heatmaps.
#' The default value is 45 degree.
#'
#' @param heatmapColor a character string that defines heatmao color. The default value is "RdBu". "redgreen" is also a popular
#' color in genomic studies. To see the rest of colors, please type \code{display.brewer.all()}.  Default value is 'TRUE'.
#'
#' @param reverseColor a logical value that reverses the color gradiant for heatmap(s).
#'
#' @param simplify a logical value that tells the function whether or not to change values under
#' \code{simplifiction.cuttoff} to zero. The purpose behind this option is to facilitate seeing candidate genes. Therefore, it is
#' not suited for publications. Default value is 'FALSE'.
#'
#' @param simplifictionCuttoff a logical value that, if \code{simplify.visulization = TRUE}, needs to be set as a desired cuttoff
#' for \code{simplify.visulization}. It has the same unit as \code{cutoff}.
#'
#'
#'
#' @return a list that containes some or all of the following groups, based on what user has chosen: ValidationResults,
#' Frequency.Percentage, Top.Genes.of.Frequency.Percentage, Frequency.Ratio, mean.Value, Top.Genes.of.Mean.Value, median.Value,
#' Top.Genes.of.Median. It also saves these groups in one excel files for convenience. Based on preference, three heatmaps for
#' Frequency.Percentage, Mean.Value and Median can be generated. If more than one group of genes is entered, output for each group
#' will be strored in a separate sub-directory.
#'
#' @examples
#' # Creating a list that contains one gene group: 'K.demethylases'
#' genes <- list(K.demethylases = c("KDM1A", "KDM1B", "KDM2A"))
#'
#' # Running the function to obtain and process the selected data
#' processOneStudy(genes, "Breast Invasive Carcinoma (TCGA, Cell 2015)", "RNA-seq", desired.case.list = c(3,4,5),
#' data.presented.as = c("Frequency.Percentage", "Frequency.Ratio", "Mean.Value"), heatmap.color = "redgreen")
#'
#' @author Arman Shahrisa, \email{shahrisa.arman@hotmail.com} [maintainer, copyright holder]
#' @author Maryam Tahmasebi Birgani, \email{tahmasebi-ma@ajums.ac.ir}
#'
#' @export



###################################################################################################
###################################################################################################
########## Evaluation of Median, Frequency and ExpressionMean for Subtypes of a Cancer ############
###################################################################################################
###################################################################################################

processOneStudy <- function(genesList, submissionName, studyName, desiredTechnique, desiredCaseList = FALSE, validateGenes = TRUE,

                            calculate = c("frequencyPercentage", "frequencyRatio", "meanValue", "medianValue"), cutoff=NULL, round=TRUE,

                            topGenes = TRUE, shortenStudyNames = TRUE, genelimit = "none", resolution = 600, RowCex = 0.8, ColCex = 0.8,

                            heatmapMargines = c(10,10), angleForYaxisNames = 45, heatmapColor = "RdBu", reverseColor = TRUE,

                            transposedHeatmap = FALSE, simplify = FALSE, simplifictionCuttoff = FALSE){

  ##########################################################################
  ### Obtaining data

  obtainOneStudy(genesList = genesList, submissionName = submissionName, studyName = studyName, desiredTechnique = desiredTechnique,

                 desiredCaseList = desiredCaseList, validateGenes = validateGenes)



  ##########################################################################
  ### Calculating statistics

  automatedStatistics(submissionName = submissionName, obtainedDataType = "single study", calculate = calculate, cutoff = cutoff,

                      round = round, topGenes = topGenes)



  ################################################################################
  ################################################################################
  ### Create new directory for submission

  present.directory <- getwd()

  dir.create(paste(present.directory, "/", submissionName, " output for  single study", sep = ""), showWarnings = FALSE)

  setwd(paste(present.directory, "/", submissionName, " output for a single study", sep = ""))



  ##########################################################################
  ### Preparing for heatmap output

  heatmapOutput(submissionName = submissionName, shortenStudyNames = shortenStudyNames, genelimit = genelimit, resolution = resolution,

                RowCex = RowCex, ColCex = ColCex, heatmapMargines = heatmapMargines, angleForYaxisNames = angleForYaxisNames,

                heatmapColor = heatmapColor, reverseColor = reverseColor, transposedHeatmap = transposedHeatmap, simplify = simplify,

                simplifictionCuttoff = simplifictionCuttoff)



  ##########################################################################
  ### Preparing for excel output

  xlsxOutput(submissionName = submissionName)



  ################################################################################
  ################################################################################
  ### Change the directory to the first directory

  setwd(present.directory)

}