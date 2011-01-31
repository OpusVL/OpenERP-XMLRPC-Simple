package OpenERP::XMLRPC::Client::Role::ObjectExecWorkflow;
# ABSTRACT: Role to structure rpc call to OpenERP.

use Moose::Role;

requires ('change_uri');

has '_object_exec_workflow_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/object' );

sub object_exec_workflow
{
	my $self = shift;

	my $method 		= shift;	# eg. 'search'
	my $relation 	= shift;	# eg. 'res.partner'
	my @args 		= @_;		# All other args we just pass on.

	# change the uri to base uri we are going to query..
    $self->change_uri( $self->_object_exec_workflow_uri );

    $self->openerp_rpc->simple_request
	(
		'exec_workflow',
		$self->dbname,
		$self->openerp_uid,
		$self->password,
		$relation,
		$method,
		@args
	);

}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Client::Role::ObjectExecWorkflow - Role to structure rpc call to OpenERP.

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

