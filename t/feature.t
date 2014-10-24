use strict;
use warnings;

use Test::More;

plan skip_all => 'feature check irrelevant on v5.8'
    if $] <= 5.010;

{
    package TestClass;

    use Reindeer;
    use Test::More;

    BEGIN {
        ok($^H{$_}, "$_ is enabled")
            for map { "feature_$_" } qw{ switch state say };
    }
}

{
    package TestRole;

    use Reindeer::Role;
    use Test::More;

    BEGIN {
        ok($^H{$_}, "$_ is enabled")
            for map { "feature_$_" } qw{ switch state say };
    }
}

done_testing;
