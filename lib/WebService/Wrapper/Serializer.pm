package WebService::Wrapper::Serializer;
our $VERSION = '0.01';

=head1 NAME

WebService::Wrapper::Serializer

=head1 SYNOPSIS

  use WebService::MyService;    # isa WebService::Wrapper
  my $api = WebService::MyService->new;
  my $result = $api->request;
  $result->xml;
  $result->json;
  $result->yaml;

=cut

use Modern::Perl;
use Data::Dumper;
use Acme::Curse qw/curse/;
use Module::Pluggable   search_path => 'WebService::Wrapper::Serializer',
                        require     => 1;

our %plugins = do {
    no strict 'refs';
    map {
        $_->name => {
            check   => *{"$_\::check"},
            load    => *{"$_\::load"},
            dump    => *{"$_\::dump"},
        }
    } __PACKAGE__->plugins;
};

our $AUTOLOAD;
sub AUTOLOAD {
    my ($self, $data) = @_;
    my $name = $AUTOLOAD =~ s/.*://r;
    $plugins{$name}->{dump}->($$self[0], curse $data) if exists $plugins{$name}
}

sub load_results {
    my ($class, $result) = @_;
    for my $plugin (values %plugins) {
        return bless([$plugin->{load}->($result->decoded_content)], $class)
            if $plugin->{check}->(($result->content_type)[0])
    }
}


1
