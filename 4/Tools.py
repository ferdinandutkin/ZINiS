import typing
from functools import reduce
from operator import ixor, iand
from typing import TypeVar, List, Optional, overload, Union
from Types import bit, bitlist, bitmatrix


def to_bit_string(val: int, length: Optional[int]) -> List[bit]:
    length = length or val.bit_length()
    return [typing.cast(bit, val >> i & 1) for i in range(length - 1, -1, -1)]


def identity_matrix(d: int) -> bitmatrix:
    return [[typing.cast(bit, int(x == y)) for x in range(d)] for y in range(d)]


def invert(val: bit) -> bit:
    return typing.cast(bit, 0 if val == 1 else 1)


A = TypeVar('A')
B = TypeVar('B')


def transpose(matrix: List[List[A]]) -> List[List[A]]:
    return [[matrix[j][i] for j in range(len(matrix))] for i in range(len(matrix[0]))]


def cat_matrices(a: List[List[A]], b: List[List[A]]):
    return [i + j for i, j in zip(a, b)]


@overload
def apply_xor(a: List[A], b: List[A]) -> List[bit]:
    pass


@overload
def apply_xor(a: List[A], b: None) -> bit:
    pass


def apply_xor(a: List[A], b: Optional[List[A]]) -> Union[List[bit], bit]:
    if b is None:
        return reduce(ixor, a)
    else:
        return [typing.cast(bit, int(i != j)) for i, j in zip(a, b)]


@overload
def apply_and(a: List[A], b: List[A]) -> List[bit]:
    pass


@overload
def apply_and(a: List[A], b: None) -> bit:
    pass


def apply_and(a: List[A], b: Optional[List[A]]) -> Union[List[bit], bit]:
    if b is None:
        return reduce(iand, a)
    else:
        return [typing.cast(bit, int(bool(i) & bool(j))) for i, j in zip(a, b)]
