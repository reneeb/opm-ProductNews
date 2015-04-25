# --
# Kernel/Output/HTML/OutputFilterProductNews.pm
# Copyright (C) 2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterProductNews;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::ProductNews
    Kernel::System::User
    Kernel::Output::HTML::Layout
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Template = $Param{TemplateFile} || '';

    return 1 if !$Template;
    return 1 if !$Param{Templates}->{$Template};

    my $PNObject    = $Kernel::OM->Get('Kernel::System::ProductNews');
    my %ProductNews = $PNObject->NewsList(
        Valid   => 1,
        Display => $Template,
    );

    return 1 if !%ProductNews;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $UserID      = $LayoutObject->{UserID};
    my %Preferences = $UserObject->GetPreferences(
        UserID => $UserID,
    );

    my %UserReadNews = map{ $_ => 1 } split /;/, $Preferences{ProductNewsRead} || '';

    my $NewsShown = 0;

    my $ShowTeaserWidget    = $ConfigObject->Get('ProductNews::ShowTeaserWidget') || 0;
    my $ShowCreatedByWidget = $ConfigObject->Get('ProductNews::ShowCreatedByWidget') || 0;

    NEWSID:
    for my $NewsID ( sort keys %ProductNews ) {

        next NEWSID if $UserReadNews{$NewsID};

        $NewsShown++;

        my %News = $PNObject->NewsGet(
            NewsID => $NewsID,
        );

        $LayoutObject->Block(
            Name => 'News',
            Data => \%News,
        );

        if( $ShowTeaserWidget ) {
            $LayoutObject->Block(
                Name => 'Teaser',
                Data => {
                    %News,
                },
            );
        }

        if( $ShowCreatedByWidget ) {
            my %UserInformation = $UserObject->GetUserData(
                UserID => $News{CreateBy},
            );

            $LayoutObject->Block(
                Name => 'CreateByInformation',
                Data => {
                    %UserInformation,
                },
            );
        }
    }

    return 1 if !$NewsShown;

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'ProductNewsSnippet',
    );

    ${ $Param{Data} } =~ s{
        <div \s+ class="SidebarColumn"> \K
    }{
        $Snippet
    }xms;

    my $JS = sprintf q~
        $('span[id^="mark_as_read_"]').bind( 'click', function() {
            var link    = $(this);
            var news_id = link.attr('id').replace('mark_as_read_', '');

            $.ajax({
                type: "POST",
                url:  '%s',
                data : {
                    Action: 'AgentProductNewsMarkRead',
                    NewsID: news_id
                },
                success : function() {
                    link.closest('tr').remove();
                }
            });
        });
    ~, $LayoutObject->{EnvRef}->{Baselink};

    ${ $Param{Data} } =~ s{\z}{[% WRAPPER JSOnDocumentComplete %]\n$JS\n[% END %]}
}

1;
