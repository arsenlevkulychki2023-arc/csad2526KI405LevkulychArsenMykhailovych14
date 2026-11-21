from add import add


def main() -> None:
    if add(2, 3) != 5:
        raise ValueError("add returned an unexpected result")
    print("Hello, World!")


if __name__ == "__main__":
    main()
