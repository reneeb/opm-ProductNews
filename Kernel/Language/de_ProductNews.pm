# --
# Kernel/Language/de_ProductNews.pm - the german translation of ProductNews
# Copyright (C) 2011 Perl-Services.de, http://perl-services.de/
# --
# $Id: de_ProductNews.pm,v 1.1.1.1 2011/04/15 07:49:58 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ProductNews;

use strict;
use warnings;
use utf8;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1.1.1 $) [1];

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'Add news'}        = 'Neue Nachricht';
    $Lang->{'News ID'}         = 'Nachricht';
    $Lang->{'Headline'}        = 'Überschrift';
    $Lang->{'Teaser'}          = 'Kurztext';
    $Lang->{'Author'}          = 'Autor';
    $Lang->{'Add/Change News'} = 'Nachricht hinzufügen/ändern';
    $Lang->{'News Management'} = 'Nachrichten verwalten';
    $Lang->{'edit'}            = 'bearbeiten';

    $Lang->{'Create and manage news.'} = 'Nachrichten erstellen und verwalten.';

    return 1;
}

1;
