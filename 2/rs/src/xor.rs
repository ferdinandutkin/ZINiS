use std::iter::FromIterator;
use core::iter;

pub trait BitXOR<T : BitXOR<T>> {
    fn xor_with(&self, other: &T) -> T;
}


impl BitXOR<String> for String {
    fn xor_with(&self, other: &String) -> String {

        let self_bits = iter::repeat('\0')
                .take(if other.len() > self.len() {other.len() - self.len()} else { 0 })
                .chain(self.chars())
                .flat_map(to_bits);

        let other_bits = iter::repeat('\0')
                .take(if self.len() > other.len() {self.len() - other.len()} else { 0 })
                .chain(other.chars())
                .flat_map(to_bits);


        let xored = self_bits
            .zip(other_bits)
            .map(|(a, b)| a ^ b)
            .map(bool_to_char);

        String::from_iter(xored)
    }
}


pub fn to_bit_str(str : &String) -> String {
    String::from_iter(str.chars().flat_map(to_bits).map(bool_to_char))
}

pub fn bool_to_char(b : bool) -> char {
    if b {'1'}  else {'0'}
}
pub fn to_bits(source: char) -> Vec<bool> {
    let mut bits = vec![false; 8];
    let mut idx = bits.len() as i32 - 1;
    let mut source_int = source as i32;
    while idx != -1  {
        bits[idx as usize] = (source_int & 1) != 0;
        idx -= 1;
        source_int /= 2;
    }
    bits
}