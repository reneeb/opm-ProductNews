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
    Kernel::System::ProductNews
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

    for my $NewsID ( sort keys %ProductNews ) {
        my %News = $PNObject->NewsGet(
            NewsID => $NewsID,
        );

        $LayoutObject->Block(
            Name => 'News',
            Data => \%News,
        );
    }

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'ProductNewsSnippet',
    );

    ${ $Param{Data} } =~ s{
        <div \s+ class="SidebarColumn"> \K
    }{
        $Snippet
    }xms;
}

1;
