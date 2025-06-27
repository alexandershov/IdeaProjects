import argparse
import pathlib

from google.protobuf import descriptor_pb2
# foo_pb2 is an output of py_proto_library
from proto import foo_pb2


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('descriptor_path', type=pathlib.Path)
    return parser.parse_args()


def main():
    args = parse_args()
    d = descriptor_pb2.FileDescriptorSet()
    descriptor_bin = args.descriptor_path.read_bytes()
    d.ParseFromString(descriptor_bin)
    # will output (if foo.proto is the input)
    """
    d=file {
  name: "proto/foo.proto"
  message_type {
    name: "Person"
    field {
      name: "age"
      number: 1
      label: LABEL_OPTIONAL
      type: TYPE_UINT64
      json_name: "age"
    }
    field {
      name: "name"
      number: 2
      label: LABEL_OPTIONAL
      type: TYPE_STRING
      json_name: "name"
    }
  }
}
    """
    print(f"{d=}")


if __name__ == '__main__':
    main()
