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
    Kernel::System::Time
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
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $TimeObject   = $Kernel::OM->Get('Kernel::System::Time');

    my @Params = (qw(
        NewsID Headline Teaser Body ValidID UserID RedirectAction
        InvalidateYear InvalidateMonth InvalidateDay InvalidateHour
        InvalidateMinute InvalidateUsed
    ));
    my %GetParam;
    for (@Params) {
        $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
    }

    for my $ArrayParam (qw(Display) ) {
        $GetParam{$ArrayParam} = [ $ParamObject->GetArray( Param => $ArrayParam ) ];
    }

    # transform invalidate time, time stamp based on user time zone
    if (
        $GetParam{InvalidateUsed}
        && defined $GetParam{InvalidateYear}
        && defined $GetParam{InvalidateMonth}
        && defined $GetParam{InvalidateDay}
        && defined $GetParam{InvalidateHour}
        && defined $GetParam{InvalidateMinute}
        )
    {
        %GetParam = $LayoutObject->TransfromDateSelection(
            %GetParam,
            Prefix => 'Invalidate',
        );

        $GetParam{InvalidateEpoche} = $TimeObject->Date2SystemTime(
            Year   => $GetParam{InvalidateYear},
            Month  => $GetParam{InvalidateMonth},
            Day    => $GetParam{InvalidateDay},
            Hour   => $GetParam{InvalidateHour},
            Minute => $GetParam{InvalidateMinute},
            Second => 0,
        );
    }

    my $IsAdmin = $Self->_IsAdmin();
    if ( $Self->{Subaction} && $GetParam{NewsID} ) {
        my %News = $NewsObject->NewsGet( NewsID => $GetParam{NewsID} );
        if ( !( $IsAdmin || $News{CreateBy} == $Self->{UserID} ) ) {
            my $TranslatableMessage = $Self->{LayoutObject}->{LanguageObject}->Translate(
                "We are sorry, you do not have permissions to edit this news item."
            );
    
            return $Self->{LayoutObject}->NoPermission(
                Message    => $TranslatableMessage,
                WithHeader => 'yes',
            );
        }
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
        $Output .= $Self->_MaskNewsForm( IsAdmin => $IsAdmin );
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
    my $TimeObject   = $Kernel::OM->Get('Kernel::System::Time');

    if ( $Self->{Subaction} eq 'Edit' ) {
        my %News = $NewsObject->NewsGet( NewsID => $Param{NewsID} );
        $Param{$_} = $News{$_} for keys %News;

        $Param{Display} = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
            Data => $News{Displays} || '["Dashboard"]',
        );

        if ( $News{InvalidateEpoche} ) {
            $Param{InvalidateUsed} = 1;

            (undef, @Param{ qw/InvalidateMinute InvalidateHour InvalidateDay InvalidateMonth InvalidateYear/ } ) =
                $TimeObject->SystemTime2Date( SystemTime => $News{InvalidateEpoche} );
        }
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

    $Param{InvalidateDate} = $LayoutObject->BuildDateSelection(
        %Param,
        Prefix             => 'Invalidate',
        Format             => 'DateInputFormatLong',
        InvalidateUsed     => $Param{InvalidateUsed},
        InvalidateOptional => 1,
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

            if ( $Param{IsAdmin} || $Self->{UserID} == $News{CreateBy} ) {
                $LayoutObject->Block(
                    Name => 'EditDelete',
                    Data => \%News,
                );
            }
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

sub _IsAdmin {
    my ($Self) = @_;

    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $EditDelete    = $ConfigObject->Get('ProductNews::DashboardEditDelete') || 0;
    my $EditDeleteGrp = $ConfigObject->Get('ProductNews::DashboardEditDeleteGroup') || 'admin';
    my $IsAdmin       = 0;

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

    return $IsAdmin;
}

1;
