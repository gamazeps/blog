---
title: Deep Variant summary
date: 2017-07-18 18:00:00
Category: Work journal
Tags: notes, genomics, bioinformatics, hospitals
author: Felix Raimundo
---

## Paper report: Creating a universal SNP and small indel variant caller with deep neural networks

[Creating a universal SNP and small indel variant caller with deep neural
networks](http://www.biorxiv.org/content/early/2016/12/14/092890)[0]  
Ryan Poplin, Dan Newburger, Jojo Dijamco, Nam Nguyen, Dion Loy, Sam Gross, Cory Y. McLean, Mark A.
DePristo  
DOI: https://doi.org/10.1101/092890

This paper, published in 2016, describes Google's new Variant caller based on
Deep learning methods.

What this new approach seems to bring are the following:

- Variant caller robust across sequencing technologies, whereas GATK requires
special tuning for each sequencing technology or machine.
- Better accuracy and F1 score than GATK.
- Takes into account the fact that read errors are not independant.
- Works accross species and chromosomes.

Overall this method changes the game compared to GATK and seems to be able to
fix many issues in the GATK way (described
[here](https://software.broadinstitute.org/gatk/best-practices/bp_3step.php?case=GermShortWGS)[1])

The way DeepVariant takes into account the errors is by a new representation
of the reads. It represents them as an image where the aligned reads are
represented as an image with each nucleic acid being color coded in a unique
way.  
This allows to pass that image to a CNN and an [inception-v2](https://arxiv.org/abs/1512.00567) architecture.
The fact that it goes into a CNN is what allows it to take into account the
neighbouring pixels and dealing with correlation in read errors.
The paper mentions that a tensor-like representation approach is probably
being currently investigated.

I imagine that the confidence in the quality of the reads is also taken into
account in that representation even though not mentionned.

Even though not mentionned, it would be interesting to see how that approach
would work if one was to work on unaligned data (even though that is a different
problem), as this [paper by H. Li describes](https://www.ncbi.nlm.nih.gov/pubmed/21903627)[3]


### References

- [0] Creating a universal SNP and small indel variant caller with deep neural networks
- [1] Best Practices for Germline SNP & Indel Discovery in Whole Genome and Exome Sequence
- [2] Rethinking the Inception Architecture for Computer Vision
- [3] A statistical framework for SNP calling, mutation discovery, association mapping and
  population genetical parameter estimation from sequencing data.
