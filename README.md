# TAPAS UniQC - Unified NeuroImaging Quality Control Toolbox

*Current version: Release 2021a, v0.2*

> Copyright (C) 2021  
> Lars Kasper and Saskia Bollmann  
> <kasper@biomed.ee.ethz.ch>  
>  
> Translational Neuromodeling Unit (TNU)  
> Institute for Biomedical Engineering  
> University of Zurich and ETH Zurich  


## Purpose

The unified neuroimaging quality control (UniQC) toolbox offers a flexible and interactive n-dimensional image analysis framework. UniQC is designed to specifically support the development of new acquisition and reconstruction methods for (f)MRI and to assist during their translation to neuroscientific practice. It combines algebraic matrix operations, image operations, SPM processing steps and visualization options into one framework, thus allowing the user to specify their unique quality control (QC) pipeline. 

UniQC is implemented in an object-oriented framework and follows the design principles of flexibility, reproducibility and accessibility. 
- Flexibility is achieved through the intuitive syntax to access subsets of data utilizing user-defined dimension labels, and the generalization of MATLAB and SPM functions to arbitrary dimensions. 
- Reproducibility is pursued through the easily readable code, the automatic documentation of processing steps and saving of the corresponding data, and the integration of MATLAB and SPM functions wherever possible. 
- Accessibility is achieved via operator overloading, which allows the same syntax for objects as for variables, and the straightforward integration of new functions.


## Installation


1. Please download the latest stable versions of the UniQC Toolbox on GitHub as part of the 
  [TAPAS software releases of the TNU](https://github.com/translationalneuromodeling/tapas/releases).
    - The latest bugfixes can be found in the [development branch of TAPAS](https://github.com/translationalneuromodeling/tapas/tree/development) 
      and are announced in the [GitHub Issue Forum](https://github.com/translationalneuromodeling/tapas/issues). 
    - Changes between all versions are documented in the 
      [CHANGELOG](CHANGELOG.md).
2. Please download the current version of statistical the parametric mapping ([SPM](http://www.fil.ion.ucl.ac.uk/spm/software/)) software.
    - This is optional, but required for loading of nifti-images, complex neuroimaging operations, both in preprocessing (realignment, ...) and statistical analysis (general linear models, ...). 
3. In Matlab, add the UniQC path recursively (i.e., including sub-folders) to your path, and optionally add the code directory of spm (e.g., `spm12`) as well, but *not recursively*.
4. Type `I = MrImage` to test your setup.


## Getting started

The best starting point are the demo scripts contained in `demo/[MrClassName]`. Details to each demo are given below.

The example data to run most of the scripts is a real-time multi-echo fMRI dataset, provided by Heunis, Stephan, 2020, "rt-me-fMRI: A task and resting state dataset for real-time, multi-echo fMRI methods development and validation", https://doi.org/10.34894/R1TNL8, DataverseNL, V1. Please download it separately at https://dataverse.nl/dataverse/rt-me-fmri.


## Contact/Support

We are very happy to provide support on how to use the UniQC Toolbox. However, 
as every researcher, we only have a limited amount of time. So please excuse, if 
we might not provide a detailed answer to your request, but just some general 
pointers and templates. Please get support in the following way:

1. A first look at the [FAQ](https://gitlab.ethz.ch/uniQC/uniqc-doc/wikis/FAQ) 
   (which is frequently extended) might already answer your questions.
2. Submit any questions, bug reports or feature request as a new on our 
   [github issues page](https://github.com/translationalneuromodeling/tapas/issues) for TAPAS, 
    - Please check the archives (including closed issues) there, whether your question might 
      have been answered in a response to another user.



## Documentation

Documentation for this toolbox is provided in the following forms

1. Overview and guide to further documentation: README.md and CHANGELOG.md
    - [README.md](README.md): this file, purpose, installation, getting started, pointer to more help
    - [CHANGELOG.md](CHANGELOG.md): List of all toolbox versions and the respective release notes, 
      i.e. major changes in functionality, bugfixes etc.
2. Within Matlab: Extensive headers at the start of each `.m` file (functions, classes) and commenting throughout
    - accessible via `help` and `doc` commands from Matlab command line
    - also useful for developers (technical documentation)
3. The demos (below) illustrate the features of uniQC and provide examples for many use-cases.
4. User Guide: The markdown-based [GitLab Wiki](https://gitlab.ethz.ch/uniQC/uniqc-doc/wikis/home), including an FAQ
5. A [chapter](https://cloudstor.aarnet.edu.au/plus/s/59cJjfB9QI0Akxp) in Saskia Bollmann's PhD Thesis, which describes UniQC's design concepts in detail, but refers to the state in 2017, before most of the n-dimensional SPM operators were integrated.


## Demos

### MrImage
`MrImage/demo_add_overlay.m`: Illustrates how to use plot with overlayImages and compares it to an implementation using native MATLAB code.

`MrImage/demo_constructor.m`: Illustrates how MrImage objects can be created from nifti files, folders and Philips par/rec files.

`MrImage/demo_coregister.m`: Illustrates how to coregister a structural to a functional image and the difference between changing (only) the geometry and reslicing the coregistered image.

`MrImage/demo_image_math_imcalc_fslmaths.m`: Illustrates how to estimate image properties and compare different images.

`MrImage/demo_multi_echo_realign.m`: Illustrates the syntax to extend SPM pre-processing options to n-dimensional data.

`MrImage/demo_plot_images.m`: Illustrates the versatile plot options; see also section Visualisation tools.

`MrImage/demo_roi_analysis.m`: Template for a fast analysis of regions-of-interest defined using tissue masks and manually drawn masks, which can be saved and, thereby, enhance the documentation of the performed analysis.

`MrImage/demo_spikes.m`: Illustrates the performance of different visualisation options such as mean and tSNR images and dynamic displays to identify k-space spikes.

`MrImage/demo_split_complex.m`: Illustrates how complex data are automatically split and combined to perform SPM pre-processing operations.

### MrSeries
`MrSeries/demo_fmri_qa.m`: Illustrates how to combine different visualisations and image operations to inspect an fMRI time series.

`MrSeries/demo_model_estimation_1st_level.m`: Illustrates how to specify a 1st level model using MrGlm and estimating its parameters using the classical restricted maximum Likelihood approach within SPM (Kiebel and Holmes, 2007). Note that it requires the output of MrSeries/demo_preprocessing.

`MrSeries/demo_model_estimation_1st_level_Bayesian.m`: Illustrates how to estimate the same model as in MrSeries/demo_model_estimation_1st_level using a Variational Bayesian framework (Penny et al., 2003). Note that it requires the output of MrSeries/demo_model_estimation_1st_level and MrSeries/demo_preprocessing.

`MrSeries/demo_preprocessing.m`: Example pre-processing script for fMRI data. Illustrates how MrSeries automatically updates data and populates appropriate properties such as mean, snr, sd images, tissue probability maps and masks.

`MrSeries/demo_snr_analysis_mrseries.m`: Example of a tSNR assessment in different ROIS illustrating the impact of different pre-processing steps on tSNR in grey matter.

### MrDimInfo
`MrDimInfo/demo_dim_info.m`: The MrDimInfo class implements data selection and access used in plots and computations. The demo covers the creation of dimInfo objects, retrieving parameters via get_dims and dimInfo.dimLabel, adding/setting dimensions, retrieving array indices and sampling points, selecting a subset of dimensions and creating dimInfos from files. Note that dimInfo does not know about the affineGeometry, i.e. all sampling points are with reference to the data matrix.

### MrAffineGeometry
`MrAffineGeometry/demo_affine_geometry.m`: Exemplifies creating of an MrAffineGeometry object using a nifti file, a Philips par/rec file, prop/val pairs or an affine transformation matrix.

### MrImageGeometry
`MrImageGeometry/demo_image_geometry.m`: Shows how an MrImageGeometry object can be created from file or via MrDimInfo and MrAffineGeometry objects.

### MrDataNd
`MrDataNd/demo_save.m`: Illustrates how data are split to allow compatibility with SPM read-in.

### MrCopyData
`MrCopyData/demo_copy_data.m`: Shows the functionality of MrCopyData for deep cloning and recursive operations.


## Background

The challenge of unified and comprehensive quality control (QC) in (functional) MRI results from the vast amount of artefact sources combined with the complex processing pipelines applied to the data. Beyond standard image quality measures, MRI sequence development is often in need of flexible diagnostic tools to test diverse hypotheses on artefact origin, such as hardware fluctuations, k-space spikes, or subject movement. These tests are usually performed in a sequential order, where one outcome informs the next evaluation. This necessitates fast switching between mathematical image operations and interactive display of multi-dimensional data to assess image properties from a range of different perspectives. Additionally, for complex image analysis pipelines, as employed, e.g., in fMRI, direct access to the standard analysis packages is required to ultimately evaluate functional sensitivity of new sequence prototypes. Here, we present the uniQC toolbox that provides seamless combination of algebraic matrix operations, image processing, visualization options and data provenance in an intuitive, object-oriented framework using MATLAB, and interfacing SPM for all fMRI-related pre-processsing and statistical analysis steps. Therein, processing of 4D image time series data is generalised to an arbitrary number of dimensions to handle data from multiple receiver coils, multi-echo or phase fMRI data in a unified framework along with classical statistical analysis and powerful visualization options.


## Contributors

- Lead Programmer: 
    - Lars Kasper, TNU & MR-Technology Group, IBT, University of Zurich & ETH Zurich
    - Saskia Bollmann, Centre for Advanced Imaging, University of Queensland, Australia
- Project Team: 
    - ...
- Contributors:
    - Matthias Mueller-Schrader, TNU Zurich
    - External TAPAS contributors are listed in the [Contributor License Agreement](https://github.com/translationalneuromodeling/tapas/blob/master/Contributor-License-Agreement.md)


## Requirements

- All specific software requirements and their versions are in a separate file
  in this folder, `requirements.txt`.
- In brief:
    - UniQC needs Matlab to run, and a few of its toolboxes.
    - Some functionality requires SPM (e.g., loading of nifti-files, preprocessing (realignment, ...) and statistical analysis (general linear models, ...).


## Acknowledgements

We thank Stephan Heunis and colleagues for the provision of the [rt-me-fmri dataset]( https://doi.org/10.34894/R1TNL8) that is utilized as an example dataset for the n-dimensional computation abilities of UniQC.

We thank all internal users at the TNU, IBT and CAI for employing UniQC and providing helpful feedback on the toolbox functionality.


## References
1. Bollmann, S., Kasper, L., Pruessmann, K., Barth, M., Stephan, K.E., 2018. Interactive and flexible quality control in fMRI sequence evaluation: the uniQC toolbox, in: Proc. Intl. Soc. Mag. Reson. Med. 26. Presented at the ISMRM, Paris, France, p. 2842.

2. Bollmann, S., 2018. Evaluating Acquisition Techniques for Functional Magnetic Resonance Imaging at Ultra-High Field (PhD Thesis). The University of Queensland. Chapter 4, p. 96-127 https://doi.org/10.14264/uql.2018.635
