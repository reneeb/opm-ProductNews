# --
# Copyright (C) 2011 - 2023 Perl-Services.de, https://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminProductNewsSorting;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::ProductNews
    Kernel::System::Time
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::Language
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

    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NewsObject     = $Kernel::OM->Get('Kernel::System::ProductNews');
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

    my @Params = $ParamObject->GetParamNames();

    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
    }

    # ------------------------------------------------------------ #
    # get data 2 form
    # ------------------------------------------------------------ #
    if ( !$Self->{Subaction} ) {
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_MaskNewsSorting();
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # insert news item
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        KEY:
        for my $Key ( keys %GetParam ) {
            next KEY if $Key !~ m{\APosition-}xms;

            my ($ID) = $Key =~ m{\APosition-(\d+)}xms;
            my $Success = $NewsObject->NewsPositionSet(
                NewsID   => $ID,
                Position => $GetParam{$Key},
                UserID   => $Self->{UserID},
            );
        }

        return $LayoutObject->Redirect( OP => "Action=AdminProductNewsSorting" );
    }
}

sub _MaskNewsSorting {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NewsObject   = $Kernel::OM->Get('Kernel::System::ProductNews');

    my @NewsIDsList = $NewsObject->NewsList(
        Return => 'Sorted',
    );
  
    if ( !@NewsIDsList ) {
        $LayoutObject->Block(
            Name => 'NoNewsFound',
        );
    }

    for my $NewsID ( @NewsIDsList ) {
        my %News = $NewsObject->NewsGet(
            NewsID => $NewsID,
        );

        $LayoutObject->Block(
            Name => 'NewsRow',
            Data => \%News,
        );
    }

    return $LayoutObject->Output(
        TemplateFile => 'AdminProductNewsSorting',
        Data         => \%Param
    );
}

1;
