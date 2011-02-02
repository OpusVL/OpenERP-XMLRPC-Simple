package OpenERP::XMLRPC::Client;
# ABSTRACT: XMLRPC Client tweaked for OpenERP interaction.


use Moose;


has 'username' 	=> ( is  => 'ro', isa => 'Str', default => 'admin');
has 'password' 	=> ( is  => 'ro', isa => 'Str', default => 'admin');
has 'dbname' 	=> ( is  => 'ro', isa => 'Str', default => 'terp');
has 'host' 		=> ( is  => 'ro', isa => 'Str', default => '127.0.0.1');
has 'port' 		=> ( is  => 'ro', isa => 'Int', default => 8069);
has 'proto'		=> ( is  => 'ro', isa => 'Str', default => 'http');

has '_report_report_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/report' );
has '_report_report_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/report' );
has '_object_execute_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/object' );
has '_object_exec_workflow_uri'	=> ( is => 'ro', isa => 'Str', default => 'xmlrpc/object' );

has 'openerp_uid' 	=> ( is  => 'rw', isa => 'Int' );
has 'base_rpc_uri'	=> ( is  => 'rw', isa => 'Str', default => 'xmlrpc/common');


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

sub object_execute
{
	my $self = shift;

	my $method 		= shift;	# eg. 'search'
	my $relation 	= shift;	# eg. 'res.partner'
	my @args 		= @_;		# All other args we just pass on.

	# change the uri to base uri we are going to query..
    $self->change_uri( $self->_object_execute_uri );

    $self->openerp_rpc->simple_request
	(
		'execute',
		$self->dbname,
		$self->openerp_uid,
		$self->password,
		$relation,
		$method,
		@args
	);

}

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

sub report_report
{
	my $self = shift;

	my $method 		= shift;	# eg. 'search'
	my $relation 	= shift;	# eg. 'res.partner'
	my @args 		= @_;		# All other args we just pass on.

	# change the uri to base uri we are going to query..
    $self->change_uri( $self->_object_execute_uri );

    $self->openerp_rpc->simple_request
	(
		'report',
		$self->dbname,
		$self->openerp_uid,
		$self->password,
		$relation,
		$method,
		@args
	);

}

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

sub create
{
	my $self 	= shift;
	my $object 	= shift;
	my $args 	= shift;

	return $self->object_execute('create', $object, $args );
}

sub read
{
	my $self 	= shift;
	my $object 	= shift;
	my $ids		= shift;
	my $cols 	= shift;

	# ensure we pass an array of IDs to the RPC..
	$ids = [ $ids ] unless ( ref $ids eq 'ARRAY' );

	return $self->object_execute('read', $object, $ids, $cols );
}

sub search
{
	my $self 	= shift;
	my $object 	= shift;
	my $args 	= shift;
	return $self->object_execute('search', $object, $args );
}

sub update
{
	my $self 	= shift;
	my $object 	= shift;
	my $ids 	= shift;
	my $args 	= shift;

    # ensure we pass an array of IDs to the RPC..
    $ids = [ $ids ] unless ( ref $ids eq 'ARRAY' );

	return $self->object_execute('write', $object, $ids, $args );
}

sub delete
{
	my $self 	= shift;
	my $object 	= shift;
	my $ids 	= shift;

    # ensure we pass an array of IDs to the RPC..
    $ids = [ $ids ] unless ( ref $ids eq 'ARRAY' );

	return $self->object_execute('unlink', $object, $ids );
}

sub search_detail
{
	my $self = shift;
	my $object 	= shift;
	my $args 	= shift;

	# search and get ids..
	my $ids = $self->search( $object, $args );
	return unless ( defined $ids && ref $ids eq 'ARRAY' && scalar @$ids >= 1 );

	# read data from all the ids..
	return $self->read( $object, $ids );
}

sub read_single
{
	my $res = shift->read( @_ );
	return unless ( defined $res && ref $res eq 'ARRAY' && scalar @$res >= 1 );
	return $res->[0];
}



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

	my $erp = OpenERP::XMLRPC::Simple->new( dbname => 'my_openerp_db', username => 'mylogin', password => 'mypassword', host => '10.0.0.123' );

	# READ a res.partner object
	my $partner = $erp->read( 'res.partner', $id );

	print "You Found Partner:" . $partner->{name} . "\n";

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

These methods re-present the OpenERP XML RPC but in a slightly more user friendly way.

The methods have been tested using the 'res.partner' object name and the demo database
provided when you install OpenERP. 

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

=head2 read ( OBJECTNAME, [IDS] )

Can pass this a sinlge ID or an ARRAYREF of ID's, it will return an ARRAYREF of 
OBJECT records (HASHREF's).

Example:
	$partner = $erp->read('res.partner', 1 );
	print "This is the returned record name:" .  $partner->[0]->{name} . "\n";

	$partners = $erp->read('res.partner', [1,2] );
	print "This is the returned record 1:" .  $partners->[0]->{name} . "\n";
	print "This is the returned record 2:" .  $partners->[1]->{name} . "\n";

Returns: ArrayRef of HashRef's - All the objects with IDs passed.

=head2 search ( OBJECTNAME, [ [ COLNAME, COMPARATOR, VALUE ] ] )

Used to search and return IDs of objects matching the searcgh.

Returns: ArrayRef of ID's - All the objects ID's matching the search.

Example:
	$results = $erp->search('res.partner', [ [ 'name', 'ilke', 'abc' ] ] );
	print "This is the 1st ID found:" .  $results->[0] . "\n";

=head2 create ( OBJECTNAME, { COLNAME => COLVALUE } )

Returns: ID	- the ID of the object created.

Example:
	$new_id = $erp->create('res.partner', { 'name' => 'new company name' } );

=head2 update ( OBJECTNAME, ID, { COLNAME => COLVALUE } )

Returns: boolean	 - updated or not.

Example:
	$success = $erp->update('res.partner', 1, { 'name' => 'changed company name' } );

=head2 delete ( OBJECTNAME, ID )

Returns: boolean	 - deleted or not.

Example:
	$success = $erp->delete('res.partner', 1 );

=head2 search_detail ( OBJECTNAME, [ [ COLNAME, COMPARATOR, VALUE ] ] )

Used to search and read details on a perticular OBJECT. This uses 'search' to find IDs,
then calls 'read' to get details on each ID returned.

Returns: ArrayRef of HashRef's - All the objects found with all their details.

Example:
	$results = $erp->search_detail('res.partner', [ [ 'name', 'ilke', 'abc' ] ] );
	print "This is the 1st found record name:" .  $results->[0]->{name} . "\n";

=head2 read_single ( OBJECTNAME, ID )

Pass this a sinlge ID and get a single OBJECT record (HASHREF).

Example:
	$partner = $erp->read_single('res.partner', 1 );
	print "This name of partner with ID 1:" .  $partner->{name} . "\n";

Returns: HashRef 	- The objects data

=head1 SEE ALSO

L<RPC::XML::Client>

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
