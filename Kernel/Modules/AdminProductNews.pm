# --
# Kernel/Modules/AdminProductNews.pm - provides admin notification translations
# Copyright (C) 2011 Perl-Services.de, http://perl-services.de/
# --
# $Id: AdminProductNews.pm,v 1.1.1.1 2011/04/15 07:49:58 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminProductNews;

use strict;
use warnings;

use Kernel::System::ProductNews;
use Kernel::System::HTMLUtils;
use Kernel::System::Valid;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1.1.1 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed (qw(ParamObject DBObject LayoutObject ConfigObject LogObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    # create needed objects
    $Self->{NewsObject}      = Kernel::System::ProductNews->new(%Param);
    $Self->{ValidObject}     = Kernel::System::Valid->new(%Param);
    $Self->{HTMLUtilsObject} = Kernel::System::HTMLUtils->new(%Param);

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my @Params = (qw(NewsID Headline Teaser Body ValidID UserID));
    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $Self->{ParamObject}->GetParam( Param => $_ ) || '';
    }

    # ------------------------------------------------------------ #
    # get data 2 form
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Edit' || $Self->{Subaction} eq 'Add' ) {
        my %Subaction = (
            Edit => 'Update',
            Add  => 'Save',
        );

        my $Output       = $Self->{LayoutObject}->Header();
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->_MaskNewsForm(
            %GetParam,
            %Param,
            Subaction => $Subaction{ $Self->{Subaction} },
        );
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # update action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Update' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();
 
        # server side validation
        my %Errors;
        if (
            !$GetParam{ValidID} ||
            !$Self->{ValidObject}->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Headline Teaser Body)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Edit';

            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->_MaskNewsForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Update',
            );
            $Output .= $Self->{LayoutObject}->Footer();
            return $Output;
        }

        my $Update = $Self->{NewsObject}->NewsUpdate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Update ) {
            return $Self->{LayoutObject}->ErrorScreen();
        }
        return $Self->{LayoutObject}->Redirect( OP => "Action=AdminProductNews" );
    }

    # ------------------------------------------------------------ #
    # insert invoice state
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        # server side validation
        my %Errors;
        if (
            !$GetParam{ValidID} ||
            !$Self->{ValidObject}->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Headline Teaser Body)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Add';

            my $Output = $Self->{LayoutObject}->Header();
            $Output .= $Self->{LayoutObject}->NavigationBar();
            $Output .= $Self->_MaskNewsForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Save',
            );
            $Output .= $Self->{LayoutObject}->Footer();
            return $Output;
        }

        my $Success = $Self->{NewsObject}->NewsAdd(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Success ) {
            return $Self->{LayoutObject}->ErrorScreen();
        }
        return $Self->{LayoutObject}->Redirect( OP => "Action=AdminProductNews" );
    }

    elsif ( $Self->{Subaction} eq 'Delete' ) {
        $Self->{NewsObject}->NewsDelete( %GetParam );
        return $Self->{LayoutObject}->Redirect( OP => "Action=AdminProductNews" );
    }

    # ------------------------------------------------------------ #
    # else ! print form
    # ------------------------------------------------------------ #
    else {
        my $Output = $Self->{LayoutObject}->Header();
        $Output .= $Self->{LayoutObject}->NavigationBar();
        $Output .= $Self->_MaskNewsForm();
        $Output .= $Self->{LayoutObject}->Footer();
        return $Output;
    }
}

sub _MaskNewsForm {
    my ( $Self, %Param ) = @_;

    if ( $Self->{Subaction} eq 'Edit' ) {
        my %News = $Self->{NewsObject}->NewsGet( NewsID => $Param{NewsID} );
        $Param{$_} = $News{$_} for keys %News;
    }

    my $ValidID = $Self->{ValidObject}->ValidLookup( Valid => 'valid' );

    $Param{ValidSelect} = $Self->{LayoutObject}->BuildSelection(
        Data       => { $Self->{ValidObject}->ValidList() },
        Name       => 'ValidID',
        Size       => 1,
        SelectedID => $Param{ValidID} || $ValidID,
        HTMLQuote  => 1,
    );

    if ( $Self->{Subaction} ne 'Edit' && $Self->{Subaction} ne 'Add' ) {

        my %NewsList = $Self->{NewsObject}->NewsList();
  
        if ( !%NewsList ) {
            $Self->{LayoutObject}->Block(
                Name => 'NoNewsFound',
            );
        }

        for my $NewsID ( sort keys %NewsList ) {
            my %News = $Self->{NewsObject}->NewsGet(
                NewsID => $NewsID,
            );

            $Self->{LayoutObject}->Block(
                Name => 'NewsRow',
                Data => \%News,
            );
        }
    }

    $Param{SubactionName} = 'Update';
    $Param{SubactionName} = 'Save' if $Self->{Subaction} && $Self->{Subaction} eq 'Add';

    my $TemplateFile = 'AdminProductNewsList';
    $TemplateFile = 'AdminProductNewsForm' if $Self->{Subaction};

    return $Self->{LayoutObject}->Output(
        TemplateFile => $TemplateFile,
        Data         => \%Param
    );
}

1;
