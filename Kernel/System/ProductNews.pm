# --
# Kernel/System/ProductNews.pm - All News related functions should be here eventually
# Copyright (C) 2011 Perl-Services.de, http://perl-services.de/
# --
# $Id: ProductNews.pm,v 1.1.1.1 2011/04/15 07:49:58 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ProductNews;

use strict;
use warnings;

use Kernel::System::User;
use Kernel::System::Valid;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1.1.1 $) [1];

=head1 NAME

Kernel::System::ProductNews - backend for product news

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Main;
    use Kernel::System::DB;
    use Kernel::System::ProductNews;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $NewsObject = Kernel::System::ProductNews->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        EncodeObject => $EncodeObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(DBObject ConfigObject MainObject LogObject EncodeObject TimeObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    # create needed objects
    $Self->{UserObject}  = Kernel::System::User->new( %{$Self} );
    $Self->{ValidObject} = Kernel::System::Valid->new( %{$Self} );
    
    return $Self;
}

=item NewsAdd()

to add a news 

    my $ID = $NewsObject->NewsAdd(
        Headline => 'A headline for the news',
        Teaser   => 'A teaser for the news',
        Body     => 'Anything is happened',
        ValidID  => 1,
        UserID   => 123,
    );

=cut

sub NewsAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Headline Teaser Body ValidID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # insert new news
    return if !$Self->{DBObject}->Do(
        SQL => 'INSERT INTO product_news '
            . '(headline, teaser, body, create_time, create_by, valid_id, change_time, change_by) '
            . 'VALUES (?, ?, ?, current_timestamp, ?, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Headline},
            \$Param{Teaser},
            \$Param{Body},
            \$Param{UserID},
            \$Param{ValidID},
            \$Param{UserID},
        ],
    );

    # get new invoice id
    return if !$Self->{DBObject}->Prepare(
        SQL   => 'SELECT MAX(id) FROM product_news WHERE headline = ?',
        Bind  => [ \$Param{Headline}, ],
        Limit => 1,
    );

    my $NewsID;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $NewsID = $Row[0];
    }

    # log notice
    $Self->{LogObject}->Log(
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
        ValidID  => 1,
        UserID   => 123,
    );

=cut

sub NewsUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(NewsID Headline Teaser Body ValidID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # insert new news
    return if !$Self->{DBObject}->Do(
        SQL => 'UPDATE product_news SET headline = ?, teaser = ?, body = ?, '
            . 'valid_id = ?, change_time = current_timestamp, change_by = ? '
            . 'WHERE id = ?',
        Bind => [
            \$Param{Headline},
            \$Param{Teaser},
            \$Param{Body},
            \$Param{ValidID},
            \$Param{UserID},
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
        'CreateTime' => '2010-04-07 15:41:15',
        'CreateBy'   => 123,
    );

=cut

sub NewsGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{NewsID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need NewsID!',
        );
        return;
    }

    # sql
    return if !$Self->{DBObject}->Prepare(
        SQL => 'SELECT id, headline, teaser, body, create_time, create_by, valid_id '
            . 'FROM product_news WHERE id = ?',
        Bind  => [ \$Param{NewsID} ],
        Limit => 1,
    );

    my %News;
    while ( my @Data = $Self->{DBObject}->FetchrowArray() ) {
        %News = (
            NewsID     => $Data[0],
            Headline   => $Data[1],
            Teaser     => $Data[2],
            Body       => $Data[3],
            CreateTime => $Data[4],
            CreateBy   => $Data[5],
            ValidID    => $Data[6],
        );
    }

    $News{Valid}  = $Self->{ValidObject}->ValidLookup( ValidID => $News{ValidID} );
    $News{Author} = $Self->{UserObject}->UserLookup( UserID => $News{CreateBy} );

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

    # check needed stuff
    if ( !$Param{NewsID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need NewsID!',
        );
        return;
    }

    return $Self->{DBObject}->Do(
        SQL  => 'DELETE FROM product_news WHERE id = ?',
        Bind => [ \$Param{NewsID} ],
    );
}


=item NewsList()

returns a hash of all news

    my %Newss = $NewsObject->NewsList();

the result looks like

    %Newss = (
        '1' => 'News 1',
        '2' => 'Test News',
    );

=cut

sub NewsList {
    my ( $Self, %Param ) = @_;

    my $Where = '';
    my @Bind;

    if ( $Param{Valid} ) {
        my $ValidID = $Self->{ValidObject}->ValidLookup( Valid => 'valid' );
        $Where = 'WHERE valid_id = ?';
        @Bind  = ( \$ValidID );
    }

    # sql
    return if !$Self->{DBObject}->Prepare(
        SQL  => "SELECT id, teaser FROM product_news $Where",
        Bind => \@Bind,
    );

    my %News;
    while ( my @Data = $Self->{DBObject}->FetchrowArray() ) {
        $News{ $Data[0] } = $Data[1];
    }

    return %News;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

=head1 VERSION

$Revision: 1.1.1.1 $ $Date: 2011/04/15 07:49:58 $

=cut
