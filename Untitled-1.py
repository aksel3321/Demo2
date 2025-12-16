def hello_world():
    """Print a greeting message."""
    print("Hello, World!")

def add(a, b):
    """Add two numbers and return the result."""
    return a + b

def main():
    """Main function to run the program."""
    hello_world()
    result = add(5, 3)
    print(f"5 + 3 = {result}")

if __name__ == "__main__":
    main()