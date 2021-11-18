import math
from itertools import count, islice
from math import ceil
from typing import Generator, Callable
from Tools import *


class Hamming:
    def __init__(self, k: int):
        self.k = k

    @property
    def p_matrix(self) -> bitmatrix:
        return Hamming.calculate_p_matrix(self.k, self.r)

    @property
    def e_matrix(self) -> bitmatrix:
        return Hamming.calculate_e_matrix(self.r)

    @property
    def matrix(self) -> bitmatrix:
        return cat_matrices(self.p_matrix, self.e_matrix)

    @property
    def r(self) -> int:
        return Hamming.r_from_k_for_basic_matrix(self.k)

    @staticmethod
    def column_gen(length: int) -> Generator[bitlist, None, None]:
        for i in count():
            if i.bit_count() >= 2:
                yield to_bit_string(i, length)

    @staticmethod
    def r_from_k_for_basic_matrix(k: int) -> int:
        return ceil(math.log2(k)) + 1

    @staticmethod
    def r_from_k_for_extended_matrix(k: int) -> int:
        return Hamming.r_from_k_for_basic_matrix(k) + 1

    @staticmethod
    def calculate_p_matrix(k: int, r: int) -> bitmatrix:
        columns = [*islice(Hamming.column_gen(r), k)]
        return transpose(columns)

    @staticmethod
    def calculate_matrix(k: int, r: int) -> bitmatrix:
        return cat_matrices(Hamming.calculate_p_matrix(k, r), Hamming.calculate_e_matrix(r))

    @staticmethod
    def calculate_e_matrix(r: int) -> bitmatrix:
        return identity_matrix(r)

    def calculate_x_r(self, message: int) -> bitlist:
        bit_message = to_bit_string(message, self.k)
        return [apply_xor(apply_and(a, bit_message), None) for a in self.p_matrix]

    def calculate_x_r_from_x_k(self, x_k: bitlist) -> bitlist:
        return [apply_xor(apply_and(a, x_k), None) for a in self.p_matrix]

    def calculate_x_k(self, message: int) -> bitlist:
        return to_bit_string(message, self.k)

    def calculate_x(self, message: int) -> bitlist:
        return self.calculate_x_k(message) + self.calculate_x_r(message)

    def __str__(self):
        return '\n'.join([''.join(['{:4}'.format(item) for item in row]) for row in self.matrix])

    def find_error_column_index(self, error: bitlist):
        return transpose(self.matrix).index(error)


class Message:
    def __init__(self, value: int, hamming_matrix_provider: Callable[[int], Hamming]):
        self.value = value
        self.k = self.value.bit_count()
        self.hamming_matrix = hamming_matrix_provider(self.k)
        self.r = self.hamming_matrix.r
        self.x_k = self.hamming_matrix.calculate_x_k(self.value)
        self.x_r = self.hamming_matrix.calculate_x_r(self.value)

    @property
    def n(self) -> int:
        return self.k + self.r

    @property
    def x(self) -> bitlist:
        return self.x_k + self.x_r

    # чел просто не засовывай туда массивы не того размера ок да?
    @x.setter
    def x(self, value: bitlist):
        assert len(value) == self.n
        self.x_k = value[:self.k]
        self.x_r = value[self.k:]

    def invert_bit(self, error_bit_number: int):
        new_x = self.x
        new_x[error_bit_number] = invert(new_x[error_bit_number])
        self.x = new_x

    def __str__(self):
        return f"Xk = {self.x_k}, Xr = {self.x_r}, X = {self.x}"

    @property
    def error_syndrome(self):
        x_r_actual = self.hamming_matrix.calculate_x_r_from_x_k(self.x_k)
        return apply_xor(x_r_actual, self.x_r)


class ExtendedHamming(Hamming):
    @property
    def r(self) -> int:
        return Hamming.r_from_k_for_extended_matrix(self.k)

    @property
    def e_matrix(self) -> bitmatrix:
        base_matrix = Hamming.calculate_e_matrix(super().r)
        matrix_with_new_column = [row + [0] for row in base_matrix]
        new_row = [int(not reduce(ixor, column)) for column in zip(*matrix_with_new_column)]
        matrix_with_new_column.append(new_row)
        return matrix_with_new_column

    @property
    def p_matrix(self) -> bitmatrix:
        base_matrix = Hamming.calculate_p_matrix(self.k, super().r)
        new_row = [int(not reduce(ixor, column)) for column in zip(*base_matrix)]
        base_matrix.append(new_row)
        return base_matrix


def matrix_test(matrix_provider: Callable[[int], Hamming]):
    msg = Message(389, matrix_provider)
    print("matrix: ")
    print(msg.hamming_matrix)
    print(f"message: {msg}")

    print("0 errors: ")
    print(f"syndrome: {msg.error_syndrome}\n")

    error_bit = 1
    msg.invert_bit(error_bit)
    print(f"1 errors, error bit number: {error_bit}")
    print(f"message with error: {msg}")
    syndrome = msg.error_syndrome
    print(f"syndrome: {syndrome}")
    error_column_index = msg.hamming_matrix.find_error_column_index(syndrome)
    print(f"found error bit: {error_column_index}")
    msg.invert_bit(error_column_index)
    print(f"fixed message: {msg}\n")

    error_bits = [1, 2]
    msg.invert_bit(error_bits[0])
    msg.invert_bit(error_bits[1])
    print(f"2 errors, error bit numbers: {error_bits}")
    print(f"message with error: {msg}")
    syndrome = msg.error_syndrome
    print(f"syndrome: {syndrome}")


matrix_test(Hamming)
matrix_test(ExtendedHamming)
