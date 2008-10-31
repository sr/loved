Loved
=====

Simple favorite manager for [MPD][].

It goes like this:
------------------

Assuming that the fellowing aliases are defined

    alias l="ruby ~/code/loved/loved.rb"
    alias p="l play"

You're listening to some kick-ass song.

    % mpc
    Big L - M.V.P.
    [playing] #32/76   0:16/3:39 (7%)
    volume:  0%   repeat: on    random: off

    % l "old school"
    => Loved Big L - M.V.P.
       tags: "old school" "Big L" "1995" "Rap & Hip Hop"

Later, you want to listen it

    % p "old school"
    Added 1 songs to your play list. Enjoy!

That's it!

Note that :

* You can assign as many tags as needed
* `p` loads all favorites
* Each tag has its playlist stored in `~/.favorites`

Ever heard of [TATFT][] ?!
-------------------------
Absolutely. Fork you! I mean, fork me!

Licence
-------

    (The MIT License)

    Copyright (c) 2008 Simon Rozet <simon@rozet.name>

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    'Software'), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[MPD]: http://www.musicpd.org/
[TATFT]: http://rubyhoedown2008.confreaks.com/05-bryan-liles-lightning-talk-tatft-test-all-the-f-in-time.html
