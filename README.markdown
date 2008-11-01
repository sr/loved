Loved
=====

Simple tag-based favorite manager for [MPD][].

It goes like this
-----------------

Assuming that the following aliases are defined:

    alias loved="ruby ~/code/loved/loved.rb"
    alias play="loved play"

You're listening to some kick-ass song:

    % mpc
    Big L - M.V.P.
    [playing] #32/76   0:16/3:39 (7%)
    volume:  0%   repeat: on    random: off

    % loved swearing "old school"
    => Loved Big L - M.V.P.
       tags: "swearing" "old school" "Big L" "1995" "Rap & Hip Hop"

Later, when you want to listen it:

    % play "old school"
    Added 1 songs to your play list. Enjoy!

That's it!

Note that:

* You can assign as many tags as needed
* `% play` loads all favorites
* Each tag has its playlist stored in `~/.favorites`

Requirements
------------

Ruby, rubygems, the librmpd gem, good music taste.

Ever heard of [TATFT][] ?!
-------------------------
Absolutely. Fork you! I mean, fork me!

Licence
-------

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                       Version 2, December 2004

    Copyright (C) 2008 Simon Rozet <simon@rozet.name>
    Everyone is permitted to copy and distribute verbatim or modified
    copies of this license document, and changing it is allowed as long
    as the name is changed.

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

     0. You just DO WHAT THE FUCK YOU WANT TO.

[MPD]: http://www.musicpd.org/
[TATFT]: http://rubyhoedown2008.confreaks.com/05-bryan-liles-lightning-talk-tatft-test-all-the-f-in-time.html
