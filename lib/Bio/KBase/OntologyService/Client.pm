package Bio::KBase::OntologyService::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::OntologyService::Client

=head1 DESCRIPTION


This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric" and "chisq") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Testtype (right now it is ignored but "hypergeometric" and "chisq" will be included) and return the requested results as tabular dataset.


=cut

sub new
{
    my($class, $url, @args) = @_;

    my $self = {
	client => Bio::KBase::OntologyService::Client::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 getGOIDList

  $results = $obj->getGOIDList($sname, $geneIDList, $domainList, $ecList)

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string


=end text

=item Description

For a given list of Features (aka Genes) from a particular genome (for example "Athaliana" Arabidopsis thaliana ) extract corresponding list of GO identifiers. This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids.

=back

=cut

sub getGOIDList
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 4)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOIDList (received $n, expecting 4)");
    }
    {
	my($sname, $geneIDList, $domainList, $ecList) = @args;

	my @_bad_arguments;
        (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument 1 \"sname\" (value was \"$sname\")");
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 4 \"ecList\" (value was \"$ecList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOIDList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOIDList');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOIDList",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOIDList',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOIDList",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOIDList',
				       );
    }
}



=head2 getGoDesc

  $results = $obj->getGoDesc($goIDList)

=over 4

=item Parameter and return types

=begin html

<pre>
$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string

</pre>

=end html

=begin text

$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string


=end text

=item Description

Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) and returns a table of two columns, first column being the go-id and the second column being the go-term description.

=back

=cut

sub getGoDesc
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGoDesc (received $n, expecting 1)");
    }
    {
	my($goIDList) = @args;

	my @_bad_arguments;
        (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"goIDList\" (value was \"$goIDList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGoDesc:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGoDesc');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGoDesc",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGoDesc',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGoDesc",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGoDesc',
				       );
    }
}



=head2 getGOEnrichment

  $results = $obj->getGOEnrichment($sname, $geneIDList, $domainList, $ecList, $type)

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string


=end text

=item Description

For a given list of Features from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your feature-set. This function accepts five parameters: Species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and test type (e.g. "hypergeometric" and "chisq"). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test.

Note that the current released verion ignore test type and by default, it uses hypergeometric test. So even if you do not provide TestType, it will do hypergeometric test. Also, if no species name is provided then Athaliana is used as the default species.

=back

=cut

sub getGOEnrichment
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOEnrichment (received $n, expecting 5)");
    }
    {
	my($sname, $geneIDList, $domainList, $ecList, $type) = @args;

	my @_bad_arguments;
        (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument 1 \"sname\" (value was \"$sname\")");
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 4 \"ecList\" (value was \"$ecList\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 5 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOEnrichment');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOEnrichment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOEnrichment',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOEnrichment",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOEnrichment',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "Ontology.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'getGOEnrichment',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method getGOEnrichment",
            status_line => $self->{client}->status_line,
            method_name => 'getGOEnrichment',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::OntologyService::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::OntologyService::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 Species

=over 4



=item Description

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


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoID

=over 4



=item Description

GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoDesc

=over 4



=item Description

GoDesc : Human readable text description of the corresponding GO term


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GeneID

=over 4



=item Description

Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is an external identifier that exists in the public databases such as Gramene, Ensembl, NCBI etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 EvidenceCode

=over 4



=item Description

Evidence code indicates how the annotation to a particular term is supported. 
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


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Domain

=over 4



=item Description

Captures which branch of knowledge the GO terms refers to e.g. "biological_process", "molecular_function", "cellular_component" etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 TestType

=over 4



=item Description

Test type, whether it's "hypergeometric" and "chisq"


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoIDList

=over 4



=item Description

A list of ontology identifiers


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoID
</pre>

=end html

=begin text

a reference to a list where each element is a GoID

=end text

=back



=head2 GoDescList

=over 4



=item Description

a list of GO terms description


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoDesc
</pre>

=end html

=begin text

a reference to a list where each element is a GoDesc

=end text

=back



=head2 GeneIDList

=over 4



=item Description

A list of gene identifiers from same species


=item Definition

=begin html

<pre>
a reference to a list where each element is a GeneID
</pre>

=end html

=begin text

a reference to a list where each element is a GeneID

=end text

=back



=head2 DomainList

=over 4



=item Description

A list of ontology domains


=item Definition

=begin html

<pre>
a reference to a list where each element is a Domain
</pre>

=end html

=begin text

a reference to a list where each element is a Domain

=end text

=back



=head2 StringArray

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 EvidenceCodeList

=over 4



=item Description

A list of ontology term evidence codes. One ontology term can have one or more evidence codes.


=item Definition

=begin html

<pre>
a reference to a list where each element is an EvidenceCode
</pre>

=end html

=begin text

a reference to a list where each element is an EvidenceCode

=end text

=back



=head2 GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc


=end text

=back



=head2 GoTermInfoList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a GoTermInfo
</pre>

=end html

=begin text

a reference to a list where each element is a GoTermInfo

=end text

=back



=head2 GoIDMap2GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GoID and the value is a GoTermInfoList
</pre>

=end html

=begin text

a reference to a hash where the key is a GoID and the value is a GoTermInfoList

=end text

=back



=head2 GeneIDMap2GoInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
</pre>

=end html

=begin text

a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo

=end text

=back



=head2 Enrichment

=over 4



=item Description

A composite data structure to capture ontology enrichment type object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float


=end text

=back



=head2 EnrichmentList

=over 4



=item Description

A list of ontology enrichment objects


=item Definition

=begin html

<pre>
a reference to a list where each element is an Enrichment
</pre>

=end html

=begin text

a reference to a list where each element is an Enrichment

=end text

=back



=cut

package Bio::KBase::OntologyService::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        $obj->{id} = $self->id if (defined $self->id);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
