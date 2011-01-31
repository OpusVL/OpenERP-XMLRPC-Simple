package Test::MockOpenERP;

=head1 NAME

Test::MockOpenERP - Something to test against

=head1 DESCRIPTION

This is just an HTTP server that serves responses to OpenERP RPC structured requests.
Based roughly on the request this will server the response from the source files 
held within the 'auto' dir.

=cut

use strict;
use warnings;

use Net::HTTPServer;
use HTTP::Response;
use HTTP::Request;
use File::ShareDir qw/module_dir/;
use XML::Simple;
use File::Slurp;

# Get the path for the response source files (using the 'auto' name space)..
our $MOCKSOURCE_DIR = File::ShareDir::module_dir( 'Test::MockOpenERP' ) . '/rpc_responses';

use IO::File;

our $PID  = $$;

END { __PACKAGE__->stop(); }

sub start
{
    my $self 	= shift;

    my $port	= 5555;

    # Ignore CHLD
    local $SIG{CHLD} = 'IGNORE';

    # Fork
    my $pid = fork();

    if ( $pid == 0 )
    {
    	# Create pid file
    	_createPid( "/tmp/openerp_httpd.pid" );

    	# Create server
    	eval
    	{
    		# Create http server..
			my $server = new Net::HTTPServer( port => $port, log => '/dev/null' );

			$server->RegisterURL("/xmlrpc/object",\&object);
			$server->RegisterURL("/xmlrpc/common",\&common);

			my $port_no = $server->Start();

			$server->Process();  # Run forever
    	};

    	if ($@)
    	{
    		# Remove pid file
    		unlink "/tmp/openerp_httpd.pid";

    		# die
    		die $@;
    	}

    	# Exit nicely
    	exit(0);
    }

    # Wait up to 5 seconds for server to start;
    die "Failed to start http server" unless _waitpid( 5, "/tmp/openerp_httpd.pid", $pid );	

}

sub stop
{
	# Only cleanup parent process.
	if ( $PID && $PID == $$ )
	{
		if ( my $fh = IO::File->new( "/tmp/openerp_httpd.pid", 'r') )
		{
			# Get pid.
			my $pid;
			$fh->read( $pid, 16384 ); 
			$pid =~ s/\D//g;
			
			# Kill server
			kill 4, $pid if $pid;
		}
	}
}

sub _createPid 
{
    my $fh = IO::File->new( shift, 'w') || die "Couldn't create pid";
    $fh->print("$$");
    $fh->close(); 
    return;
}

sub _waitpid 
{
    my $secs = shift || 5;
    my $file = shift || die "Missing pid file";
	my $pid = shift;
	for( my $i=0; $i <= $secs; $i++ )
	{

		sleep 1;

		my $fh = IO::File->new( $file, 'r');
		if ( $fh )
		{
			my $logged_pid = $fh->getline;
			return $logged_pid if ( $logged_pid == $pid );
		}
		$fh->close;
	}
}




sub object
{
    my $req = shift;             # Net::HTTPServer::Request object
	return _response_from_file( $req->Response, _get_fake_file_path_standard( $req->URL, _parse_req( $req ) ) );
}



sub common
{
    my $req = shift;             # Net::HTTPServer::Request object

	my $fake_http_response_ext = '.http_response';

	my $req_ref = _parse_req( $req ); # parse xml into a hash..

	# find fake http response file path..

    # .. split the path ..
    my ( $nothing, $xmlrpc, $method_class ) = split ('/', $req->URL );

	# .. build path based on defaults + rpc xml request..
	my $fake_http_response_base = $MOCKSOURCE_DIR . '/' . $method_class . '/' . $req_ref->{methodName};
	my $fake_http_response_file = $fake_http_response_base . $fake_http_response_ext;

	# open file and set response.
	return _response_from_file( $req->Response, $fake_http_response_file );

}






sub _response_from_file
{
	my $res = shift;
	my $file  = shift;

	die ("Could not fake response with: $file ")
		unless ( -f $file );

	print STDERR "FAKING WITH FILE: $file \n" if $ENV{DEBUG};
	
	my $res_src = read_file( $file ) ;

	my $http_res = HTTP::Response->parse( $res_src );

	# set the content of the Net::HTTPServer::Response object passed..
	$res->Body(	$http_res->content );
	map { $res->Header($_ , $http_res->header( $_ ) ) } $http_res->header_field_names;

	return $res;
}

sub _parse_req
{
	my $req = shift;

    # build HTTP::Request object..
    my $r = HTTP::Request->parse( $req->Request );

    my $src_xml = $r->content;

	print STDERR "REQUESRED XML: $src_xml \n" if $ENV{DEBUG};

    $src_xml =~ s/^<\?xml .+?\?>//;

    my $xs = XML::Simple->new;
    my $req_ref = $xs->XMLin( $src_xml );

    # simple procedural interface
	use Data::Dumper;

    print STDERR Dumper($req_ref) if $ENV{DEBUG};

	return $req_ref;
}

sub _get_fake_file_path_standard
{
	my $req_url = shift;
	my $req_ref = shift;

	my $fake_http_response_ext = '.http_response';

    # .. split the path ..
    my ( $nothing, $xmlrpc, $method_class ) = split ('/', $req_url );

	# .. put it together ..
	my $fake_http_response_base = $MOCKSOURCE_DIR . '/' . $method_class . '/' . $req_ref->{methodName} . '_' . $req_ref->{params}->{param}->[4]->{value}->{string};

	my $fake_http_response_file = $fake_http_response_base . $fake_http_response_ext;
	return $fake_http_response_file;
}

1;
__END__
