pub trait Alphabet {
    fn get_char_for_index(&self, index: u8) -> Option<char>;
    fn get_padding_char(&self) -> char;
}

pub struct Classic;
const UPPERCASEOFFSET: i8 = 65;
const LOWERCASEOFFSET: i8 = 71;
const DIGITOFFSET: i8 = -4;

impl Alphabet for Classic {
    fn get_char_for_index(&self, index: u8) -> Option<char> {
        let index = index as i8;

        let ascii_index = match index {
            0..=25 => index + UPPERCASEOFFSET,  // A-Z
            26..=51 => index + LOWERCASEOFFSET, // a-z
            52..=61 => index + DIGITOFFSET,     // 0-9
            62 => 43,                           // +
            63 => 47,                           // /

            _ =>  return None,
        } as u8;

        Some(ascii_index as char)
    }


    fn get_padding_char(&self) -> char {
        '='
    }
}