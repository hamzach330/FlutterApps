32K fixed file size
header and index are top down
table is bottom up with 128B block size
ids are unique per type

SOF ↑ [HEAD SIZE=36]
    |   int(16) uuid
    |   bool(1) lock
    |   int(8) lastUpdate -> optimization: 32B unix time seconds
    |   int32(4) lengthOfIndex -> optimization: entry count as uint8_t
    |   int32(4) lengthOfTable -> optimization: entry count as uint8_t
    |   int(1) versionMajor
    |   int(1) versionMinor
    |   int(1) versionPatch
    | [/HEAD]
    | [TABLE INDEX]
    |   [ENTRY SIZE=21]
    |     enum(1) type -> 0x00 = unused
    |     int(8) id -> optimizaion: 32b
    |     int(4) offset -> optimization: block number as uint8_t
    |     int(8) lastUpdate
    |   [/ENTRY]
    |   [ENTRY]...[/ENTRY]
    |   [ENTRY]...[/ENTRY]
    |   [ENTRY]...[/ENTRY]
    |   [ENTRY]...[/ENTRY]
    | [/TABLE INDEX]
    | 
    | [FREE_SPACE]32k minus size of head, index and data[/FREE_SPACE]
    | 
    | [TABLE DATA]
    |   [ENTRY TYPE=1 SIZE=99]
    |     enum(1) type (cpNode)
    |     int(8) id
    |     int(4) panId -> unnecessary? we store only our own pan
    |     enum(1) initiator
    |     int(8) cpGroup -> fix size 4
    |     int(8) cGroup -> fix size 4
    |     bool(1) coupled -> unnecessary? we store only coupled devices anyways
    |     char(32) name
    |     char(5) serial
    |     int(3) majorMinorPatch
    |     int(1) buildNo
    |     int(1) manufacturer -> fix: not needed there's only 1
    |     char(12) artId -> fix: convert to bin, halfes required space
    |     char(8) parentMac
    |     int(2) statusFlags
    |     bool(1) batteryPowered -> hm?
    |     bool(1) visible
    |     ...pad 128
    |   [/ENTRY]
    |   [ENTRY TYPE=2]
    |     Reserved for type cNode
    |     ...pad 128
    |   [/ENTRY]
    |   [ENTRY TYPE=3 SIZE=73]
    |     enum(1) type (group)
    |     int(1) id
    |     char(32) name
    |     int(8) cpGroup (4 pages of 3 bytes - 96 receivers)
    |     int(8) cGroup (4 pages of 3 bytes - 96 receivers)
    |     ...pad 128
    |   [/ENTRY]
    |   [ENTRY TYPE=4 SIZE=10+len]
    |       enum(1) type (string)
    |       int(8) id
    |       int(1) len
    |       char(118) value
    |   [/ENTRY]
EOF ↓ [/TABLE DATA]
