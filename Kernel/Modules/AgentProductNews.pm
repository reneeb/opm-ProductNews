# --
# Kernel/Modules/AgentProductNews.pm - provides admin notification translations
# Copyright (C) 2011 Perl-Services.de, http://perl-services.de/
# --
# $Id: AgentProductNews.pm,v 1.1.1.1 2011/04/15 07:49:58 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentProductNews;

use strict;
use warnings;

use Kernel::System::ProductNews;
use Kernel::System::HTMLUtils;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1.1.1 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed (qw(ParamObject DBObject LayoutObject ConfigObject LogObject TimeObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    # create needed objects
    $Self->{NewsObject}  = Kernel::System::ProductNews->new(%Param);
    $Self->{UtilsObject} = Kernel::System::HTMLUtils->new( %Param );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my @Params = (qw(NewsID));

    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $Self->{ParamObject}->GetParam( Param => $_ ) || '';
    }

    my %News = $Self->{NewsObject}->NewsGet( NewsID => $GetParam{NewsID} );

    $News{Body} = $Self->{UtilsObject}->ToHTML( String => $News{Body} );

    my $Content = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentProductNews',
        Data         => \%News,
    );

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();
    $Output .= $Content;
    $Output .= $Self->{LayoutObject}->Footer();
    return $Output;
}

1;
