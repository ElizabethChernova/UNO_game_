% -*- mode: Prolog; coding:utf-8 -*-

/* Tests of reading protobufs in wireformat generated by Python/C++ programs,
   e.g., test_write.py -- the values in the tests were taken from the Python source.
   There are also round-trip tests of generating wire format.

   TODO: add tests for repeated fields being set to [].
   TODO: add tests for default values (proto2, proto3).
*/

:- module(test_read, [test_read_main/0]).

:- encoding(utf8).

:- if(true). % TODO: Remove (these directives are only for debugging).
:- set_prolog_flag(backtrace_goal_depth,100).
:- set_prolog_flag(backtrace_depth,100).
:- endif.

:- initialization(test_read_main, main).

:- use_module(library(plunit)).
:- use_module(library(debug), [assertion/1]).
:- use_module(library(protobufs)).
:- use_module(test_templates).
:- use_module(test_pb).
:- use_module(test2_pb).
:- use_module(google/protobuf/unittest_pb).
:- use_module(google/protobuf/unittest_import_pb).
:- use_module(google/protobuf/unittest_import_public_pb).

% Not needed because we're using plunit:
% :- set_prolog_flag(optimise_debug, false). % ensure assertion/1 is executed

test_read_main :-
    run_tests. % ([ scalar,
               %    repeated,
               %    golden,
               %    oneof,
               %    map
               %  ]).

round_trip_serialize_parse(Term, MsgType, OutputPath) :-
    protobuf_serialize_to_codes(Term, MsgType, WireCodes),
    !,
    write_message_codes(OutputPath, WireCodes),
    protobuf_parse_from_codes(WireCodes, MsgType, Term2),
    % There shouldn't be any variables in the Term (or WireCodes), unlike
    % protobuf_message/2, which can have variables from repeated_embedeed.
    % So, no need to use term_attvars/2 or call_residue_vars/2
    assertion(Term == Term2),
    assertion(ground(Term)),
    assertion(ground(Term2)),
    assertion(ground(WireCodes)).

:- begin_tests(scalar).

test(scalars1a_template) :-
    [In, Out] = ['scalars1a_from_python.wire', 'scalars1a_from_prolog_template.wire'],
    read_message_codes(In, WireCodes),
    scalars1_template(Template, Vars),
    Vars = [V_double,
            V_float,
            V_int32,
            V_int64,
            V_uint32,
            V_uint64,
            V_sint32,
            V_sint64,
            V_fixed32,
            V_fixed64,
            V_sfixed32,
            V_sfixed64,
            V_bool,
            V_string,
            V_bytes,
            V_enum,
            V_utf8_codes,
            V_key,
            V_value],
    protobuf_message(Template, WireCodes),
    protobuf_message(Template, WireCodes2),
    assertion(WireCodes == WireCodes2),
    protobuf_message(Template, WireCodes2), % once more, with both Template and WireCodes2 fully instantiated
    string_values(S1, S2, _S3, _S4, C1, _C2, _C3, _C4),
    assertion(V_double     == 1.5),
    assertion(V_float      == 2.5),
    assertion(V_int32      == 3),
    assertion(V_int64      == 4),
    assertion(V_uint32     == 5),
    assertion(V_uint64     == 6),
    assertion(V_sint32     == 7),
    assertion(V_sint64     == 8),
    assertion(V_fixed32    == 9),
    assertion(V_fixed64    == 10),
    assertion(V_sfixed32   == 11),
    assertion(V_sfixed64   == 12),
    assertion(V_bool       == false),
    assertion(V_string     == S1),
    assertion(V_bytes      == [0xc3, 0x28]),
    assertion(V_enum       ==  'E1'),
    assertion(V_utf8_codes == C1),
    assertion(V_key        == "reticulated python"),
    assertion(V_value      == S2),
    test_write_template(Out, Template).

test(scalars1b_template) :-
    [In, Out] = ['scalars1b_from_python.wire', 'scalars1b_from_prolog_template.wire'],
    read_message_codes(In, WireCodes),
    scalars1_template(Template, Vars),
    Vars = [V_double,
            V_float,
            V_int32,
            V_int64,
            V_uint32,
            V_uint64,
            V_sint32,
            V_sint64,
            V_fixed32,
            V_fixed64,
            V_sfixed32,
            V_sfixed64,
            V_bool,
            V_string,
            V_bytes,
            V_enum,
            V_utf8_codes,
            V_key,
            V_value],
    protobuf_message(Template, WireCodes),
    protobuf_message(Template, WireCodes2),
    % TODO: Consider using call_residue_vars/2 on the calls to
    %       protobuf_message/2 to provide extra assurance that none of
    %       the when/2 calls leave a residual.
    assertion(term_attvars(Template, [])),  % Can have vars from repeated_embedded
    assertion(ground(Template)),            % ... but there's no repeated_embededed in this test
    assertion(ground(WireCodes)),
    assertion(ground(WireCodes2)),
    assertion(WireCodes == WireCodes2),
    protobuf_message(Template, WireCodes), % once more, with both Template and WireCodes2 fully instantiated
    string_values(_S1, _S2, S3, _S4, _C1, _C2, C3, _C4),
    assertion(V_double     ==  -1.5),
    assertion(V_float      ==  -2.5),
    assertion(V_int32      ==  -3),
    assertion(V_int64      ==  -4),
    assertion(V_uint32     =:=  5+10000000),
    assertion(V_uint64     =:=  6+10000000),
    assertion(V_sint32     ==  -7),
    assertion(V_sint64     ==  -8),
    assertion(V_fixed32    =:=  9+1000),
    assertion(V_fixed64    =:= 10+1000),
    assertion(V_sfixed32   == -11),
    assertion(V_sfixed64   == -12),
    assertion(V_bool       ==  true),
    assertion(V_string     ==  S3),
    assertion(V_bytes      ==  [0xf0, 0x28, 0x8c, 0x28]),
    assertion(V_enum       ==  'AnotherEnum'),
    assertion(V_utf8_codes == C3),
    assertion(V_key        ==  "foo"),
    assertion(V_value      ==  ""),
    test_write_template(Out, Template).

test(scalars1a_parse) :-
    [In, Out] = ['scalars1a_from_python.wire', 'scalars1a_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, 'test.Scalars1', Term), % No leading '.' for the MessageType
    !,
    string_values(S1, S2, _S3, _S4, _C1, _C2, _C3, _C4),
    assertion_eq_dict(Term,
                      '.test.Scalars1'{
                                       v_double     :1.5,
                                       v_float      :2.5,
                                       v_int32      :3,
                                       v_int64      :4,
                                       v_uint32     :5,
                                       v_uint64     :6,
                                       v_sint32     :7,
                                       v_sint64     :8,
                                       v_fixed32    :9,
                                       v_fixed64    :10,
                                       v_sfixed32   :11,
                                       v_sfixed64   :12,
                                       v_bool       :false,
                                       v_string     :S1,
                                       v_bytes      :[195,40],
                                       v_enum       :'E1',
                                       v_utf8_codes :S1,
                                       v_key_value  :'.test.KeyValue'{key:"reticulated python",
                                                                      value:S2}
                                      }),
    round_trip_serialize_parse(Term, 'test.Scalars1', Out),  % No leading '.' for MessageType
    !. % TODO: remove this and find where choice points are created

test(scalars1b_parse) :-
    [In, Out] = ['scalars1b_from_python.wire', 'scalars1b_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.test.Scalars1', Term),
    string_values(_S1, _S2, S3, _S4, _C1, _C2, _C3, _C4),
    X5 is 5+10000000,
    X6 is 6+10000000,
    X9 is 9+1000,
    X10 is 10+1000,
    assertion_eq_dict(Term,
                      '.test.Scalars1'{
                                       v_double    : -1.5,
                                       v_float     : -2.5,
                                       v_int32     : -3,
                                       v_int64     : -4,
                                       v_uint32    :  X5,
                                       v_uint64    :  X6,
                                       v_sint32    : -7,
                                       v_sint64    : -8,
                                       v_fixed32   :  X9,
                                       v_fixed64   :  X10,
                                       v_sfixed32  : -11,
                                       v_sfixed64  : -12,
                                       v_bool      :  true,
                                       v_string    :  S3,
                                       v_bytes     :  [0xf0, 0x28, 0x8c, 0x28],
                                       v_enum      :  'AnotherEnum',
                                       v_utf8_codes: S3,
                                       v_key_value :'.test.KeyValue'{key:"foo",
                                                                     value:""}
                                      }),
    round_trip_serialize_parse(Term, '.test.Scalars1', Out),
    !. % TODO: remove this and find where choice points are created

test(scalars1c_parse) :-
    [In, Out] = ['scalars1c_from_python.wire', 'scalars1c_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.test.Scalars1', Term),
    % Default values:
    assertion_eq_dict(Term,
                      '.test.Scalars1'{
                                       v_double    : 0.0,
                                       v_float     : 0.0,
                                       v_int32     : 0,
                                       v_int64     : 0,
                                       v_uint32    : 0,
                                       v_uint64    : 0,
                                       v_sint32    : 0,
                                       v_sint64    : 0,
                                       v_fixed32   : 0,
                                       v_fixed64   : 0,
                                       v_sfixed32  : 0,
                                       v_sfixed64  : 0,
                                       v_bool      : false,
                                       v_string    : "",
                                       v_bytes     : [],
                                       v_enum      : 'E1',
                                       v_utf8_codes: ""
                                       % v_key_value has no default
                                      }),
    round_trip_serialize_parse(Term, '.test.Scalars1', Out),
    !. % TODO: remove this and find where choice points are created

test(string_atom) :-
    Term = _{v_string:abc},
    protobuf_serialize_to_codes(Term, '.test.Scalars1', WireCodes),
    protobuf_parse_from_codes(WireCodes, '.test.Scalars1', Term2),
    assertion(Term2.v_string == "abc").

:- end_tests(scalar).

:- begin_tests(repeated).

test(repeated1a_template) :-
    [In, Out] = ['repeated1a_from_python.wire', 'repeated1a_from_prolog_template.wire'],
    read_message_codes(In, WireCodes),
    repeated1a_template(Template, Vars),
    Vars = [V_double,
            V_float,
            V_int32,
            V_int64,
            V_uint32,
            V_uint64,
            V_sint32,
            V_sint64,
            V_fixed32,
            V_fixed64,
            V_sfixed32,
            V_sfixed64,
            V_bool,
            V_string,
            V_bytes,
            V_enum,
            V_utf8_codes,
            V_key_values],
    protobuf_message(Template, WireCodes),
    protobuf_message(Template, WireCodes2),
    assertion(WireCodes == WireCodes2),
    protobuf_message(Template, WireCodes2), % once more, with both Template and WireCodes2 fully instantiated
    assertion(term_attvars(Template, [])),  % Can have vars from repeated_embedded
    assertion(ground(WireCodes)),
    assertion(ground(WireCodes2)),
    string_values(S1, _S2, _S3, S4, C1, _C2, _C3, _C4),
    string_codes("Hello world", C1a),
    assertion(V_double     == [1.5, 0.0, -1.5]),
    assertion(V_float      == [2.5, 0.0, -2.5]),
    assertion(V_int32      == [3, -3, 555, 0, 2147483647, -2147483648]),
    assertion(V_int64      == [4, -4, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_uint32     == [5, 0, 4294967295]),
    assertion(V_uint64     == [6, 7, 8, 9, 0, 18446744073709551615]),
    assertion(V_sint32     == [7, -7, 0, 2147483647, -2147483648]),
    assertion(V_sint64     == [-8, 8, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_fixed32    == [9, 0, 4294967295]),
    assertion(V_fixed64    == [10, 0, 18446744073709551615]),
    assertion(V_sfixed32   == [-11, 11, 0, 2147483647, -2147483648]),
    assertion(V_sfixed64   == [-12, 12, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_bool       == [false, true]),
    assertion(V_string     == [S1, "Hello world"]),
    assertion(V_bytes      == [[0xc3, 0x28], [0,1,2]]),
    assertion(V_enum       == ['E1','Enum2', 'E1']), % TODO: , 'NegEnum']),
    assertion(V_utf8_codes == [C1, C1a]),
    assertion(V_key_values == [protobuf([string(15,"foo"),string(128,"")]),
                               protobuf([string(15,S4),
                                         string(128,"reticulated python")])]),
    test_write_template(Out, Template).

test(repeated1a_parse) :-
    [In, Out] = ['repeated1a_from_python.wire', 'repeated1a_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.test.Repeated1', Term),
    string_values(S1, _S2, _S3, S4, _C1, _C2, _C3, _C4),
    assertion_eq_dict(Term,
                      '.test.Repeated1'{
                                       v_double    : [ 1.5, 0.0, -1.5],
                                       v_float     : [ 2.5, 0.0, -2.5],
                                       v_int32     : [ 3, -3, 555, 0, 2147483647, -2147483648],
                                       v_int64     : [ 4, -4, 0, 9223372036854775807, -9223372036854775808],
                                       v_uint32    : [ 5, 0, 4294967295],
                                       v_uint64    : [ 6, 7, 8, 9, 0, 18446744073709551615],
                                       v_sint32    : [ 7, -7, 0, 2147483647, -2147483648],
                                       v_sint64    : [ -8, 8, 0, 9223372036854775807, -9223372036854775808],
                                       v_fixed32   : [ 9, 0, 4294967295],
                                       v_fixed64   : [10, 0, 18446744073709551615],
                                       v_sfixed32  : [-11, 11, 0, 2147483647, -2147483648],
                                       v_sfixed64  : [-12, 12, 0, 9223372036854775807, -9223372036854775808],
                                       v_bool      : [false, true],
                                       v_string    : [S1, "Hello world"],
                                       v_bytes     : [[0xc3,0x28], [0x00,0x01,0x02]],
                                       v_enum      : ['E1', 'Enum2', 'E1'], % TODO: , 'NegEnum'],
                                       v_utf8_codes: [S1, "Hello world"],
                                       v_key_value : ['.test.KeyValue'{key:"foo", value:""},
                                                      '.test.KeyValue'{key:S4,
                                                                       value:"reticulated python"}]
                                      }),
    round_trip_serialize_parse(Term, '.test.Repeated1', Out),
    !. % TODO: remove this and find where choice points are created

test(packed1a_template) :-
    [In, Out] = ['packed1a_from_python.wire', 'packed1a_from_prolog_template.wire'],
    read_message_codes(In, WireCodes),
    packed1a_template(Template, Vars),
    Vars = [V_double,
            V_float,
            V_int32,
            V_int64,
            V_uint32,
            V_uint64,
            V_sint32,
            V_sint64,
            V_fixed32,
            V_fixed64,
            V_sfixed32,
            V_sfixed64,
            V_bool,
            V_string,
            V_bytes,
            V_enum,
            V_utf8_codes,
            V_key_values],
    protobuf_message(Template, WireCodes),
    assertion(term_attvars(Template, [])),  % Can have vars from repeated_embedded
    assertion(ground(WireCodes)),
    string_values(S1, _S2, _S3, S4, C1, _C2, _C3, _C4),
    string_codes("Hello world", C1a),
    assertion(V_double     == [1.5, 0.0, -1.5]),
    assertion(V_float      == [2.5, 0.0, -2.5]),
    assertion(V_int32      == [3, -3, 555, 0, 2147483647, -2147483648]),
    assertion(V_int64      == [4, -4, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_uint32     == [5, 0, 4294967295]),
    assertion(V_uint64     == [6, 7, 8, 9, 0, 18446744073709551615]),
    assertion(V_sint32     == [7, -7, 0, 2147483647, -2147483648]),
    assertion(V_sint64     == [-8, 8, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_fixed32    == [9, 0, 4294967295]),
    assertion(V_fixed64    == [10, 0, 18446744073709551615]),
    assertion(V_sfixed32   == [-11, 11, 0, 2147483647, -2147483648]),
    assertion(V_sfixed64   == [-12, 12, 0, 9223372036854775807, -9223372036854775808]),
    assertion(V_bool       == [false, true]),
    assertion(V_string     == [S1, "Hello world"]),
    assertion(V_bytes      == [[0xc3, 0x28], [0,1,2]]),
    assertion(V_enum       == ['E1','Enum2','E1']), % TODO: 'NegEnum']),
    assertion(V_utf8_codes == [C1, C1a]),
    assertion(V_key_values == [protobuf([string(15,"foo"),string(128,"")]),
                               protobuf([string(15,S4),
                                         string(128,"reticulated python")])]),
    test_write_template(Out, Template).

test(packed1a_parse) :-
    [In, Out] = ['packed1a_from_python.wire', 'packed1a_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.test.Packed1', Term),
    string_values(S1, _S2, _S3, S4, _C1, _C2, _C3, _C4),
    assertion_eq_dict(Term,
                      '.test.Packed1'{
                                       v_double    : [ 1.5, 0.0, -1.5],
                                       v_float     : [ 2.5, 0.0, -2.5],
                                       v_int32     : [ 3, -3, 555, 0, 2147483647, -2147483648],
                                       v_int64     : [ 4, -4, 0, 9223372036854775807, -9223372036854775808],
                                       v_uint32    : [ 5, 0, 4294967295],
                                       v_uint64    : [ 6, 7, 8, 9, 0, 18446744073709551615],
                                       v_sint32    : [ 7, -7, 0, 2147483647, -2147483648],
                                       v_sint64    : [ -8, 8, 0, 9223372036854775807, -9223372036854775808],
                                       v_fixed32   : [ 9, 0, 4294967295],
                                       v_fixed64   : [10, 0, 18446744073709551615],
                                       v_sfixed32  : [-11, 11, 0, 2147483647, -2147483648],
                                       v_sfixed64  : [-12, 12, 0, 9223372036854775807, -9223372036854775808],
                                       v_bool      : [false, true],
                                       v_string    : [S1, "Hello world"],
                                       v_bytes     : [[0xc3,0x28], [0x00,0x01,0x02]],
                                       v_enum      : ['E1', 'Enum2', 'E1'], % , 'NegEnum'],
                                       v_utf8_codes:[S1, "Hello world"],
                                       v_key_value : ['.test.KeyValue'{key:"foo", value:""},
                                                     '.test.KeyValue'{key:S4,
                                                                      value:"reticulated python"}]
                                      }),
    round_trip_serialize_parse(Term, '.test.Packed1', Out),
    !. % TODO: remove this and find where choice points are created

:- end_tests(repeated).

:- begin_tests(golden).

% Taken from protobuf/src/google/protobuf/unittest.proto and
% protobuf_unittest.TestAllTypes (see also golden_message/1 in
% ../test_protobufs.pl)

test(golden_2_5_0_parse) :-
    [In, Out] = ['../golden_message.2.5.0', 'golden_message.2.5.0_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.protobuf_unittest.TestAllTypes', Term),
    % To double-check the following:
    %    protoc -I. --decode=protobuf_unittest.TestAllTypes google/protobuf/unittest.proto <../golden_message.2.5.0
    assertion_eq_dict(Term,
        '.protobuf_unittest.TestAllTypes'{
                                          % oneof_bytes:[],  % part of a oneof group
                                          % oneof_string:"", % part of a oneof group
                                          % oneof_uint32:0,  % part of a oneof group

                                          optional_int32:101,
                                          optional_int64:102,
                                          optional_uint32:103,
                                          optional_uint64:104,
                                          optional_sint32:105,
                                          optional_sint64:106,
                                          optional_fixed32:107,
                                          optional_fixed64:108,
                                          optional_sfixed32:109,
                                          optional_sfixed64:110,
                                          optional_float:111.0,
                                          optional_double:112.0,
                                          optional_bool:true,
                                          optional_string:"115",
                                          optional_bytes:[49,49,54], % "116",
                                          optionalgroup:'.protobuf_unittest.TestAllTypes.OptionalGroup'{ a:117 },
                                          optional_nested_message:'.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:118 },
                                          optional_foreign_message:'.protobuf_unittest.ForeignMessage'{ c:119, d:0 },
                                          optional_import_message:'.protobuf_unittest_import.ImportMessage'{ d:120 },
                                          optional_nested_enum:'BAZ',
                                          optional_foreign_enum:'FOREIGN_BAZ',
                                          optional_import_enum:'IMPORT_BAZ',
                                          optional_string_piece:"124",
                                          optional_cord:"125",
                                          optional_public_import_message:'.protobuf_unittest_import.PublicImportMessage'{ e:126 },
                                          optional_lazy_message:'.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:127 },
                                          repeated_int32:[201,301],
                                          repeated_int64:[202,302],
                                          repeated_uint32:[203,303],
                                          repeated_uint64:[204,304],
                                          repeated_sint32:[205,305],
                                          repeated_sint64:[206,306],
                                          repeated_fixed32:[207,307],
                                          repeated_fixed64:[208,308],
                                          repeated_sfixed32:[209,309],
                                          repeated_sfixed64:[210,310],
                                          repeated_float:[211.0,311.0],
                                          repeated_double:[212.0,312.0],
                                          repeated_bool:[true,false],
                                          repeated_string:["215","315"],
                                          repeated_bytes:[ [50,49,54], % repeated_bytes: [b"216", b"316"]
                                                           [51,49,54]
                                                         ],
                                          repeatedgroup:[ '.protobuf_unittest.TestAllTypes.RepeatedGroup'{ a:217 },
                                                          '.protobuf_unittest.TestAllTypes.RepeatedGroup'{ a:317 }
                                                        ],
                                         repeated_nested_message:[ '.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:218 },
                                                                   '.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:318 }
                                                                 ],
                                          repeated_foreign_message:[ '.protobuf_unittest.ForeignMessage'{ c:219, d:0 },
                                                                     '.protobuf_unittest.ForeignMessage'{ c:319, d:0 }
                                                                   ],
                                          repeated_import_message:[ '.protobuf_unittest_import.ImportMessage'{ d:220 },
                                                                    '.protobuf_unittest_import.ImportMessage'{ d:320 }
                                                                  ],
                                          repeated_nested_enum:['BAR','BAZ'],
                                          repeated_foreign_enum:[ 'FOREIGN_BAR',
                                                                  'FOREIGN_BAZ'
                                                                ],
                                          repeated_import_enum:[ 'IMPORT_BAR',
                                                                 'IMPORT_BAZ'
                                                               ],
                                          repeated_string_piece:["224","324"],
                                          repeated_cord:["225","325"],
                                          repeated_lazy_message:[ '.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:227 },
                                                                  '.protobuf_unittest.TestAllTypes.NestedMessage'{ bb:327 }
                                                                ],
                                          default_int32:401,
                                          default_int64:402,
                                          default_uint32:403,
                                          default_uint64:404,
                                          default_sint32:405,
                                          default_sint64:406,
                                          default_fixed32:407,
                                          default_fixed64:408,
                                          default_sfixed32:409,
                                          default_sfixed64:410,
                                          default_float:411.0,
                                          default_double:412.0,
                                          default_bool:false,
                                          default_string:"415",
                                          default_bytes:[52,49,54], % b"416"
                                          default_nested_enum:'FOO',
                                          default_foreign_enum:'FOREIGN_FOO',
                                          default_import_enum:'IMPORT_FOO',
                                          default_string_piece:"424",
                                          default_cord:"425"
                                         }),
    round_trip_serialize_parse(Term, '.protobuf_unittest.TestAllTypes', Out),
    !. % TODO: remove this and find where choice points are created

:- end_tests(golden).

:- begin_tests(oneof).

test(oneof) :-
    [In, _Out] = ['oneof1_from_python.wire', 'oneof1_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    protobuf_parse_from_codes(WireCodes, '.OneofMessage', Term),
    % TODO: This is what's on the wire, after processing default values.
    %       Needs "oneof" processing to remove bar and name
    assertion(Term == '.OneofMessage'{
                                      % bar:0.0, % part of oneof group
                                      foo:"FOO",
                                      % name:"", % part of oneof group
                                      number:666
                                      % qqsv:"" % part of oneof group
                                     }).

% TODO: add test(oneofb)

:- end_tests(oneof).

:- begin_tests(map).

test(map) :-
    [In, _Out] = ['map1_from_python.wire', 'map1_from_prolog.wire'],
    read_message_codes(In, WireCodes),
    /*
      $ protoc --decode=MapMessage test2.proto <map1_from_python.wire
      number_ints {
        key: "one"
        value: 1
      }
      number_ints {
        key: "two"
        value: 2
      }
    */
    /*
      Codes = [42,7,10,3,111,110,101,16,2,42,7,10,3,116,119,111,16,4]
      Segments =  [ message(5,[string(1,"one"),varint(2,2)]),
                    message(5,[string(1,"two"),varint(2,4)]) ]
    */
    protobuf_parse_from_codes(WireCodes, '.MapMessage', Term), % No package: needs 1 leading '.'
    is_dict(Term, MessageType),
    assertion(protobufs:proto_meta_normalize(MessageType, '.MapMessage')),
    protobuf_field_is_map(MessageType, number_ints),
    protobuf_map_pairs(Term.number_ints, MapTag, Pairs0),
    assertion(MapTag == '.MapMessage.NumberIntsEntry'), % TODO: does protobuf spec guarantee this?
    keysort(Pairs0, Pairs),
    assertion(Pairs == ["one"-1, "two"-2]),
    protobuf_map_pairs(RawMap, MapTag, Pairs0), % Create RawMap from Pairs0
    assertion(RawMap == Term.number_ints),
    % TODO: The following is what's on the wire without any special map<> handling.
    %       The ordering can be "random", due to Python hash randomization
    assertion((  Term == '.MapMessage'{
                             number_ints:[
                                 '.MapMessage.NumberIntsEntry'{key:"one",value:1},
                                 '.MapMessage.NumberIntsEntry'{key:"two",value:2}]}
             ;   Term == '.MapMessage'{
                             number_ints:[
                                 '.MapMessage.NumberIntsEntry'{key:"two",value:2},
                                 '.MapMessage.NumberIntsEntry'{key:"one",value:1}]}
             )).

:- end_tests(map).

end_of_file.