# NAME
[![Build Status](https://travis-ci.org/binary-com/perl-CSV-HistoryPlayer.svg?branch=master)](https://travis-ci.org/binary-com/perl-CSV-HistoryPlayer)
[![codecov](https://codecov.io/gh/binary-com/perl-CSV-HistoryPlayer/branch/master/graph/badge.svg)](https://codecov.io/gh/binary-com/perl-CSV-HistoryPlayer)

CSV::HistoryPlayer - Plays scattered CSV files with historic data

# VERSION

0.02

# STATUS

# SYNOPSYS

    use CSV::HistoryPlayer;

    my $player = CSV::HistoryPlayer->(root_dir => 'path/to/directory');
    while (my $data = $player->poll) {
      my ($file, $row) = @$data;
      print "event occured at ", $row->[0], "\n";
    }

# DESCRIPTION

Let's assume you have many of CSV-files, each one has some events
written in it (in the **first** column in form of unix timestamp) and
filenames also have encoded date of the events within, i.e.

    ├── income
    │   ├── 2015-02-10.csv
    │   └── 2015-02-12.csv
    └── outcome
        ├── 2015-02-11.csv
        └── 2015-02-12.csv

Let's assume, that the files have content like:

    income/2015-02-10.csv: 1455106611, 10, "got pocket money from Mom"
    income/2015-02-12.csv: 1455301001, 15, "got pocket money from Dad"
    outcome/2015-02-11.csv: 1455203801, 10, "bought Immortal CD (black metal)"
    outcome/2015-02-12.csv: 1455307400, 10, "bought Obsidian Gate CD (black metal)"

Now, you would to replay all transactions. That's easy

    use CSV::HistoryPlayer;

    my $player = CSV::HistoryPlayer->(root_dir => 'path/to/directory');
    while (my $data = $player->poll) {
      my ($file, $row) = @$data;
      my ($when, $how_much, $description) = @$row;
      my $sign = $file =~ /income/ ? '+' : '-';
      print $sign, " ", $how_much, '$: ', $description, "\n";
    }

    # +10$: got pocket money from Mom
    # -10$: bought Immortal CD (black metal)
    # +15$: got pocket money from Dad
    # -10$: bought Obsidian Gate CD (black metal)

I.e. the [CSV::HistoryPlayer](https://metacpan.org/pod/CSV::HistoryPlayer) virtually unites scattered CSV files,
and allows to read evens from them in historically correct order.

# ATTRIBUTES

- `root_dir`

    The root directory, where the csv files should be searched from.
    This attribute is **mandatory**.

- `dir_filter`

    The closure, which allows to filter out unneeded directories,
    in the file scan phase to do not include csv-files within

        my $player = CSV::HistoryPlayer->(
          ...,
          # if returns true, than dir will be scanned for csv-files
          dir_filter => sub { $_[0] =~ /income/ },
        );

    By default, all found directories are allowed to be scanned
    for CSV-files.

- `files_mapper`

    The closure, which allows to do custom sort and filtering of found
    CSV-files in historical order.

    By default CSV-files are lexically sorted and not filtered.

    For example, if there are files `3-Jan-16.csv`, `4-Jan-16.csv`,
    ..., they can be sorted with [Date::Utility](https://metacpan.org/pod/Date::Utility)

        files_maper => sub {
          my $orig_files = shift;
          my @files =
            map  { $_->{file} }
            sort { $a->{epoch} <=> $b->{epoch} }
            map  {
              my $date = /(.*\/)(.+)/ ? $2 : die("wrong filename in $_");
              {
                file  => $_,
                epoch => Date::Utility->new($date)->epoch,
              }
            } @$orig_files;
          return \@files;
        }

- `files`

    Returns historically sorted list of found CSV-files; each item in
    the list is [Path::Tiny](https://metacpan.org/pod/Path::Tiny) instance.

# METHODS

- `peek`

    Returns the reference to the current pointer in the i&lt;virtual> CSV-file
    and the actual file.

    Initially it points to the earliest row of the historically first file.
    If there are many concurrent files, than the earliest row of them is returned.

    If end of i&lt;virtual> CSV-file is reached, then `undef` is returned

        my $data = $player->peak;
        if ($data) {
          my ($file, $row) = @$data;
        }

- `poll`

    The same as `peak` method, but after return of the current row in
    the  i&lt;virtual> CSV-file, it moves the pointer to the next row.
    Designed to serve as iterator,

        while (my $data = $player->poll) {
          my ($file, $row) = @$data;
        }

# ASSUMPTIONS

- Same filenames for the same timeframe

    CSV-files aggregate events on some time-frame (i.e. one day, one hour,
    one week etc.). The [CSV::HistoryPlayer](https://metacpan.org/pod/CSV::HistoryPlayer) does not sort content of
    files due to performance reasons. Than means, if you have files, organized
    like:

        event-a/date_1.csv
        event-b/date_2.csv

    and `date_1` and `date_2` intersects, then they should have exactly
    the same name, e.g.:

        event-a/3-Jan-16.csv
        event-b/3-Jan-16.csv

    to be replayed correctly.

- unix timestamp is the first column in CSV-files
- CSV-files are opened with the defaults of [Text::CSV](https://metacpan.org/pod/Text::CSV)

# SEE ALSO

[Text::CSV](https://metacpan.org/pod/Text::CSV), [Higher-Order Perl](http://hop.perl.plover.com)

# SOURCE CODE

[GitHub](https://github.com/binary-com/perl-CSV-HistoryPlayer)

# AUTHOR

binary.com, `<perl at binary.com>`

# BUGS

Please report any bugs or feature requests to
[https://github.com/binary-com/perl-CSV-HistoryPlayer/issues](https://github.com/binary-com/perl-CSV-HistoryPlayer/issues).

# LICENSE AND COPYRIGHT

Copyright (C) 2016 binary.com

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
