package OpenERP::XMLRPC::Client::Role::ReportReportGet;
# ABSTRACT: Role to structure rpc call to OpenERP.

use Moose::Role;

requires ('change_uri');

has '_report_report_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/report' );

sub report_report_get
{
	my $self = shift;

	my $report_id	= shift;	# eg. 123

	# change the uri to base uri we are going to query..
    $self->change_uri( $self->_object_execute_uri );

    $self->openerp_rpc->simple_request
	(
		'report_get',
		$self->dbname,
		$self->openerp_uid,
		$self->password,
		$report_id
	);

}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Client::Role::ReportReportGet - Role to structure rpc call to OpenERP.

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

