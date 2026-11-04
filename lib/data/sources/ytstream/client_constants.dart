/// Load-bearing constants for YouTube Innertube VISIONOS player client context.
///
/// Ported from desktop `electron/youtube.cjs`. These constants must stay current
/// to avoid `LOGIN_REQUIRED` playability statuses on licensed music.
const visionOsContext = <String, dynamic>{
  'clientName': 'VISIONOS',
  'clientVersion': '1.02',
  'hl': 'en',
  'gl': 'US',
  'deviceMake': 'Apple',
  'deviceModel': 'RealityDevice17,1',
  'osName': 'visionOS',
  'osVersion': '26.5.23O471',
};

/// Matching User-Agent for the VISIONOS client context.
const visionOsUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15';

/// Public Innertube API key used across mobile and web YouTube clients.
const innertubeKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';

/// Time-to-live for cached session credentials (STS and visitorData).
const ytSessionTtl = Duration(hours: 4);
