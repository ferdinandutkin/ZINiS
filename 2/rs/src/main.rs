use crate::ecoder::encode;
use std::{fs, env};
use std::fs::OpenOptions;
use std::io::Write;
use crate::xor::{BitXOR, to_bit_str};


mod aplhabet;
mod ecoder;
mod xor;




fn main() {



    let name_str = String::from("stanislau");
    let surname_str = String::from("tumash");

    let name = to_bit_str(&name_str);
    let surname =to_bit_str(&surname_str);

    println!("{} ({}) ^ {} ({}) = {}", name_str, name, surname_str, surname, &name_str.xor_with(&surname_str));


    let args: Vec<String> = env::args()
        .collect();


    let default_input_file_name = &String::from("input.txt");

    let input_file_name  = &args
        .get(1)
        .unwrap_or(default_input_file_name);

    let default_output_file_name = &String::from("input.txt");

    let output_file_name = &args
        .get(2)
        .unwrap_or(default_output_file_name);

    let content = fs::read_to_string(input_file_name)
        .expect(format!("file {} not found", input_file_name)
            .as_str());


    let output = encode(content.as_bytes());



    let mut output_file = OpenOptions::new()
        .write(true)
        .create(true)
        .open("output.txt")
        .unwrap();

    output_file
        .write(output.as_bytes())
        .expect(format!("error while writing to {}", output_file_name).as_str());




}

