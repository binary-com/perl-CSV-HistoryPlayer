use strict;
use warnings;
BEGIN {
    eval "use ExtUtils::MakeMaker 6.64; 1" or do {
        print "need ExtUtils::MakeMaker >= 6.64\n";
        exit 0;
    };
}

WriteMakefile(
    NAME             => 'CSV::HistoryPlayer',
    AUTHOR           => q{binary.com <perl@binary.com>},
    VERSION_FROM     => 'lib/CSV/HistoryPlayer.pm',
    ABSTRACT         => 'Plays scattered CSV files with historic data',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => '5.10.0',
    clean            => {FILES => 'CSV-HistoryPlayer-*'},
    CONFIGURE_REQUIRES => {
        "ExtUtils::MakeMaker" => "6.64",
    },
    PREREQ_PM => {
        "List::MoreUtils" => 0,
        "Moo"             => 0,
        "Path::Tiny"      => 0,
        "Text::CSV"       => 0,
    },
    TEST_REQUIRES => {
        "Test::More"     => 0,
        "Test::Warnings" => 0,
    },
    META_MERGE => {
        'meta-spec' => {version => 2},
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/binary-com/perl-CSV-HistoryPlayer.git',
                web  => 'https://github.com/binary-com/perl-CSV-HistoryPlayer',
            },
        }
    },
);
