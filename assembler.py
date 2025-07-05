from dataclasses import dataclass
from typing import List, Optional

@dataclass
class Instruction:
    opcode: Optional[str]
    args: Optional[List[str]]

def parse(line: List[str]):
    opcode = None
    args = list()
    if line[0].lower() == "outloc":
        opcode = "outloc"
        args.append(line[1])
    elif line[0].lower() == "dw":
        opcode = "dw"
        args.append(line[1])
    return Instruction (
        opcode = opcode,
        args = args,
    )

def compile(instr):
    if instr.opcode == "outloc":
        return "00"+instr.args[0]
    elif instr.opcode == "dw":
        assert len(instr.args[0]) == 8
        return " ".join([instr.args[0][i:i+4] for i in range(0, len(instr.args[0]), 4)])

def main():
    binary = ""
    with open("test.s", "r") as f:
        for line in f.readlines():
            line = line.split()
            instr = parse(line)
            binary += compile(instr) + "\n"
    with open("test.bin", "w") as f:
        f.write(binary)


if __name__ == "__main__":
    main()
