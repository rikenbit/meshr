\name{meshHyperGTest}
\alias{meshHyperGTest}
\alias{meshHyperGTest,MeSHHyperGParams-method}

\title{Hypergeometric Tests for MeSH term association}

\description{ Given a \code{MeSHHyperGParams} object
  containing a set of selected and background gene IDs,
  and gene-MeSH annotation data of interest, \code{meshHyperGTest}
  performs Hypergeomtric test for over-representation of each MeSH term
  accouting for the multiple testing correction.  }

\arguments{
  \item{p}{A \code{MeSHHyperGParams} object }
}

\details{

  For details on creating \code{MeSHHyperGParams} object, please read
  the documentation in the \link[meshr]{MeSHHyperGParams-class}.

}

\value{
  A \code{MeSHHyperGResult} object.
}


\author{
Gota Morota, Koki Tsuyuzaki, Takeru Nakazato, Itoshi Nikaido

Maintainer: Koki Tsuyuzaki <k.t.the-answer@hotmail.co.jp>
}


\examples{
showMethods("meshHyperGTest")
}


\seealso{
  \code{\link{meshr-package}}, \code{\link{MeSHHyperGParams-class}},
  \code{\link{MeSHHyperGResult-class}}
}


\keyword{models}

