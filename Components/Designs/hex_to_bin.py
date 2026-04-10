import sys
import os

def hex_to_bin(input_path):
    base, ext = os.path.splitext(input_path)
    output_path = base + "convertedToBIN" + ext

    with open(input_path, "r") as f:
        lines = f.read().splitlines()

    results = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            results.append("")
            continue
        value = int(stripped, 16)
        # Preserve bit width based on hex digits (excluding "0x" prefix)
        hex_digits = len(stripped.lstrip("0x").lstrip("0") or "0")
        bit_width = (len(stripped) - 2) * 4  # each hex digit = 4 bits
        binary_str = format(value, f"0{bit_width}b")
        results.append(f"0b{binary_str}")

    with open(output_path, "w") as f:
        f.write("\n".join(results))

    print(f"Converted {len([r for r in results if r])} values -> {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python hex_to_bin.py <input_file>")
        sys.exit(1)
    hex_to_bin(sys.argv[1])
