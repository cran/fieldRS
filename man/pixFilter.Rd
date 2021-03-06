% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pixFilter.R
\name{pixFilter}
\alias{pixFilter}
\title{pixFilter}
\usage{
pixFilter(x, y, method)
}
\arguments{
\item{x}{Object of class \emph{RasterLayer}.}

\item{y}{A \emph{numeric} element.}

\item{method}{A \emph{character} element. One of "erode" or "dilate".}
}
\value{
A \emph{RasterLayer}.
}
\description{
Erosion and dilation filter of a raster image.
}
\details{
{Uses \link[raster]{focal} to filter \emph{x} using either an erosion or a dilation filter, specified by \emph{method}. If 
"erosion" is chosen, the function will identify and filter out border pixels around each cluster of pixels in \emph{x}. Small or isolated 
groups of pixels will also be removed. If "dilation" is set, the function will increase the size of each cluster of pixels and simultaneously 
remove all gaps within them. The size of the buffer used in this function is defined by \emph{y} and is expressed in number of pixels.}
}
\examples{
{

require(raster)

# read raster data
r <- raster(system.file("extdata", "ndvi.tif", package="fieldRS")) > 2000
r[r == 0] <- NA

# filter image (3x3 erosion)
or <- pixFilter(r, 1, "erode")
plot(r)
plot(or)

#' # filter image (3x3 dilation)
or <- pixFilter(r, 1, "dilate")
plot(r)
plot(or)

}
}
