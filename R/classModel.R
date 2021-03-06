#' @title classModel
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#' @description Derives a spatially-explicit predictive model as well as sample-wise validation.
#' @param x Object of class \emph{data.frame}.
#' @param y A vector of class \emph{character} or \emph{numeric}.
#' @param z A vector of class \emph{character} or \emph{numeric}.
#' @param mode One of "classification" or "regression".
#' @param ... Arguments passed to \link[caret]{train}.
#' @return A two element numeric \emph{vector}.
#' @importFrom caret train
#' @importFrom ggplot2 ggplot aes_string theme_bw ylim
#' @importFrom stats cor
#' @details {Uses \link[caret]{train} to derive a predictive model based on \emph{x} - which contains the predictors - and \emph{y} - which
#' contains information on the target classes (if \emph{mode} is "classification") or values (if \emph{mode} is "regression"). This method
#' iterates through all samples making sure that all contribute for the final accuracy. To specify how the samples should be split, the user
#' should provide the sample-wise identifiers through \emph{z}. For each unique value in \emph{z}, the function keeps it for validation and
#' the remaining samples for training. This process is repeated for all sample groups and a final accuracy is estimated from the overall set
#' of results. If \emph{mode} is "classification", the function will estimate the overall accuracy for each unique value in \emph{y}. If
#' "regression" is set, the output will be an the coefficient of determination. The classification algorithm and additional commands can be 
#' set through \emph{...} using inputs of the \link[caret]{train} function. Apart from the accuracy assessment, the function stores the 
#' performance for each sample.
#' If \emph{mode} is "classification", the function will return a logical vector reporting on the correctly assigned classes. If \emph{mode}
#' is "regression", the function will report on the percent deviation between the original value and it's predicted value. The final output
#' of the function is a list consisting of:
#' \itemize{
#'  \item{\emph{sample.validation} - Accuracy assessment of each sample.}
#'  \item{\emph{overall.validation} - Finally accuracy value for each class (if "classification").}
#'  \item{\emph{r2} - Correlation between \emph{y} and the predicted values (if "regression")}}}
#' @seealso \code{\link{raster2sample}} \code{\link{poly2sample}} \code{\link{ccLabel}}
#' @examples {
#' 
#' require(raster)
#' 
#' # read raster data
#' r <- brick(system.file("extdata", "ndvi.tif", package="fieldRS"))
#' 
#' # read field data
#' data(fieldData)
#' fieldData <- fieldData[c(1:3, 10),]
#' 
#' # extract values for polygon centroid
#' c <- spCentroid(fieldData)
#' ev <- as.data.frame(extract(r, c))
#' 
#' cm <- classModel(ev, fieldData$crop, as.character(1:length(fieldData)), method="rf")
#' 
#' }
#' @export

#-----------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------#

classModel <- function(x, y, z, mode="classification", ...) {

#-----------------------------------------------------------------------------------------------------------------------------------------------#
# 1. Check input variables
#-----------------------------------------------------------------------------------------------------------------------------------------------#

  if (!is.data.frame(x)) {stop('"x" is not a data.frame')}
  if (!is.vector(y)) {stop('"y" is not a vector')}
  if (!is.vector(z)) {stop('"z" is not a vector')}
  
  if (nrow(x) != length(y)) {stop('"x" and "y" have a different number of entries')}
  if (nrow(x) != length(z)) {stop('"x" and "z" have a different number of entries')}
  if (!mode %in% c('classification', 'regression')) {stop('"mode" is not a valid keyword')}
  
#-----------------------------------------------------------------------------------------------------------------------------------------------#
# 2. train and validate models
#-----------------------------------------------------------------------------------------------------------------------------------------------#

  if (mode == "classification") {

    unique.y <- unique(y) # unique classes
    n <- 1:nrow(x) # base index
    v <- vector('logical', length(n)) # individual sample validation
    a <- vector('numeric', length(unique.y)) # clas-wise validation

    for (c in 1:length(unique.y)) {

      i <- which(y == unique.y[c]) # find class samples
      u <- unique(z[i]) # identify unique region ID's

      # validate each region
      for (r in 1:length(u)) {
        vi <- i[which(z[i] == u[r])]
        ti <- n[!n %in% vi]
        m <- train(x[ti,], as.factor(y[ti]), ...)
        v[vi] <- as.vector(predict(m, x[vi,])) == unique.y[c]}

      # derive accuracy
      a[c] <- sum((v[i])) / length(i)

    }

    # make plot with accuracies
    odf <- data.frame(class=unique.y, accuracy=a, stringsAsFactors=TRUE)
    p <- ggplot(odf, aes_string(x="class", y="accuracy")) + geom_bar(stat="identity") + theme_bw() + ylim(0,1)

    # derive output
    return(list(sample.validation=v, overall.validation=odf, f1.plot=p))

  }

  if (mode == "regression") {

    u <- unique(z) # unique region ID's
    v <- vector('numeric', length(y)) # individual sample validation

    # validate each region
    for (r in 1:length(u)) {
      vi <- which(z == u[r])
      ti <- which(z != u[r])
      m <- train(x[ti,], y[ti], ...)
      v[vi] <- predict(m, x[vi,], y[vi])}

    # derive accuracy
    a <- cor(y,v)^2
    v <- abs(v - y) / y

    # derive output
    return(list(sample.validation=v, r2=a))

  }

}
