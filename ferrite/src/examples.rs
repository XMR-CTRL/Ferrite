use crate::prelude::*;

#[script]
pub fn calculate_sum() {
    let mut sum = 0;
    for i in 1..=10 {
        sum = sum + i;
    }
    print!("Sum: {}", sum);
}

#[script]
pub fn factorial(n: i32) -> i32 {
    if n <= 1 {
        return 1;
    }
    let mut result = 1;
    for i in 2..=n {
        result = result * i;
    }
    result
}

#[script]
pub fn countdown(start: i32) {
    let mut current = start;
    while current > 0 {
        print!("{}", current);
        current = current - 1;
    }
    print!("Blast off!");
}
