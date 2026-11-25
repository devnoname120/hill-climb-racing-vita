import argparse
from pathlib import Path


def extract_helper(source: Path, destination: Path) -> None:
    text = source.read_text()
    start = text.index(
        "static inline __attribute__((always_inline)) GLboolean glsl_is_ident_char("
    )
    end = text.index("\nvoid glsl_translator_process(", start)
    helper = text[start:end]
    if helper.count("static void glsl_translate_stpq_swizzles(") != 1:
        raise ValueError("Expected one upstream swizzle helper in the pinned vitaGL source")
    destination.write_text(helper)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    extract_helper(args.source, args.destination)
