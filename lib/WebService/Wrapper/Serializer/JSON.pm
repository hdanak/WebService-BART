package WebService::Wrapper::Serializer::JSON {
    use JSON qw/from_json to_json/;
    sub name    { 'json' }
    sub check   { shift ~~ /json/i }
    sub load    { from_json(shift) }
    sub dump    { to_json(shift) }
    1
}
