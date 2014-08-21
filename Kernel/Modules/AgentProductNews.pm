# --
# Kernel/Modules/AgentProductNews.pm - provides admin notification translations
# Copyright (C) 2011-2014 Perl-Services.de, http://perl-services.de/
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

our $VERSION = 0.01;

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
    my @Params = (qw(NewsID ID Mode));

    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $Self->{ParamObject}->GetParam( Param => $_ ) || '';
    }

    my %News = $Self->{NewsObject}->NewsGet( NewsID => $GetParam{ID} || $GetParam{NewsID});

    $News{Body} = $Self->{UtilsObject}->ToHTML( String => $News{Body} );

    my %Opts;
    my $NavigationBar = $Self->{LayoutObject}->NavigationBar();
    if( $GetParam{Mode} eq 'ContentOnly') {
        $Opts{Type}    = 'Small';
        $NavigationBar = '';
       
        # for very short news, the dialog will show garbage, so
        # we have to extend the content...
        my $Whitespaces = 0; 
        while ( length $News{Body} < 120 ) {
            $News{Body} .= ' ';
            $Whitespaces++;
        }

        $News{Body} .= '&nbsp;' x $Whitespaces;
    }

    my $Content = $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentProductNews',
        Data         => \%News,
    );

    my $Output = $Self->{LayoutObject}->Header( %Opts );
    $Output .= $NavigationBar;
    $Output .= $Content;
    $Output .= $Self->{LayoutObject}->Footer( %Opts );
    return $Output;
}

1;
