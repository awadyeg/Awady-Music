class LegalDocuments {
  const LegalDocuments._();

  static const String disclaimer = '''

# Disclaimer

**TL;DR: Awady Music is a media player, not a music service.** It is a piece of software you run on your own device. It hosts nothing, stores nothing, uploads nothing, and sells nothing. Every byte of audio or metadata is fetched by *your* device, at *your* request, directly from third-party servers operated by their respective platforms, the same way a web browser does.

## What Awady Music is (and is not)

Awady Music is an open-source mobile application that provides a unified interface for playing audio that is already publicly accessible on the internet. Functionally it is comparable to a web browser or a media player such as VLC: it sends requests to publicly reachable endpoints and renders or plays back what those endpoints return.

Awady Music:
- **does not host** any audio, video, artwork, lyrics, or metadata
- **does not operate any servers** that store, cache, relay, or proxy copyrighted content: there is no Awady Music backend at all
- **does not redistribute** any media; streams travel directly between the third-party platform and the end user's device
- **does not contain** copyrighted material: the source code and binaries are a user interface and a networking client, nothing more
- **does not require an account**, collect personal data, or track usage
- **is not affiliated with, endorsed by, or sponsored by** Spotify, YouTube, YouTube Music, Google, Audius, or any label, artist, or rights holder. All trademarks belong to their respective owners.

## Where the content comes from

All catalog metadata and audio are requested client-side, in real time, from public sources:
- **YouTube / YouTube Music**, via the same public web API (Innertube) and publicly served media URLs that any browser uses when visiting music.youtube.com.
- **Audius**, via the official public Audius REST API (`https://api.audius.co`), which explicitly licenses its catalog for third-party apps under the Audius API terms.

Whether a given stream may be accessed in a given context is determined by the hosting platform, not by Awady Music. If a platform restricts or removes content, Awady Music simply cannot play it.

## Why this is legal territory for a tool, not a service

Software that is capable of accessing public streams is not itself an infringement of copyright. Courts have long recognized that technology with **substantial non-infringing uses**: playing openly licensed music (Audius), personal media, Creative-Commons works, or content the user has rights to, is lawful to develop and distribute, even if some users might misuse it. This is the same legal footing as web browsers, download managers, media players, and apps that embed video/audio playback.

Responsibility for complying with each platform's Terms of Service and with local copyright law rests with **the person operating the software**. By using Awady Music you are making direct requests to third-party services from your own device and IP address. You are the client, not Awady Music.

## No commercial interest

Awady Music is free, contains no advertising, has no paid tier, no donations baked into playback, and generates no revenue from streams. It is a non-commercial, educational open-source project maintained for personal use and mobile engineering research.

## Takedown / rights-holder contact

Because Awady Music hosts and distributes no content, there is nothing on our servers to remove: there are no such servers. If you are a rights holder and want content restricted, the effective channel is the platform that actually serves it:
- YouTube / YouTube Music: https://support.google.com/youtube/answer/2807622
- Audius: https://audius.co/legal/terms-of-use

If you believe the software itself infringes your rights, open an issue at https://github.com/awadyeg/Awady-Music/issues.

## Warranty and liability

Awady Music is provided **"as is"**, without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the authors or contributors be liable for any claim, damages, or other liability arising from, out of, or in connection with the software.
''';

  static const String terms = '''

# Terms of Use

*Last updated: November 2026*

These terms govern your use of the Awady Music mobile application ("the Software"). By downloading, installing, or using the Software you agree to them. If you do not agree, do not use it.

## 1. What the Software is

Awady Music is a free, open-source, non-commercial media player. It is a client-side tool: it makes network requests from your device to publicly accessible third-party services (including YouTube/YouTube Music and the Audius public API) and plays back what those services return. Awady Music does not host, store, proxy, redistribute, or sell access to any content, and it operates no content servers.

## 2. Your responsibilities

- You use the Software **at your own initiative and your own risk**.
- You are solely responsible for complying with the Terms of Service of every third-party service you access through the Software, and with all laws applicable in your jurisdiction (including copyright law).
- Any requests made through the Software originate from **your device and your IP address**. You are the client of those services; Awady Music's authors are not a party to that interaction.
- The Software is intended for **personal, non-commercial use**: playing media you are lawfully entitled to access. Do not use it to infringe copyright, to redistribute content, or in any commercial setting.

## 3. No warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. The authors do not warrant that the Software will be uninterrupted, error-free, or that any third-party content will remain available; availability is controlled by the platforms that serve it, which may change their APIs, terms, or catalog at any time without notice.

## 4. Limitation of liability

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS OF AWADY MUSIC BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF DATA, REVENUE, OR PROFITS, ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF (OR INABILITY TO USE) THE SOFTWARE, INCLUDING ANY CLAIM BY A THIRD PARTY RELATING TO YOUR USE OF IT.

## 5. Indemnification

You agree to indemnify and hold harmless the authors and contributors of Awady Music from any claim, demand, liability, or expense (including reasonable legal fees) arising from your use of the Software, your violation of these terms, or your violation of any third party's rights or terms of service.

## 6. Third-party services and trademarks

- "Spotify" is a registered trademark of Spotify AB.
- "YouTube" and "YouTube Music" are registered trademarks of Google LLC.
- "Audius" is a trademark of Audius, Inc.

Awady Music is an independent project and is not affiliated with, endorsed by, or sponsored by any of these entities. Reference to them is made purely for identification and compatibility.
''';

  static const String privacy = '''

# Privacy Policy

*Last updated: November 2026*

**Awady Music collects nothing.** There is no account system, no analytics, no telemetry, no crash reporting, no advertising, and no Awady Music server that could receive your data even if it wanted to.

## What stays on your device

Everything the app remembers is stored locally on your device in local database and preferences:
- Liked tracks, followed artists, user playlists, play history and queue: local SQLite database on your device
- Playback preferences (volume, shuffle, repeat, autoplay, equalizer)
- Appearance preferences (theme, language, reduced transparency)
- Temporary caches of artwork, lyrics and resolved stream URLs
- Diagnostic logs written to a private local app folder

You can wipe the caches at any time from Settings → "Clear artwork & lyrics cache", or export your library and data.

## What third parties see

When you use Awady Music, **your device makes direct requests** to the third-party services that actually provide the catalog and audio. The same way visiting their websites in a browser would:
- **YouTube / YouTube Music** (Google) receives the search/browse/stream requests needed to play music, from your IP address.
- **Audius** receives API and stream requests, from your IP address.
- **GitHub** receives a release-info request when the app checks for updates or you open the repository link.

Those requests are governed by each service's own privacy policy. Awady Music's authors never see any of this traffic.

## Playlist imports

Spotify playlist import never asks you to log in. Awady Music reads the public playlist page Spotify serves any anonymous visitor, and that page carries a short-lived token Spotify's own web player uses. That token is used to read the track list and is then dropped: it never reaches any remote server, never touches disk, and never outlives the import. No Spotify account, password or stored session is involved.
''';

  static const String licenses = '''

# Licenses & Notices

Awady Music is open source software.

## Open Source Attribution

Based on the open-source Freebify design and concept.
Original concept and design: Freebify (govu)
Awady Music Flutter Implementation: Awady Music Team (https://github.com/awadyeg/Awady-Music)

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## Third-Party Libraries

Awady Music utilizes several open source packages:
- Flutter SDK (BSD-3-Clause)
- flutter_riverpod (MIT)
- drift & sqlite3 (MIT / Apache-2.0)
- just_audio & audio_service (MIT)
- dio (MIT)
- lucide_icons_flutter (ISC)
- google_fonts (Apache-2.0)
- path_provider (BSD-3-Clause)
- shared_preferences (BSD-3-Clause)
- share_plus (BSD-3-Clause)
''';
}
