#!/usr/bin/perl

# Implements GenSel Bayes analysis
# Supports BayesA, BayesB, BayesC, BayesCPi, but not BayesCCSub

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use File::Basename;

our $VERSION = '1.0.0';
use vars qw($VERSION);

my $GENSEL_ROOT="/usr/local2/GSrun4.55R";
$ENV{'PATH'}="$GENSEL_ROOT/bin" . ":" . $ENV{'PATH'};
$ENV{'LD_LIBRARY_PATH'}="$GENSEL_ROOT/lib";

# Define workflow options
my ($marker_file, $phenotype_file, $inclusion_file, $exclusion_file, $inclusion_range, $bayes_type, $chain_length, $burnin, $hastings, $var_genotypic, $var_residual, $prob_fixed, $degrees_freedom_effect_var, $nures, $seed, $plotposterior, $modelsequence);

GetOptions( "marker=s" => \$marker_file,
			"phenotype=s" => \$phenotype_file,
			"includef=s" => \$inclusion_file,
			"excludef=s" => \$exclusion_file,
			"includer=s" => \$inclusion_range,
			"bayestype=s" => \$bayes_type,
			"chain=i" => \$chain_length,
			"burnin=i" => \$burnin,
			"hastings=i" => \$hastings,
			"genovar=f" => \$var_genotypic,
			"resvar=f" => \$var_residual,
			"probfixed=f" => \$prob_fixed,
			"dofv=i" => \$degrees_freedom_effect_var,
			"nures=i" => \$nures,
			"seed=i" => \$seed,
			"plot" => \$plotposterior,
			"model" => \$modelsequence	);

# Force fixed decimal notation for floats
$var_genotypic = sprintf("%.8f", $var_genotypic);
$var_residual = sprintf("%.8f", $var_residual);
$prob_fixed = sprintf("%.8f", $prob_fixed);

# Marker inclusion and exclusion behavior
# Logic favors range > includeFile > excludeFile
my $include_or_exclude_parameter = "";
if (defined($inclusion_range)) {
	$include_or_exclude_parameter = "includeRange $inclusion_range"
} elsif (defined($inclusion_file)) {
	$include_or_exclude_parameter = "includeFileName $inclusion_file"
} elsif (defined($exclusion_file)) {
	$include_or_exclude_parameter = "excludeFileName  $exclusion_file"
}

# All BayesTypes except for BayeA expect a probFixed value to be passed
my $prob_fixed_parameter = "";
if ((defined($prob_fixed) and ($bayes_type !~ /BayesA/i))) {
	$prob_fixed_parameter = "probFixed $prob_fixed"
}

# Support for BayesA nuRes which sets df for residual
my $nures_parameter = "";
if ((defined($nures) and ($bayes_type =~ /BayesA/i))) {
	$nures_parameter = "nuRes $nures"
}

# Support for Metropolis Hastings
my $hastings_parameter = "";
if ((defined($hastings) and ($bayes_type =~ /Bayes[AB]/i))) {
	$hastings_parameter = "numMHIter $hastings"
}

# Plot behavior
my $plot_parameter = "";
if ($plotposterior) {
	$plot_parameter = "plotPosteriors yes"
} else {
	$plot_parameter = "plotPosteriors no"
}

# Plot behavior
my $modelsequence_parameter = "";
if ($modelsequence) {
	$modelsequence_parameter = "modelSequence yes"
} else {
	$modelsequence_parameter = "modelSequence no"
}

# Seed value
my $seed_param = "";
if (defined($seed)) {
	$seed_param = "seed $seed"
}

my $param_file = <<END;

markerFileName $marker_file
phenotypeFileName $phenotype_file
$include_or_exclude_parameter
analysisType Bayes
bayesType $bayes_type
chainLength $chain_length
burnin $burnin
$hastings_parameter
varGenotypic $var_genotypic
varResidual $var_residual
degreesFreedomEffectVar $degrees_freedom_effect_var
$prob_fixed_parameter
$nures_parameter
$seed_param
addMapInfoToMarkers no
mcmcSamples no
$plot_parameter
$modelsequence_parameter

END

open (SCRIPT, ">run.inp");
print SCRIPT $param_file;
close SCRIPT;

my $result = system("$GENSEL_ROOT/bin/GenSel run.inp");

exit $result;

=head1 AUTHOR

Matthew Vaughn
University of Texas
Texas Advanced Computing Center
vaughn@tacc.utexas.edu

=head1 COPYRIGHT

The full text of the license can be found in the
LICENSE file included with this module.

=cut
