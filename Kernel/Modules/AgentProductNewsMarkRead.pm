# --
# Copyright (C) 2015 - 2022 Perl-Services.de, https://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentProductNewsMarkRead;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::ProductNews
    Kernel::System::HTMLUtils
    Kernel::System::User
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::Config
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NewsObject   = $Kernel::OM->Get('Kernel::System::ProductNews');
    my $UtilsObject  = $Kernel::OM->Get('Kernel::System::HTMLUtils');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    my @Params = (qw(NewsID ID Mode));

    my %GetParam;
    for my $ParamName (@Params) {
        $GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName ) || '';
    }

    my $GlobalMarkRead = $ConfigObject->Get('ProductNews::GlobalMarkRead');
    my %News           = $NewsObject->NewsGet( NewsID => $GetParam{ID} || $GetParam{NewsID});
    my $PrefKey        = 'ProductNewsRead';

    if ( $GetParam{Mode} && $GetParam{Mode} eq 'ReadAutoOpen' ) {
        $PrefKey        = 'ProductNewsAutoOpenRead';
        $GlobalMarkRead = 0;
    }

    if ( $GlobalMarkRead ) {
        $NewsObject->NewsUpdate(
            %News,
            ValidID => 2,
            UserID  => $Self->{UserID},
        );
    }
    else {
        my %Preferences = $UserObject->GetPreferences(
            UserID => $Self->{UserID},
        );

        my %AllNews      = $NewsObject->NewsList( Valid => 0 );
        my %UserReadNews = map{ $_ => 1 } split /;/, $Preferences{$PrefKey} || '';

        my $NewsID = $GetParam{ID} || $GetParam{NewsID};
        $UserReadNews{$NewsID} = 1;

        for my $ID ( keys %UserReadNews ) {
            delete $UserReadNews{$ID} if !exists $AllNews{$ID};
        }

        $UserObject->SetPreferences(
            Key    => $PrefKey,
            Value  => join( ';', keys %UserReadNews ),
            UserID => $Self->{UserID},
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => '{"Success":1}',
        Type        => 'inline',
        NoCache     => 0,
    );
}

1;
