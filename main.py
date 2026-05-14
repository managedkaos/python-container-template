"""
Use this template to create a custom Python function
"""

# import os
# import re
import sys


def custom_function(function_input):
    """
    Update or replace this function as needed.
    """
    return f"Custom function output: {function_input}"


if __name__ == "__main__":
    # Set the input to be sys.argv[1] if it exists
    # otherwise set it to a default value
    input_value = sys.argv[1] if len(sys.argv) > 1 else "default_value"

    print(custom_function(sys.argv[1]))
