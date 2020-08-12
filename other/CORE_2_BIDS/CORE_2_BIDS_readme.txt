CORE 2 BIDS readme

12-Aug-2020 12:44
axs

The ERP CORE is a freely available online resource consisting of optimized paradigms, experiment control scripts, example data from 40 participants, data processing pipelines and analysis scripts, and a broad set of results for 7 different ERP components obtained from 6 different ERP paradigms

https://erpinfo.org/erp-core


We also wish to prepare these datasets as BIDS compatible datasets - see https://bids.neuroimaging.io/

To do so, we:
- have the datasets and analysis files downloaded (perhaps from https://osf.io/thsqg/)

- run the CORE_2_BIDS function, written by axs

- manually add a few additional fields, checking from (https://bids-specification.readthedocs.io/en/latest/04-modality-specific-files/03-electroencephalography.html)


Note that we include a modified version of bids-matlab-tools. This was modified to better handle numeric event codes.