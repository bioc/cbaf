#' @title Obtaining the requested data for various cancer studies.
#'
#' @description This function Obtains the requested data for the given genes across multiple cancer studies. It can check
#' whether or not all genes are included in cancer studies and, if not, looks for the alternative gene names.
#'
#' @details
#' \tabular{lllll}{
#' Package: \tab cBioAutomatedTools \cr
#' Type: \tab Package \cr
#' Version: \tab 0.99.0 \cr
#' Date: \tab 2017-06-15 \cr
#' License: \tab Artistic-2.0 \cr
#' }
#'
#' @import cgdsr Biobase
#'
#' @usage obtainMultipleStudies(genesList, submissionName, studiesNames, desiredTechnique, cancerCode = FALSE, validateGenes = TRUE)
#'
#' @param genesList a list that contains at least one gene group
#'
#' @param submissionName a character string containing name of interest. It is used for naming the process.
#'
#' @param studiesNames a character vector or a matrix that containes desired cancer names. The character vector containes standard
#' names of cancer studies that can be found on cbioportal.org, such as \code{Acute Myeloid Leukemia (TCGA, NEJM 2013)}. Alternatively,
#' a matrix can be used if users prefer user-defined cancer names, in which the first column of matrix comprises the standard
#' cancer names while the second column must contain the desired cancer names.
#'
#' @param desiredTechnique a character string that is one of the following techniques: 'RNA-seq', 'microRNA-Seq',
#' 'microarray.mRNA', 'microarray.microRNA' or 'methylation'.
#'
#' @param cancerCode a logical value that tells the function to use cbioportal abbreviated cancer names instead of complete cancer
#' names, if set to be \code{TRUE}. For example, \code{laml_tcga_pub} is the abbreviated name for \code{Acute Myeloid Leukemia (TCGA, NEJM 2013)}.
#'
#' @param validateGenes a logical value that, if set to be \code{TRUE}, function will check each cancer study to find whether
#' or not each gene has a record. If a cancer study doesn't have a record for specific gene, it checks for alternative gene names
#' that cbioportal might use instead of the given gene name.
#'
#' @return a list that contains the obtained data without further processing. Name of the list starts with 'obS' and contains
#' \code{submissionName}. Inside the list, there is one subgroup for every gene group, which itself contains one matrix for every cancer study.
#' In addition, if \code{validateGenes = TRUE}, a secondary list containing gene validation results will be stored. Name of the second
#' list starts with 'vaS' and contains \code{submissionName}.
#'
#' @examples
#' # Creating a list that contains one gene group: 'K.acetyltransferases'
#' genes <- list(K.acetyltransferases = c("CLOCK", "CREBBP", "ELP3", "EP300"))
#'
#' # creating a character vector of study names.
#' cancernames <- c("Acute Myeloid Leukemia (TCGA, Provisional)", "Adrenocortical Carcinoma (TCGA, Provisional)",
#' "Bladder Urothelial Carcinoma (TCGA, Provisional)")
#'
#' # Running the function to obtain and process the selected data
#' obtainMultipleStudies(genes, "test, cancernames, "RNA-seq")
#'
#' @author Arman Shahrisa, \email{shahrisa.arman@hotmail.com} [maintainer, copyright holder]
#' @author Maryam Tahmasebi Birgani, \email{tahmasebi-ma@ajums.ac.ir}
#'
#' @export



#########################################################################
#########################################################################
############# Obtain the requested data for multiple Cancer #############
#########################################################################
#########################################################################

obtainMultipleStudies <- function(genesList, submissionName, studiesNames, desiredTechnique, cancerCode = FALSE, validateGenes = TRUE){

  ##########################################################################
  ########## Prerequisites

  # Check genes

  if(!is.list(genesList)){

    stop("'genes' must be entered as a list containing at list one group of genes with descriptive group name for logistical purposes")

  }



  # studiesNames names

  if(!is.character(studiesNames)){

    stop("'studiesNames' must be entered a character vector containing at least one cancer name")

  }



  # Check whether there is data for the same genes

  if(exists(paste("gM", ".", submissionName, sep = ""))){

    oldGeneList <- unname(sort(unlist(get(paste("gM", ".", submissionName, sep = "")))))

    newGeneList <- unname(sort(unlist(genesList)))


    if(identical(oldGeneList, newGeneList)){

      haultDecision1 <- NULL

    }

  }



  # Check whether there is data for the same studies

  if(exists(paste("cM", ".", submissionName, sep = ""))){

    oldStudyList <- get(paste("cM", ".", submissionName, sep = ""))


    if(identical(oldStudyList, studiesNames)){

      haultDecision2 <- NULL

    }

  }



  # Halt the function

  if(all(exists("haultDecision1"), exists("haultDecision2"))){

    assign(paste("ohaultM", ".", submissionName, sep = ""), "hault order for the other functions", envir = globalenv())

    return("--- Function 'obtainMultipleStudies()' was skipped: Data for the requested genes already exist ---")

  }




  # high throughput data type

  if(is.character(desiredTechnique)){

    if(!(desiredTechnique %in% c("RNA-seq", "microRNA-Seq", "Microarray.mRNA", "Microarray.microRNA", "methylation")) | length(desiredTechnique)!= 1){

      stop("'desiredTechnique' must contain one of the following techniques: 'RNA-seq', 'microRNA-Seq', 'Microarray.mRNA', 'Microarray.microRNA' or

           'methylation'")

    }

  } else {

    stop("'desiredTechnique' must be entered as a character string describing a technique name")

  }




  # Choice of high-throughput data type

  if(desiredTechnique == "RNA-seq"){

    L1.characteristics <- c("Tumor Samples with mRNA data (RNA Seq V2)", "Tumors with mRNA data (RNA Seq V2)", "Tumor Samples with mRNA data (RNA Seq)", "Tumors with mRNA data (RNA Seq)")

    L2.characteristics <- c("mRNA Expression z-Scores (RNA Seq V2 RSEM)", "mRNA Expression z-Scores (RNA Seq RPKM)")

  } else if(desiredTechnique == "microRNA-Seq"){

    L1.characteristics <- c("Tumors with microRNA data (microRNA-Seq)")

    L2.characteristics <- c("microRNA expression Z-scores")

  } else if(desiredTechnique == "microarray.mRNA"){

    L1.characteristics <- c("Tumor Samples with mRNA data (Agilent microarray)", "Tumors with mRNA data (Agilent microarray)", "Tumor Samples with mRNA data (U133 microarray only)", "Tumors with mRNA data", "Tumors with mRNA")

    L2.characteristics <- c("mRNA Expression z-Scores (microarray)", "mRNA Expression z-Scores (U133 microarray only)", "mRNA expression z-scores (Illumina)", "mRNA expression Z-scores (all genes)", "mRNA Expression Z-Scores vs Normals", "mRNA Expression z-Scores (combined microarray)")

  } else if(desiredTechnique == "microarray.microRNA"){

    L1.characteristics <- c("Tumors with microRNA")

    L2.characteristics <- c("mRNA Expression Z-Scores vs Normals", "mRNA Expression z-Scores (combined microarray)")

  } else if(desiredTechnique == "methylation"){

    L1.characteristics <- c("Tumor Samples with methylation data (HM450)", "Tumors with methylation data (HM450)", "Tumor Samples with methylation data (HM27)", "Tumors with methylation data (HM27)", "Tumors with methylation data")

    L2.characteristics <- c("Methylation (HM450)", "Methylation (HM27)", "Methylation")

  } else{

    stop("desiredTechnique field can not be left empety. It should be chosen as 'RNA-seq', 'microRNA-Seq', 'microarray.mRNA', 'microarray.microRNA'or 'methylation'")

  }



  ##########################################################################
  ########## Set the function ready to work

  # Set cgdsr

  mycgds = CGDS("http://www.cbioportal.org/")



  # Creating a vector for cancer names and subsequent list sebset name

  if(!is.matrix(studiesNames)){

    studiesNames <- studiesNames[order(studiesNames)]

    studiesNamesMatrix <- studiesNames



    if(cancerCode == TRUE){

      groupNames <- getCancerStudies(mycgds)[which(getCancerStudies(mycgds)[,2] %in% as.character(studiesNames)),1]

    } else if(cancerCode == FALSE){

      groupNames <- as.character(studiesNames)

    }


  } else if(is.matrix(studiesNames)){

    studiesNamesMatrix <- studiesNames[order(studiesNames[,1]),]

    studiesNames <- studiesNamesMatrix[,2]

    groupNames <- studiesNames

  }


  ##########################################################################
  ########## Core segment

  # Report

  print(paste("***", "Obtaining the requested data for", submissionName, "***", sep = " "))



  # create progress bar

  obtainMultipleStudiesProgressBar <- txtProgressBar(min = 0, max = length(studiesNames), style = 3)



  # Create parent list for storing final results in the global environment

  rawList <- list()

  # Creating child lists

  for(nname in 1:length(genesList)){

    rawList[[nname]] <- list()

    names(rawList)[nname] <- names(genesList)[nname]

  }

  # Creating a list for gene validation results

  if(validateGenes == TRUE){

    validationResult <- list()

    for(nname in 1:length(genesList)){

      validationResult[[nname]] <- "x"

      names(validationResult)[nname] <- names(genesList)[nname]

    }

  }





  ## Getting the required gene expresssion profile ...

  # 'for' control structure for obtaining data and calculating the requested parameters

  for(c in 1:length(studiesNames)){

    # Determining name for list subset of study name

    groupName <- groupNames[c]

    # Correcting possible errors of list names

    groupName <- gsub(groupName, pattern = "\\+ ", replacement = " possitive ", ignore.case = TRUE)

    groupName <- gsub(groupName, pattern = "\\- ", replacement = " negative ", ignore.case = TRUE)

    groupName <- gsub(groupName, pattern = " ", replacement = "_", ignore.case = TRUE)





    ##--## print(as.character(studiesNames[c]))

    mycancerstudy = getCancerStudies(mycgds)[which(getCancerStudies(mycgds)[,2]==as.character(studiesNames[c])),1]



    # Finding the first characteristics of data in the cancer

    f.condition <- (getCaseLists(mycgds,mycancerstudy)[,2])[getCaseLists(mycgds,mycancerstudy)[,2] %in% L1.characteristics]

    mycaselist = getCaseLists(mycgds,mycancerstudy)[which(getCaseLists(mycgds,mycancerstudy)[,2] == if(length(f.condition) >= 1){

      f.condition[1]

    } else if(length(f.condition) == 0){

      stop(paste(studiesNames[c], "lacks", desiredTechnique, "data!", sep=" "))

    }) ,1]



    # Finding the second characteristics of data in the cancer

    s.condition <- (getGeneticProfiles(mycgds,mycancerstudy)[,2])[getGeneticProfiles(mycgds,mycancerstudy)[,2] %in% L2.characteristics]

    mygeneticprofile = getGeneticProfiles(mycgds,mycancerstudy)[which(getGeneticProfiles(mycgds,mycancerstudy)[,2] == if(length(s.condition) >= 1){

      s.condition[1]

    } else if (length(s.condition) == 0){

      stop(paste(studiesNames[i], "doesn't have an appropriate 'level 2' condition for", desiredTechnique, "data!", sep=" "))

    }) ,1]



    # obtaining data for every genegroup

    for(group in 1:length(genesList)){

      # Chose one group of genes

      genesNames <- genesList[[group]]



      # Obtaining Expression x-scores fore the requested genes

      # Assaign data to specific list member

      rawList[[group]][[c]] <- data.matrix(getProfileData(mycgds,genesNames[order(genesNames)],mygeneticprofile,mycaselist))

      names(rawList[[group]])[c] <- groupName


      # Find whether alternative gene names are used

      # Alter c.genes to be compatible with gene names in cBioPortal output

      alteredGeneNames <- sort(gsub("-", ".", genesNames))

      # Obtain name of genes that are absent in requested cancer

      absentGenes <- alteredGeneNames[!alteredGeneNames %in% colnames(rawList[[group]][[c]])]

      # For loop for determining changed genes

      alternativeGeneNames <- vector("character", length = length(absentGenes))

      # For loop

      for(ab in 1:length(absentGenes)){

        absentGeneProfileData <- colnames(data.matrix(getProfileData(mycgds, absentGenes[ab], mygeneticprofile,mycaselist)))

        # Check wheter gene has an alternative name or missed in the database

        if(length(absentGeneProfileData) == 1){

          alternativeGeneNames[ab] <- absentGeneProfileData

        } else if(length(absentGeneProfileData) != 1){

          alternativeGeneNames[ab] <- "-"

        }

      }

      # Naming Alternative.gene.names

      names(alternativeGeneNames) <- absentGenes

      # Seperating genes with alternative names from those that are absent

      genesLackData <- alternativeGeneNames[alternativeGeneNames == "-"]

      genesWithData <- alternativeGeneNames[alternativeGeneNames != "-"]



      # modifying gene names containing an alternative name

      for(re in 1:length(genesWithData)){

        colnames(rawList[[group]][[c]])[colnames(rawList[[group]][[c]]) %in% genesWithData[re]] <- paste(genesWithData[re], " (", names(genesWithData[re]), ")", sep = "")

      }





      # validateGenes

      if(validateGenes == TRUE){

        # Empty validation matrix

        validationMatrix <- matrix(, ncol = length(genesNames), nrow = 1)

        # Naming empty matrix

        if(length(genesLackData) != 0){

        dimnames(validationMatrix) <- list(groupNames[c], c(colnames(rawList[[group]][[c]]), names(genesLackData)))

        } else{

          dimnames(validationMatrix) <- list(groupNames[c], colnames(rawList[[group]][[c]]))

        }



        # modifying gene names containing an alternative name

        for(re in 1:length(genesWithData)){

          colnames(validationMatrix)[colnames(validationMatrix) %in% genesWithData[re]] <- paste(genesWithData[re], " (", names(genesWithData[re]), ")", sep = "")

        }





        # Puting value for genes lacking data

        validationMatrix[,colnames(validationMatrix) %in% names(genesLackData)] <- "-"



        for(eval in 1:ncol(rawList[[group]][[c]])){

          ## Validating Genes

          # Correct those that are not found

          if(length(((rawList[[group]][[c]])[,eval])[!is.nan((rawList[[group]][[c]])[,eval])]) > 0 & all(!is.finite((rawList[[group]][[c]])[,eval])) &

             is.nan(mean(as.vector((rawList[[group]][[c]])[,eval])[abs((rawList[[group]][[c]])[,eval])], na.rm=TRUE))){

            validationMatrix[1, eval] <- "-"

          } else {

            validationMatrix[1, eval] <- "Found"

          }

        }

        # Storing the results in validation result

        validationMatrix <- validationMatrix[,sort(colnames(validationMatrix)), drop=FALSE]

        if(c == 1){

          validationResult[[group]]    <- validationMatrix

        } else if(c > 1){

          validationResult[[group]]    <- rbind(validationResult[[group]], validationMatrix)

        }

      }

    }

    # Update progressbar

    setTxtProgressBar(obtainMultipleStudiesProgressBar, c)


  }

  # Closing progress bar

  close(obtainMultipleStudiesProgressBar)

  # Store name of the genes

  assign(paste("gM", ".", submissionName, sep = ""), genesList, envir = globalenv())

  # Store studies names

  assign(paste("cM", ".", submissionName, sep = ""), studyName, envir = globalenv())

  # Export the obtained data as a list

  assign(paste("obM", ".", submissionName, sep = ""), rawList, envir = globalenv())

  # Export the validation data as a list

  if(validateGenes == TRUE){

    assign(paste("vaM", ".", submissionName, sep = ""), validationResult, envir = globalenv())

  }

}