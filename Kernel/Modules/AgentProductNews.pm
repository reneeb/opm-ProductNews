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

our @ObjectDependencies = qw(
    Kernel::System::ProductNews
    Kernel::System::HTMLUtils
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
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

    my @Params = (qw(NewsID ID Mode));

    my %GetParam;
    for my $ParamName (@Params) {
        $GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName ) || '';
    }

    my %News = $NewsObject->NewsGet( NewsID => $GetParam{ID} || $GetParam{NewsID});

    if ( !$ConfigObject->Get('ProductNews::UseRichText') ) {
        $News{Body} = $UtilsObject->ToHTML( String => $News{Body} );
    }

    my %Opts;
    my $NavigationBar = $LayoutObject->NavigationBar();
    if( $GetParam{Mode} eq 'ContentOnly') {
        $Opts{Type}    = 'Small';
        $NavigationBar = '';
       
        # for very short news, the dialog will show garbage, so
        # we have to extend the content...
        my $Whitespaces = 0; 
        while ( length $News{Body} < 420 ) {
            $News{Body} .= ' ';
            $Whitespaces++;
        }

        $News{Body} .= '&nbsp;' x $Whitespaces;
    }

    if ( $News{OpenNews} ) {
        $LayoutObject->Block(
            Name => 'OpenNews',
            Data => \%News,
        );
    }

    my $Content = $LayoutObject->Output(
        TemplateFile => 'AgentProductNews',
        Data         => \%News,
    );

    my $Output = $LayoutObject->Header( %Opts );
    $Output .= $NavigationBar;
    $Output .= $Content;
    $Output .= $LayoutObject->Footer( %Opts );
    return $Output;
}

1;
