/* 
  Commands used in hyperdeck - all models
  The hyperdeck follows TelNet protocol, thus commands were passed as string.
  It is important to note that every command must terminate by '\n'.
  Without '\n' the commands won't work.
  Since hyperdeck understands '\n' as the command terminator and
  uses multiline String commands.
*/

// return this help
String cHDHelp = 'help\n';

// return commands in XML format
String cHDCommands = 'commands\n';

// return device information
String cHDDeviceInfo = 'device info\n';

// query clip list on active disk
String cHDDiskList = 'disk list\n';

// query clip list on disk in slot {n}
// param: {n}
String cHDClipFromDisk = 'disk list: slot id: {n}\n';

// disconnect ethernet control
String cHDQuit = 'quit\n';

// check device is responding
String cHDPing = 'ping\n';

// switch to preview or output
// param: {true/false}
String cHDSwitchPreview = 'preview: enable: {true/false}\n';

// play from current timecode
String cHDPlay = 'play\n';

// play at specific speed
// param: {-1600 to 1600}
String cHDPlaySpeed = 'play: speed: {-1600 to 1600}\n';

// play in loops or stop-at-end
// param: {true/false}
String cHDPlayLoop = 'play: loop: {true/false}\n';

// play current clip or all clips
// param: {true/false}
String cHDTogglePlaySingleOrAll = 'play: single clip: {true/false}\n';

// set play range to play clip {n} only
// param: {n}
String cHDSetPlayRangeToPlayClip = 'playrange set: clip id: {n}\n';

// set play range to play between - timecode {inT} and timecode {outT}
// param: {inT}, {outT}
String cHDSetPlayRange = 'playrange set: in: {inT} out: {outT}\n';

// clear/reset play range setting
String cHDClearPlayRange = 'playrange clear\n';

// record from current input
String cHDRecord = 'record\n';

// record named clip
// param: {name}
String cHDRecordNamedClip = 'record: name: {name}\n';

// stop playback or recording
String cHDStop = 'stop\n';

// query number of clips on timeline
String cHDClipsCount = 'clips count\n';

// query all timeline clips
String cHDClipsGet = 'clips get\n';

// query a timeline clip info
// param: {n}
String cHDClipInfo = 'clips get: clip id: {n}\n';

// append a clip to timeline
// param: {name}
String cHDAppendClip = 'clips add: name: {name}\n';

// empty timeline clip list
String cHDClipsClear = 'clips clear\n';

// query current activity
String cHDUpdateInfo = 'transport info\n';

// query active slot
String cHDActiveSlotInfo = 'slot info\n';

// query slot {n}
// param: {n}
String cHDSlotInfo = 'slot info: slot id: {n}\n';

// switch to specified slot
// param: {1/2}
String cHDSwitchSlot = 'slot select: slot id: {1/2}\n';

// load clips of specified format
// param: {format}
String cHDLoadClipWithFormat = 'slot select: video format: {format}\n';

// query notification status
String cHDNotify = 'notify\n';

// set remote notifications
// param: {true/false}
String cHDSetRemoteNotify = 'notify: remote: {true/false}\n';

// set transport notifications
// param: {true/false}
String cHDSetTransNotify = 'notify: transport: {true/false}\n';

// set slot notifications
// param: {true/false}
String cHDSetSlotNotify = 'notify: slot: {true/false}\n';

// set configuration notifications
// param: {true/false}
String cHDSetNotifyConfig = 'notify: configuration: {true/false}\n';

// goto clip id {n}
// param: {n}
String cHDGotoClip = 'goto: clip id: {n}\n';

// go forward {n} clips
// param: {n}
String cHDGoForward = 'goto: clip id: +{n}\n';

// go backward {n} clips
// param: {n}
String cHDGoBackward = 'goto: clip id: -{n}\n';

// goto start or end of clip
// param: {start/end}
String cHDGotoStartOrEndOfClip = 'goto: clip: {start/end}\n';

// goto start or end of timeline
// param: {start/end}
String cHDGotoStartOrEndOfTimeline = 'goto: timeline: {start/end}\n';

// goto specified timecode
// param: {timecode}
String cHDGotoTimecode = 'goto: timecode: {timecode}\n';

// go forward {timecode} duration
// param: {timecode}
String cHDGoForwardTimecode = 'goto: timecode: +{timecode}\n';

// go backward {timecode} duration
// param: {timecode}
String cHDGoBackwardTimecode = 'goto: timecode: -{timecode}\n';

// query unit remote control state
String cHDRemote = 'remote\n';

// enable or disable remote control
// param: {true/false}
String cHDToggleRemoteControl = 'remote: enable: {true/false}\n';

// session override remote control
// param: {true/false}
String cHDToggleRemoteControlOverride = 'remote: override: {true/false}\n';

// query configuration settings
String cHDConfig = 'configuration\n';

// switch to SDI input
String cHDSwitchToSDI = 'configuration: video input: SDI\n';

// switch to HDMI input
String cHDSwitchToHDMI = 'configuration: video input: HDMI\n';

// capture embedded audio
String cHDCaptureEmbeddedAudio = 'configuration: audio input: embedded\n';

// switch to specific file format
// param: {format}
String cHDSwitchToFileFormat = 'configuration: file format: {format}\n';

// client connection timeout
// param: {period in seconds}
String cHDClientConnectionTimeout = 'watchdog: period: {period in seconds}\n';
