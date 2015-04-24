# --
# Kernel/Modules/AdminProductNews.pm - provides admin notification translations
# Copyright (C) 2011-2014 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminProductNews;

use strict;
use warnings;

our $VERSION = 0.03;

our @ObjectDependencies = qw(
    Kernel::System::ProductNews
    Kernel::System::HTMLUtils
    Kernel::System::Valid
    Kernel::System::JSON
    Kernel::System::Web::Request
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
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my @Params = (qw(NewsID Headline Teaser Body ValidID UserID RedirectAction));
    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
    }

    for my $ArrayParam (qw(Display) ) {
        $GetParam{$ArrayParam} = [ $ParamObject->GetArray( Param => $ArrayParam ) ];
    }

    # ------------------------------------------------------------ #
    # get data 2 form
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Edit' || $Self->{Subaction} eq 'Add' ) {
        my %Subaction = (
            Edit => 'Update',
            Add  => 'Save',
        );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_MaskNewsForm(
            %GetParam,
            %Param,
            Subaction => $Subaction{ $Self->{Subaction} },
        );
        $Output .= $LayoutObject->Footer();
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
            !$ValidObject->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Headline Teaser Body)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( ! @{ $GetParam{Display} } ) {
            $Errors{DisplayInvalid} = 'ServerError';
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Edit';

            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $Self->_MaskNewsForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Update',
            );
            $Output .= $LayoutObject->Footer();
            return $Output;
        }

        $GetParam{Displays} = $JSONObject->Encode(
            Data => $GetParam{Display},
        );

        my $Update = $NewsObject->NewsUpdate(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Update ) {
            return $LayoutObject->ErrorScreen();
        }

        return $LayoutObject->Redirect( OP => "Action=AdminProductNews" );
    }

    # ------------------------------------------------------------ #
    # insert invoice state
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # server side validation
        my %Errors;
        if (
            !$GetParam{ValidID} ||
            !$ValidObject->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Headline Teaser Body)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( ! @{ $GetParam{Display} } ) {
            $Errors{DisplayInvalid} = 'ServerError';
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Add';

            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $Self->_MaskNewsForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Save',
            );
            $Output .= $LayoutObject->Footer();
            return $Output;
        }

        $GetParam{Displays} = $JSONObject->Encode(
            Data => $GetParam{Display},
        );

        my $Success = $NewsObject->NewsAdd(
            %GetParam,
            UserID => $Self->{UserID},
        );

        if ( !$Success ) {
            return $LayoutObject->ErrorScreen();
        }

        return $LayoutObject->Redirect( OP => "Action=AdminProductNews" );
    }

    elsif ( $Self->{Subaction} eq 'Delete' ) {
        $NewsObject->NewsDelete( %GetParam );

        if( !$GetParam{RedirectAction} ) {
            return $LayoutObject->Redirect( OP => "Action=AdminProductNews" );
        }
        else {
            return $LayoutObject->Redirect( OP => "Action=".$GetParam{RedirectAction} );
        }
    }

    # ------------------------------------------------------------ #
    # else ! print form
    # ------------------------------------------------------------ #
    else {
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_MaskNewsForm();
        $Output .= $LayoutObject->Footer();
        return $Output;
    }
}

sub _MaskNewsForm {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $NewsObject   = $Kernel::OM->Get('Kernel::System::ProductNews');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    if ( $Self->{Subaction} eq 'Edit' ) {
        my %News = $NewsObject->NewsGet( NewsID => $Param{NewsID} );
        $Param{$_} = $News{$_} for keys %News;

        $Param{Display} = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
            Data => $News{Displays} || '["Dashboard"]',
        );
    }

    my $OutputFilter = $ConfigObject->{'Frontend::Output::FilterElementPre'} || {};
    my $PNFilter     = $OutputFilter->{OutputFilterProductNews} ||{};
    my @Templates    = keys %{ $PNFilter->{Templates} || {} };

    $Param{DisplaySelect} = $LayoutObject->BuildSelection(
        Data => {
            'Dashboard' => 'Dashboard',
            map{ $_ => $_ }@Templates,
        },
        Name       => 'Display',
        SelectedID => $Param{Display},
        Class      => 'ValidateRequired ' . ( $Param{DisplayInvalid} || '' ),
        Multiple   => 1,
        Size       => 5,
    );

    my $ValidID = $ValidObject->ValidLookup( Valid => 'valid' );

    $Param{ValidSelect} = $LayoutObject->BuildSelection(
        Data       => { $ValidObject->ValidList() },
        Name       => 'ValidID',
        Size       => 1,
        SelectedID => $Param{ValidID} || $ValidID,
        HTMLQuote  => 1,
    );

    if ( $Self->{Subaction} ne 'Edit' && $Self->{Subaction} ne 'Add' ) {

        my %NewsList = $NewsObject->NewsList();
  
        if ( !%NewsList ) {
            $LayoutObject->Block(
                Name => 'NoNewsFound',
            );
        }

        for my $NewsID ( sort keys %NewsList ) {
            my %News = $NewsObject->NewsGet(
                NewsID => $NewsID,
            );

            $LayoutObject->Block(
                Name => 'NewsRow',
                Data => \%News,
            );
        }
    }

    $Param{SubactionName} = 'Update';
    $Param{SubactionName} = 'Save' if $Self->{Subaction} && $Self->{Subaction} eq 'Add';

    my $TemplateFile = 'AdminProductNewsList';
    $TemplateFile = 'AdminProductNewsForm' if $Self->{Subaction};

    return $LayoutObject->Output(
        TemplateFile => $TemplateFile,
        Data         => \%Param
    );
}

1;
