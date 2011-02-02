package OpenERP::XMLRPC::Simple;
# ABSTRACT: Simple interaction with OpenERP XML RPC interface.


use Moose;

BEGIN { extends 'OpenERP::XMLRPC::Client' };

has 'username'  => ( is  => 'ro', isa => 'Str', default => 'admin');
has 'password'  => ( is  => 'ro', isa => 'Str', default => 'admin');
has 'dbname'    => ( is  => 'ro', isa => 'Str', default => 'terp');
has 'host'      => ( is  => 'ro', isa => 'Str', default => '127.0.0.1');
has 'port'      => ( is  => 'ro', isa => 'Int', default => 8069);
has 'proto'     => ( is  => 'ro', isa => 'Str', default => 'http');

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


=pod

=head1 NAME

OpenERP::XMLRPC::Simple - Simple interaction with OpenERP XML RPC interface.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

	# CONNECT
	my $erp = OpenERP::XMLRPC::Simple->new( dbname => 'my_openerp_db', username => 'mylogin', password => 'mypassword', host => '10.0.0.123' );

	# READ a res.partner object
	my $partner = $erp->read( 'res.partner', $id );

	print "You Found Partner:" . $partner->{name} . "\n";

=head1 DESCRIPTION

This module brings together a number of moose roles and the L<OpenERP::XMLRPC::Client> to 
create a simple and easy to use interface to communicate with OpenERP.

=head1 NAME

OpenERP::XMLRPC::Simple - Simply communicate with your OpenERP database.

=head1 PARAMETERS

    username        - string - openerp username (default: 'admin')
    password        - string - openerp password (default: 'admin')
    dbname          - string - openerp database name (default: 'terp')
    host            - string - openerp rpc server host (default: '127.0.0.1' )
    port            - string - openerp rpc server port (default: 8069)
    proto           - string - openerp protocol (default: http)

=head1 METHODS

These methods re-present the OpenERP XML RPC but in a slightly more user friendly way.

The methods have been tested using the 'res.partner' object name and the demo database
provided when you install OpenERP. 

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

L<OpenERP::XMLRPC::Client>, L<RPC::XML::Client>, L<Moose::Role>

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


