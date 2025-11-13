# nhpov_schl_gaps

This repository contains replication code and other materials for "Poor Neighborhoods, Bad Schools? A High-dimensional Model of Place-based Disparities in Academic Achievement."

Data from the NCES Common Core of Data and Private School Universe Surveys are publicly available and included with this replication package. The authors obtained these data from:

  - https://nces.ed.gov/ccd/files.asp; and

  - https://nces.ed.gov/surveys/pss/pssdata.asp.

The rest of the data on which this analysis is based are restricted-access or proprietary and can only be obtained under contractual arrangements that preclude their dissemination by the authors.

Researchers interested in obtaining these data may follow the procedures outlined at:

  - https://nces.ed.gov/pubsearch/licenses.asp for the ECLS-K; and

  - https://geolytics.com/neighborhood-change-database-2010 for the NCDB.

The specific data files/extracts used from these sources are documented within the replication code. They include:

  - childK5.dat 
  - ncdb_raw.csv

Once these data files have been obtained, the user will need to:

1. install the required Stata and R packages documented within the replication code
2. appropriately update the directory paths in all Stata do files and R scripts
3. run _master.do
