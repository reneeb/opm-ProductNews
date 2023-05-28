# --
# Copyright (C) 2011 - 2023 Perl-Services.de, https://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dashboard::ProductNews;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::ProductNews
    Kernel::System::Group
    Kernel::System::User
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

    return;
}

sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} },
    );
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $NewsObject   = $Kernel::OM->Get('Kernel::System::ProductNews');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Content;
    my $ContentFound  = 0;
    my $ShowTeaser    = $ConfigObject->Get('ProductNews::ShowTeaser') || 0;
    my $ShowCreatedBy = $ConfigObject->Get('ProductNews::ShowCreatedBy') || 0;
    my $EditDelete    = $ConfigObject->Get('ProductNews::DashboardEditDelete') || 0;
    my $EditDeleteGrp = $ConfigObject->Get('ProductNews::DashboardEditDeleteGroup') || 'admin';
    my $IsAdmin = 0;
    
    # check if user is in productnews admin group...
    my $EDGroupID = $GroupObject->GroupLookup( Group => $EditDeleteGrp, );
    my @GroupIDs  = $GroupObject->GroupMemberList(
        UserID => $Self->{UserID},
        Type   => 'rw',
        Result => 'ID',
    );

    for my $GroupID (@GroupIDs) {
        if ($GroupID eq $EDGroupID) {
            $IsAdmin = 1;
            last;
        };
    }

    # get news
    my @ProductNews = $NewsObject->NewsList(
        Valid   => 1,
        Display => 'Dashboard',
        Return  => 'Sorted',
    );

    my $OpenNewsID;

    my %UserPrefs = $UserObject->GetPreferences(
        UserID => $Self->{UserID},
    );

    my %UserReadNews = map{ $_ => 1 } split /;/, $UserPrefs{'ProductNewsAutoOpenRead'} || '';

    # show messages
    for my $NewsID ( @ProductNews ) {

        # get news data
        my %NewsInfo = $NewsObject->NewsGet(
            NewsID => $NewsID,
        );

        if ( $NewsInfo{OpenNews} && !$OpenNewsID && !$UserReadNews{$NewsID} ) {
            $OpenNewsID = $NewsID;
        }

        # get user information
        my %UserInformation = $UserObject->GetUserData(
            UserID => $NewsInfo{CreateBy},
        );

        # remember if content got shown
        $ContentFound = 1;
        
        $LayoutObject->Block(
            Name => 'News',
            Data => {
                %NewsInfo,
            },
        );

        if( $ShowTeaser ) {
            $LayoutObject->Block(
                Name => 'Teaser',
                Data => {
                    %NewsInfo,
                },
            );
        }

        if( $ShowCreatedBy ) {
            $LayoutObject->Block(
                Name => 'CreateByInformation',
                Data => {
                    %UserInformation,
                },
            );
        }

        if( $EditDelete && ($NewsInfo{CreateBy} eq $Self->{UserID} || $IsAdmin) ) {
            $LayoutObject->Block(
                Name => 'EditDelete',
                Data => {
                    %NewsInfo,
                },
            );
        }
    }

    # check if content got shown, if true, render block
    if ($ContentFound) {
        $Content = $LayoutObject->Output(
            TemplateFile => 'DashboardProductNews',
            Data         => {
                %{ $Self->{Config} },
                NewsIDToOpen => $OpenNewsID,
            },
        );
    }

    # return content
    return $Content;
}

1;
