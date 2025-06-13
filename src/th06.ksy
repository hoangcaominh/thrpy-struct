meta:
  id: th06
  file-extension: rpy
  endian: le
  bit-endian: le
seq:
  - id: header
    type: header
  - id: data
    type: data
    # TODO: This needs fixing at some point
    process: th06_data_processor(header.key)
    size-eos: true
types:
  header:
    seq:
      - id: magic
        contents: T6RP
        doc: File magic, always T6RP
      - id: version
        type: u2
        doc: Replay version, 0x0102 for 1.02h
      - id: shot
        type: u1
        doc: Shottype, 0 = ReimuA, 1 = ReimuB, 2 = MarisaA, 3 = MarisaB
      - id: difficulty
        type: u1
        doc: Difficulty, 0 = Easy, 3 = Lunatic, 4 = Extra
      - id: checksum
        type: u4
        doc: Replay data checksum
      - id: unknown_1
        size: 2
      - id: key
        type: u1
        doc: Key for decrypting the data section
  data:
    seq:
      - id: replay_header
        type: replay_header
      - id: stages
        type: stage_instance(_index)
        repeat: expr
        repeat-expr: 7
  replay_header:
    seq:
      - id: unknown_1
        size: 1
      - id: date
        type: str
        size: 9
        encoding: ASCII
        terminator: 0x0
        doc: Replay date
      - id: name
        type: str
        size: 9
        encoding: SJIS
        terminator: 0x0
        doc: Player name
      - id: unknown_2
        size: 2
      - id: score
        type: u4
        doc: Final score
      - id: unknown_3
        size: 4
      - id: slowdown
        type: f4
        doc: Slowdown rate
      - id: unknown_4
        size: 4
      - id: stage_offsets
        type: u4
        doc: Position to corresponding stage in the decrypted file
        repeat: expr
        repeat-expr: 7
  stage:
    seq:
      - id: score
        type: u4
        doc: Stage final score
      - id: seed
        type: u2
        doc: RNG seed
      - id: unknown_1
        size: 2
      - id: power
        type: u1
        doc: Power
      - id: lives
        type: s1
        doc: Lives
      - id: bombs
        type: s1
        doc: Bombs
      - id: rank
        type: u1
        doc: Internal rank
      - id: unknown_2
        size: 4
      - id: states
        type: state
        doc: Array of states
        # It seems like the state's time at the end of the stage is 0x0098967F?
        repeat: until
        repeat-until: _.time == 0x0098967F
  stage_instance:
    params:
      - id: i
        type: u4
    instances:
      body:
        if: _parent.replay_header.stage_offsets[i] > 0
        io: _parent._io
        # Calculate offset from the start of data section
        pos: _parent.replay_header.stage_offsets[i] - 15
        type: stage
  input:
    seq:
      - id: shoot
        type: b1
      - id: bomb
        type: b1
      - id: focus
        type: b1
      - id: unknown_1
        type: b1
      - id: up
        type: b1
      - id: down
        type: b1
      - id: left
        type: b1
      - id: right
        type: b1
      - id: skip
        type: b1
  state:
    seq:
      - id: time
        type: u4
        doc: Time the state was taken
      - id: input
        type: input
        doc: State input
        size: 2
      - id: unknown_1
        size: 2
