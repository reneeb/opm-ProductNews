# --
# Copyright (C) 2011 - 2023 Perl-Services.de, https://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ProductNews;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::System::User
    Kernel::System::Valid
    Kernel::System::DB
    Kernel::System::Log
    Kernel::System::Time
    Kernel::System::JSON
);

=head1 NAME

Kernel::System::ProductNews - backend for product news

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item NewsAdd()

to add a news 

    my $ID = $NewsObject->NewsAdd(
        Headline => 'A headline for the news',
        Teaser   => 'A teaser for the news',
        Body     => 'Anything is happened',
        Displays => '[]',                     # JSON Array
        ValidID  => 1,
        UserID   => 123,
    );

=cut

sub NewsAdd {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(Headline Teaser Body ValidID UserID Displays)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{ValidID}          ||= 0;
    $Param{InvalidateEpoche} ||= 0;
    $Param{OpenNews}         ||= 0;
    $Param{Position}         ||= 0;

    # insert new news
    return if !$DBObject->Do(
        SQL => 'INSERT INTO product_news '
            . '(headline, teaser, body, create_time, create_by, valid_id, '
            . ' change_time, change_by, displays, invalidate_epoche, open_news, position) '
            . 'VALUES (?, ?, ?, current_timestamp, ?, ?, current_timestamp, ?, ?, ?, ?, ?)',
        Bind => [
            \$Param{Headline},
            \$Param{Teaser},
            \$Param{Body},
            \$Param{UserID},
            \$Param{ValidID},
            \$Param{UserID},
            \$Param{Displays},
            \$Param{InvalidateEpoche},
            \$Param{OpenNews},
            \$Param{Position},
        ],
    );

    # get new invoice id
    return if !$DBObject->Prepare(
        SQL   => 'SELECT MAX(id) FROM product_news WHERE headline = ?',
        Bind  => [ \$Param{Headline}, ],
        Limit => 1,
    );

    my $NewsID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $NewsID = $Row[0];
    }

    # log notice
    $LogObject->Log(
        Priority => 'notice',
        Message  => "News '$NewsID' created successfully ($Param{UserID})!",
    );

    return $NewsID;
}


=item NewsUpdate()

to update news 

    my $Success = $NewsObject->NewsUpdate(
        NewsID   => 3,
        Headline => 'A headline for the news',
        Teaser   => 'A teaser for the news',
        Body     => 'Anything is happened',
        Displays => '[]',                     # JSON Array
        ValidID  => 1,
        UserID   => 123,
    );

=cut

sub NewsUpdate {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(NewsID Headline Teaser Body ValidID UserID Displays)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    $Param{ValidID}          ||= 0;
    $Param{InvalidateEpoche} ||= 0;
    $Param{OpenNews}         ||= 0;

    # insert new news
    return if !$DBObject->Do(
        SQL => 'UPDATE product_news SET headline = ?, teaser = ?, body = ?, '
            . 'valid_id = ?, change_time = current_timestamp, change_by = ?, '
            . 'displays = ?, invalidate_epoche = ?, open_news = ? '
            . 'WHERE id = ?',
        Bind => [
            \$Param{Headline},
            \$Param{Teaser},
            \$Param{Body},
            \$Param{ValidID},
            \$Param{UserID},
            \$Param{Displays},
            \$Param{InvalidateEpoche},
            \$Param{OpenNews},
            \$Param{NewsID},
        ],
    );

    return 1;
}

=item NewsGet()

returns a hash with news data

    my %NewsData = $NewsObject->NewsGet( NewsID => 2 );

This returns something like:

    %NewsData = (
        'NewsID'     => 2,
        'Headline'   => 'This is the headline',
        'Teaser'     => 'A short abstract',
        'Body'       => 'This is the long text of the news',
        'Displays'   => '["Dashboard"]',
        'CreateTime' => '2010-04-07 15:41:15',
        'CreateBy'   => 123,
    );

=cut

sub NewsGet {
    my ( $Self, %Param ) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    # check needed stuff
    if ( !$Param{NewsID} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need NewsID!',
        );
        return;
    }

    # sql
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, headline, teaser, body, create_time, create_by, '
            . '     valid_id, displays, invalidate_epoche, open_news, position '
            . 'FROM product_news WHERE id = ?',
        Bind  => [ \$Param{NewsID} ],
        Limit => 1,
    );

    my %News;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        %News = (
            NewsID           => $Data[0],
            Headline         => $Data[1],
            Teaser           => $Data[2],
            Body             => $Data[3],
            CreateTime       => $Data[4],
            CreateBy         => $Data[5],
            ValidID          => $Data[6],
            Displays         => $Data[7],
            InvalidateEpoche => $Data[8],
            OpenNews         => $Data[9],
            Position         => $Data[10],
        );
    }

    $News{Valid}  = $ValidObject->ValidLookup( ValidID => $News{ValidID} );
    $News{Author} = $UserObject->UserLookup( UserID => $News{CreateBy} );

    return %News;
}

=item NewsDelete()

deletes a news entry. Returns 1 if it was successful, undef otherwise.

    my $Success = $NewsObject->NewsDelete(
        NewsID => 123,
    );

=cut

sub NewsDelete {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    if ( !$Param{NewsID} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need NewsID!',
        );
        return;
    }

    return $DBObject->Do(
        SQL  => 'DELETE FROM product_news WHERE id = ?',
        Bind => [ \$Param{NewsID} ],
    );
}

=item NewsPositionSet()

to update news 

    my $Success = $NewsObject->NewsUpdate(
        NewsID   => 3,
        Position => 1,
        UserID   => 123,
    );

=cut

sub NewsPositionSet {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(NewsID Position UserID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # insert new news
    return if !$DBObject->Do(
        SQL => 'UPDATE product_news SET position = ?, '
            . 'change_time = current_timestamp, change_by = ? '
            . 'WHERE id = ?',
        Bind => [
            \$Param{Position},
            \$Param{UserID},
            \$Param{NewsID},
        ],
    );

    return 1;
}

=item NewsList()

returns a hash of all news

    my %News = $NewsObject->NewsList();

returns a hash of all valid news

    my %News = $NewsObject->NewsList( Valid => 1 );

returns a hash of all news for a specific display

    my %News = $NewsObject->NewsList( Display => 'AgentTicketEmail' );

the result looks like

    %News = (
        '1' => 'News 1',
        '2' => 'Test News',
    );

=cut

sub NewsList {
    my ( $Self, %Param ) = @_;

    my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject  = $Kernel::OM->Get('Kernel::System::JSON');

    my $Where = '';
    my @Bind;

    $Param{Return} ||= 'List';

    if ( $Param{Valid} ) {
        my $ValidID = $ValidObject->ValidLookup( Valid => 'valid' );
        $Where = 'WHERE valid_id = ?';
        @Bind  = ( \$ValidID );
    }

    # sql
    return if !$DBObject->Prepare(
        SQL  => "SELECT id, teaser, displays FROM product_news $Where ORDER BY position ASC, create_time DESC",
        Bind => \@Bind,
    );

    my %News;
    my @IDs;

    DATA:
    while ( my @Data = $DBObject->FetchrowArray() ) {
        if ( $Param{Display} ) {
            my $Displays = $JSONObject->Decode( Data => $Data[2] || '["Dashboard"]' );
            next DATA if !first{ $Param{Display} eq $_ } @{$Displays};
        }

        $News{ $Data[0] } = $Data[1];

        push @IDs, $Data[0];
    }

    if ( $Param{Return} eq 'Sorted' ) {
        return @IDs;
    }
    return %News;
}

sub InvalidateNews {
    my ($Self, %Param) = @_;

    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $Current = $TimeObject->SystemTime();

    my $SQL = 'UPDATE product_news '
        . ' SET valid_id = 2 '
        . ' WHERE invalidate_epoche IS NOT NULL '
        . '    AND invalidate_epoche < ?'
        . '    AND invalidate_epoche != 0';

    return $DBObject->Do(
        SQL  => $SQL,
        Bind => [ \$Current ],
    );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
