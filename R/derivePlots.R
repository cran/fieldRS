#' @title derivePlots
#-----------------------------------------------------------------------------------------------------------------------------------------------#
#' @description Creates a fishnet from a spatial extent.
#' @param x A spatial object.
#' @param y A numeric element.
#' @return An object of class \emph{SpatialPolygons}.
#' @importFrom raster crop rasterToPolygons raster extent crs
#' @details {Creates a rectangular fishnet in a \emph{SpatialPolygons} format based on
#' the extent of \emph{x} and the value of \emph{y} which defines the spatial resolution.}
#' @seealso \code{\link{rankPlots}}
#' @examples {
#' 
#' require(raster)
#' 
#' # read field data
#' data(fieldData)
#' 
#' # derive plots
#' g <- derivePlots(fieldData, 1000)
#' 
#' # compare original data and output
#' plot(fieldData)
#' plot(g, border="red", add=TRUE)
#' 
#' }
#' @export

#-----------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------#

derivePlots <- function(x, y) {

  # determine rescaling factor
  if (length(y) > 1) {stop('"y" has more than 1 element')}
  e <- tryCatch(extent(x), error=function(i) return(TRUE))
  if (is.logical(e)) stop('"x" is not a valid spatial object')
  
  p <- rasterToPolygons(raster(e, res=y, crs=crs(x))) # build grid
  p <- crop(p, e) # crop grid by the reference object
  p <- p[round(area(p))==round(y*y),] # filter cells with an area smaller than intended
  
  return(p)

}

