# --
# Copyright (C) 2016 - 2019 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ProductNews;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::ProductNews
    Kernel::System::User
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

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    my $ProxyUser = $UserObject;

    if ( $Template =~ m{\A Customer}xms ) {
        $ProxyUser = $CustomerUserObject;
    }

    my $UserID      = $LayoutObject->{UserID};

    my %UserReadNews;

    if ( $UserID ) {
        my %Preferences = $ProxyUser->GetPreferences(
            UserID => $UserID,
        );

        %UserReadNews = map{
            $_ ? ($_ => 1) : ();
        } split /;/, join ';', $Preferences{ProductNewsRead} || '',  $Preferences{ProductNewsAutoOpenRead} || '';
    }

    my $NewsShown = 0;

    my $ShowTeaserWidget    = $ConfigObject->Get('ProductNews::ShowTeaserWidget') || 0;
    my $ShowCreatedByWidget = $ConfigObject->Get('ProductNews::ShowCreatedByWidget') || 0;
    my $WidgetHeader        = $ConfigObject->Get('ProductNews::WidgetHeader') || 'Product News';

    $LayoutObject->Block(
        Name => 'WidgetHeader',
        Data => {
            WidgetHeader => $WidgetHeader,
        },
    );

    NEWSID:
    for my $NewsID ( sort keys %ProductNews ) {

        next NEWSID if $UserReadNews{$NewsID};

        $NewsShown++;

        my %News = $PNObject->NewsGet(
            NewsID => $NewsID,
        );
      
        # for using without JS-Dialog
        if ( !$ConfigObject->Get('ProductNews::UseRichText') ) {
            $News{Body} = $LayoutObject->Ascii2Html(Text => $News{Body},HTMLResultMode  => 1,);
        }
        
        $LayoutObject->Block(
            Name => 'News',
            Data => \%News,
        );

        if ($Template =~ /Login/) {
            my %UserInformation = $UserObject->GetUserData(
                UserID => $News{CreateBy},
            );
            $LayoutObject->Block(
                Name => 'NewsContent',
                Data => {
                    %UserInformation,
                    %News,
                },
            );
        }

        if( $ShowTeaserWidget ) {
            $LayoutObject->Block(
                Name => 'Teaser',
                Data => {
                    %News,
                },
            );
        }

        if( $ShowCreatedByWidget ) {
            my %UserInformation = $UserObject->GetUserData(
                UserID => $News{CreateBy},
            );

            $LayoutObject->Block(
                Name => 'CreateByInformation',
                Data => {
                    %UserInformation,
                },
            );
        }
    }

    return 1 if !$NewsShown;

    if ( $Template eq 'CustomerLogin' || $Template eq 'Login' ) {
        my $ID = $Template eq 'Login' ? 'LoginBox' : 'SlideArea';

        my $Snippet = $LayoutObject->Output(
            TemplateFile => 'ProductNewsSnippetLogin',
        );
        ${ $Param{Data} } =~ s{ 
            <div \s+ id="$ID"> \K 
        }{ 
            $Snippet 
        }xms;

    }
    elsif ($Template =~ /^CustomerTicket/) {
        my $Snippet = $LayoutObject->Output(
            TemplateFile => 'ProductNewsSnippet',
        );

        my $CustomerLoginStyle = ' style="margin: 13px;" ';
        $Snippet =~ s{(<div \s+ class="WidgetSimple")(>)}{$1$CustomerLoginStyle$2}xism;
        $Snippet =~ s{<div \s+ class="WidgetAction \s+ Toggle">.*?</div>}{}xism;
        $Snippet =~ s{<span \s+ id="mark_as_read_.*?</span>}{}gxism;
        my $MatchString = '(<div.*?id="MainBox")';
        ${ $Param{Data} } =~ s{ $MatchString }{ $Snippet $1}xism;
    }
    else {
        my $Snippet = $LayoutObject->Output(
            TemplateFile => 'ProductNewsSnippet',
        );
        ${ $Param{Data} } =~ s{
            <div \s+ class="SidebarColumn"> \K
        }{
            $Snippet
        }xms;
    }

    my $ActionPrefix = $Template =~ m{\A Agent}xms ? 'Agent' : 'Customer';
    my $JSSnippet = qq~
        <script type="text/javascript">//<![CDATA[
            var ActionPrefix = '$ActionPrefix';
        //]]></script>
    ~;

    ${ $Param{Data} } =~ s{<div \s+ id="(?:ProductNewsX|ALLNEWS)" [^>]* > \K}{$JSSnippet}xism;

    return 1;
}

1;
