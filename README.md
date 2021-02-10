# Rest UICL
Codes for the longitudinal resting-state analysis from the University of Iowa College Life (UICL) study

* [Subject-Level Analysis](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis)
  * [BIDS Conversion Using Heudiconv](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#1-bids-conversion-using-heudiconv)
  * [Check slice timing for Time 2 data](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#2-check-slice-timing-for-time-2-data)
  * [Exclude dummy TRs](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#3-exclude-dummy-trs)
  * [Test phase encoding direction](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#4-test-phase-encoding-direction)
  * [Run FMRIPREP](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#5-run-fmriprep)
  * [Run MRIQC](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#6-run-mriqc)
  * [Create masks for the extended Power ROI](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#7-create-masks-for-the-extended-power-roi)
  * [Post-processing after fMRIPrep: Regression, Filter, ROI timeseries extraction](https://github.com/tientong98/RestUICL/tree/main/Subject-Level%20Analysis#8-post-processing-after-fmriprep)
  
  
* [Group-Level Analysis](https://github.com/tientong98/RestUICL/tree/main/Group-Level%20Analysis)
  * [Aggregate subject-level data into group-level dataframe](https://github.com/tientong98/RestUICL/tree/main/Group-Level%20Analysis#1-clean-up-subject-level-data-aggregate-into-a-large-dataframe)
  * [Network-Level Connectivity](https://github.com/tientong98/RestUICL/tree/main/Group-Level%20Analysis#2-network-level-connectivity): Linear mixed-effects models  
  * [Edge-Level Connectivity](https://github.com/tientong98/RestUICL/tree/main/Group-Level%20Analysis#3-edge-level-connectivity): Connectome-base predictive modeling
