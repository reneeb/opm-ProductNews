# --
# Kernel/Output/HTML/DashboardProductNews.pm
# Copyright (C) 2011-2014 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::DashboardProductNews;

use strict;
use warnings;

use Kernel::System::ProductNews;
use Kernel::System::Group;
use Kernel::System::User;

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(Config Name ConfigObject LogObject DBObject LayoutObject ParamObject CacheObject UserID)
        )
    {
        die "Got no $_!" if ( !$Self->{$_} );
    }

    $Self->{NewsObject} = Kernel::System::ProductNews->new(%Param);
    $Self->{UserObject} = $Self->{UserObject} || Kernel::System::User->new(%Param);
    $Self->{GroupObject} = $Self->{GroupObject} || Kernel::System::Group->new(%Param);

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

    my $Content;
    my $ContentFound  = 0;
    my $ShowTeaser    = $Self->{ConfigObject}->Get('ProductNews::ShowTeaser') || 0;
    my $ShowCreatedBy = $Self->{ConfigObject}->Get('ProductNews::ShowCreatedBy') || 0;
    my $EditDelete    = $Self->{ConfigObject}->Get('ProductNews::DashboardEditDelete') || 0;
    my $EditDeleteGrp = $Self->{ConfigObject}->Get('ProductNews::DashboardEditDeleteGroup') || 'admin';
    my $IsAdmin = 0;
    
    # check if user is in productnews admin group...
    my $EDGroupID = $Self->{GroupObject}->GroupLookup( Group => $EditDeleteGrp, );
    my @GroupIDs = $Self->{GroupObject}->GroupMemberList(
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
    my %ProductNews = $Self->{NewsObject}->NewsList(
        Valid => 1,
    );

    # show messages
    for my $NewsID ( keys %ProductNews ) {

        # get news data
        my %NewsInfo = $Self->{NewsObject}->NewsGet(
            NewsID => $NewsID,
        );

        # get user information
        my %UserInformation = $Self->{UserObject}->GetUserData(
            UserID => $NewsInfo{CreateBy},
        );

        # remember if content got shown
        $ContentFound = 1;
        
        $Self->{LayoutObject}->Block(
            Name => 'News',
            Data => {
                %NewsInfo,
            },
        );

        if( $ShowTeaser ) {
            $Self->{LayoutObject}->Block(
                Name => 'Teaser',
                Data => {
                    %NewsInfo,
                },
            );
        }

        if( $ShowCreatedBy ) {
            $Self->{LayoutObject}->Block(
                Name => 'CreateByInformation',
                Data => {
                    %UserInformation,
                },
            );
        }

        if( $EditDelete && ($NewsInfo{CreateBy} eq $Self->{UserID} || $IsAdmin) ) {
            $Self->{LayoutObject}->Block(
                Name => 'EditDelete',
                Data => {
                    %NewsInfo,
                },
            );
        }

    }


    # check if content got shown, if true, render block
    if ($ContentFound) {
        $Content = $Self->{LayoutObject}->Output(
            TemplateFile => 'DashboardProductNews',
            Data         => {
                %{ $Self->{Config} },
            },
        );
    }

    # return content
    return $Content;
}

1;
