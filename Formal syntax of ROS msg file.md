# Formal syntax of ROS .msg file

* Line of file:

`whitespace<definition>whitespace#<comment>`

* definition:

`<fieldtype> <fieldname> [defaultvalue]` |
`<constanttype> <CONSTANTNAME> = <value>` |

* fieldtype:

`<typename>[arraydefinition]`

* typename:

`<builtitype>` | `<complextype>`

* constanttype:

`<builtitype>`

* builtitype:

 Type name | Swift  |     C++     | Python          | DDS type
 ----------|--------|-------------|-----------------|----------
 bool      | Bool   | bool        | builtins.bool   | boolean
 byte      | UInt8  | uint8_t     | builtins.bytes  | octet
 char      | Int8   | char        | builtins.str    | char
 float32   | Float  | float       | builtins.float  | float
 float64   | Double | double      | builtins.float  | double
 int8      | Int8   | int8_t      | builtins.int    | octet
 uint8     | UInt8  | uint8_t     | builtins.int    | octet
 int16     | Int16  | int16_t     | builtins.int    | short
 uint16    | UInt16 | uint16_t    | builtins.int    | unsigned short
 int32     | Int32  | int32_t     | builtins.int    | long
 uint32    | UInt32 | uint32_t    | builtins.int    | unsigned long
 int64     | Int64  | int64_t     | builtins.int    | long long
 uint64    | UInt64 | uint64_t    | builtins.int    | unsigned long long
 string    | String | std::string | builtins.str    | string
