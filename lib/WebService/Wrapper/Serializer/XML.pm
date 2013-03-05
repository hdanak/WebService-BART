package WebService::Wrapper::Serializer::XML {
    use XML::Simple qw/XMLin XMLout/;
    sub name    { 'xml' }
    sub check   { shift ~~ /xml/i }
    sub load    { XMLin(shift) }
    sub dump    { XMLout(shift) }
    1
};
