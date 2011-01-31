package OpenERP::XMLRPC::Client;
# ABSTRACT: XMLRPC Client tweaked for OpenERP interaction.


use Moose;


has 'username' 	=> ( is  => 'ro', isa => 'Str', default => 'admin');
has 'password' 	=> ( is  => 'ro', isa => 'Str', default => 'admin');
has 'dbname' 	=> ( is  => 'ro', isa => 'Str', default => 'terp');
has 'host' 		=> ( is  => 'ro', isa => 'Str', default => '127.0.0.1');
has 'port' 		=> ( is  => 'ro', isa => 'Int', default => 8069);
has 'proto'		=> ( is  => 'ro', isa => 'Str', default => 'http');

with 'MooseX::Role::XMLRPC::Client' => 
{ 
	name => 'openerp',
	login_info => 1,
};

sub _build_openerp_userid { shift->username }
sub _build_openerp_passwd { shift->password }
sub _build_openerp_uri
{
	my $self = shift;
	return $self->proto . '://' . $self->host . ':' . $self->port . '/' . $self->base_rpc_uri;
}

sub openerp_login
{
	my $self = shift;

	# call 'login' method to get the uid..
	my $res = $self->openerp_rpc->send_request('login', $self->dbname, $self->username, $self->password );

	if ( ! defined $res || ! ref $res )
	{
		die "Failed to log into OpenERP XML RPC service";
	}

	# set the uid we have just had returned from logging in..
	$self->openerp_uid( ${ $res } );
}

sub openerp_logout
{
	my $self = shift;
	# do nothing on logout...nothing is required..
}


has 'openerp_uid' 	=> ( is  => 'rw', isa => 'Int' );
has 'base_rpc_uri'	=> ( is  => 'rw', isa => 'Str', default => 'xmlrpc/common');



sub BUILD
{
	my $self = shift;
	$self->openerp_login;
}


sub change_uri
{
	my $self = shift;
	my $base_uri = shift;

	my $exsting_base_uri = $self->base_rpc_uri;

	return $exsting_base_uri if $base_uri eq $exsting_base_uri;

	$self->base_rpc_uri( $base_uri );						# change the base path.
	$self->openerp_rpc->uri( $self->_build_openerp_uri ); 	# rebuild and set the new uri.
	return $exsting_base_uri; # return the old uri.
}


with 'OpenERP::XMLRPC::Client::Role::ObjectExecute';





with 'OpenERP::XMLRPC::Client::Role::ObjectExecWorkflow';





with 'OpenERP::XMLRPC::Client::Role::ReportReport';





with 'OpenERP::XMLRPC::Client::Role::ReportReportGet';


1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Client - XMLRPC Client tweaked for OpenERP interaction.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

	my $rpc = OpenERP::XMLRPC::Client->new( dbname => 'terp', username => 'admin', password => 'admin', host => '127.0.0.1', port => '8069' )	
	my $partner_ids = $rpc->object_execute( 'res.partner', 'search', [ 'name', 'ilke', 'abc' ] );

=head1 DESCRIPTION

I have tried to make this extendable so made use of moose roles to structure the calls to the
different methods available from the openerp rpc.

This makes use of the L<MooseX::Role::XMLRPC::Client> to communicate via rpc.

This module was built to be used by another L<OpenERP::XMLRPC::Simple> and handles 
openerp specific rpc interactions. It could be used by something else to access 
openerp rpc services.

=head1 NAME

OpenERP::XMLRPC::Client - XML RPC Client for OpenERP

=head1 Parameters

	username		- string - openerp username (default: 'admin')
	password		- string - openerp password (default: 'admin')
	dbname			- string - openerp database name (default: 'terp')
	host			- string - openerp rpc server host (default: '127.0.0.1' )
	port			- string - openerp rpc server port (default: 8069)
	proto			- string - openerp protocol (default: http) .. untested anything else.

=head1 Attributes 	

	openerp_uid		- int 		- filled when the connection is logged in.
	base_rpc_uri	- string	- used to hold uri the rpc is currently pointing to.
	openerp_rpc		- L<RPC::XML::Client> - Provided by L<MooseX::Role::XMLRPC::Client>

=head1 METHODS

=head2 BUILD

When the object is instanciated, this method is run. This calls openerp_login.

=head2 change_uri

OpenERP makes methods available via different URI's, this method is used to change which
URI the rpc client is pointing at. 

Arguments:
	$_[0]	- object ref. ($self)
	$_[1]	- string (e.g. "xmlrpc/object") base uri path.

Returns:
	string	- the old uri - the one this new one replaced.

=head1 ROLES

=head2 MooseX::Role::XMLRPC::Client

Used to establish and communicate via an xml rpc connection to OpenERP.

=head2 OpenERP::XMLRPC::Client::Role::ObjectExecute

Used to call 'execute' method in OpenERP RPC against the 'xmlrcp/object' uri.

Provides: ->object_execute

=head2 OpenERP::XMLRPC::Client::Role::ObjectExecWorkflow

Used to call 'exec_workflow' method in OpenERP RPC against the 'xmlrcp/object' uri.

Provides: ->object_exec_workflow

=head2 OpenERP::XMLRPC::Client::Role::ReportReport

Used to call 'report' method in OpenERP RPC against the 'xmlrcp/report' uri.

Provides: ->report_report

=head2 OpenERP::XMLRPC::Client::Role::ReportReportGet

Used to call 'report_get' method in OpenERP RPC against the 'xmlrcp/report' uri.

Provides: ->report_report_get

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

