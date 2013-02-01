/*
 This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric" and "chisq") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Test type ( "hypergeometric") and return the requested results as tabular dataset. 
*/
module Ontology : Ontology
{

/*

     Plant Species names.
    
     The current list of plant species includes: 
     Alyrata: Arabidopsis lyrata
     Athaliana: Arabidopsis thaliana
     Bdistachyon: Brachypodium distachyon
     Creinhardtii: Chlamydomonas reinhardtii
     Gmax: Glycine max
     Oglaberrima: Oryza glaberrima
     Oindica: Oryza sativa indica
     Osativa: Oryza sativa japonica
     Ptrichocarpa: Populus trichocarpa 
     Sbicolor: Sorghum bicolor 
     Smoellendorffii:  Selaginella moellendorffii
     Vvinifera: Vitis vinefera 
     Zmays: Zea mays
*/
  typedef string Species;

  /* GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/) */
  typedef string GoID;

  /* GoDesc : Human readable text description of the corresponding GO term */
  typedef string GoDesc;

  /* Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is an external identifier that exists in the public databases such as Gramene, Ensembl, NCBI etc. */ 
  typedef string GeneID;

  /* Evidence code indicates how the annotation to a particular term is supported. 
     The list of evidence codes includes Experimental, Computational Analysis, Author statement, Curator statement, Automatically assigned and Obsolete evidence codes. This list will be useful in selecting the correct evidence code for an annotation. The details are given below: 

     +  Experimental Evidence Codes
     EXP: Inferred from Experiment
     IDA: Inferred from Direct Assay
     IPI: Inferred from Physical Interaction
     IMP: Inferred from Mutant Phenotype
     IGI: Inferred from Genetic Interaction
     IEP: Inferred from Expression Pattern
    
     + Computational Analysis Evidence Codes
     ISS: Inferred from Sequence or Structural Similarity
     ISO: Inferred from Sequence Orthology
     ISA: Inferred from Sequence Alignment
     ISM: Inferred from Sequence Model
     IGC: Inferred from Genomic Context
     IBA: Inferred from Biological aspect of Ancestor
     IBD: Inferred from Biological aspect of Descendant
     IKR: Inferred from Key Residues
     IRD: Inferred from Rapid Divergence
     RCA: inferred from Reviewed Computational Analysis
    
     + Author Statement Evidence Codes
     TAS: Traceable Author Statement
     NAS: Non-traceable Author Statement
    
     + Curator Statement Evidence Codes
     IC: Inferred by Curator
     ND: No biological Data available
    
     + Automatically-assigned Evidence Codes
     IEA: Inferred from Electronic Annotation
    
     + Obsolete Evidence Codes
     NR: Not Recorded
    
*/
  typedef string EvidenceCode;

  /* Captures which branch of knowledge the GO terms refers to e.g. "biological_process", "molecular_function", "cellular_component" etc. */
  typedef string Domain;

  /* Test type, whether it's "hypergeometric" and "chisq"  */
  typedef string TestType;

  /* A list of ontology identifiers */
  typedef list<GoID> GoIDList;

  /* a list of GO terms description */
  typedef list<GoDesc> GoDescList;

  /* A list of gene identifiers from same species */
  typedef list<GeneID> GeneIDList;

  /* A list of ontology domains */
  typedef list<Domain> DomainList;

  typedef list<string> StringArray;

  /* A list of ontology term evidence codes. One ontology term can have one or more evidence codes. */
  typedef list<EvidenceCode> EvidenceCodeList;

  typedef string ontology_type;


  typedef structure {
    Domain domain;
    EvidenceCode ec;
    GoDesc       desc;
  } GoTermInfo;

  typedef list<GoTermInfo> GoTermInfoList;

  typedef mapping<GoID, GoTermInfoList> GoIDMap2GoTermInfo;

  typedef mapping<GeneID,GoIDMap2GoTermInfo> GeneIDMap2GoInfo;

  /* A composite data structure to capture ontology enrichment type object */
  typedef structure {
    GoID goID;
    GoDesc goDesc;
    float pvalue;
  } Enrichment;

  /* A list of ontology enrichment objects */
  typedef list<Enrichment> EnrichmentList;
  

/* For a given list of Features (aka Genes) from a particular genome (for example "Athaliana" Arabidopsis thaliana ) extract corresponding list of GO identifiers. This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids.  */
  funcdef get_goidlist( GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList) returns (GeneIDMap2GoInfo results);

/* Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) and returns a table of two columns, first column being the go-id and the second column being the go-term description. */
  funcdef get_go_description(GoIDList goIDList) returns (mapping<GoID, StringArray> results);

/* For a given list of Features from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your feature-set. This function accepts five parameters: Species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and test type (e.g. "hypergeometric" and "chisq"). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test.

Note that the current released verion ignore test type and by default, it uses hypergeometric test. So even if you do not provide TestType, it will do hypergeometric test. Also, if no species name is provided then Athaliana is used as the default species.
*/
  funcdef get_go_enrichment(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, TestType type,ontology_type ontologytype) returns (EnrichmentList results);  
};
