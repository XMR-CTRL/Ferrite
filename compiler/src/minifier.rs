
pub struct Minifier {
}

impl Minifier {
    pub fn new() -> Self {
        Minifier {}
    }
    
    pub fn minify_luau(&self, code: &str) -> String {
        let mut result = String::new();
        let mut in_string = false;
        let mut in_comment = false;
        let mut in_multiline_comment = false;
        let mut prev_char = ' ';
        
        for (i, ch) in code.chars().enumerate() {
            if ch == '"' || ch == '\'' {
                if !in_comment && !in_multiline_comment {
                    in_string = !in_string;
                    result.push(ch);
                    prev_char = ch;
                    continue;
                }
            }
            
            if ch == '-' && i + 1 < code.len() && code.chars().nth(i + 1) == Some('-') && !in_string && !in_multiline_comment {
                in_comment = true;
                continue;
            }
            
            if in_comment && ch == '\n' {
                in_comment = false;
                result.push(ch);
                prev_char = ch;
                continue;
            }
            
            if in_comment {
                continue;
            }
            
            if ch == '[' && i + 1 < code.len() && code.chars().nth(i + 1) == Some('[') && !in_string && !in_comment {
                in_multiline_comment = true;
                continue;
            }
            
            if ch == ']' && i + 1 < code.len() && code.chars().nth(i + 1) == Some(']') && in_multiline_comment {
                in_multiline_comment = false;
                continue;
            }
            
            if in_multiline_comment {
                continue;
            }
            
            if ch.is_whitespace() && !in_string {
                if ch == '\n' && prev_char != ';' && prev_char != '\n' {
                    result.push(' ');
                }
                prev_char = ch;
                continue;
            }
            
            if in_string {
                result.push(ch);
            } else {
                if ch == ';' && prev_char == ';' {
                    continue;
                }
                result.push(ch);
            }
            
            prev_char = ch;
        }
        
        result
    }
    
    pub fn dead_code_elimination(&self, code: &str, used_functions: &[String]) -> String {
        let mut result = String::new();
        let mut in_function = false;
        let mut current_function = String::new();
        let mut brace_count = 0;
        
        for line in code.lines() {
            let trimmed = line.trim();
            
            if trimmed.starts_with("function ") || trimmed.starts_with("local function ") {
                in_function = true;
                current_function = trimmed
                    .replace("function ", "")
                    .replace("local function ", "")
                    .split('(')
                    .next()
                    .unwrap_or("")
                    .trim()
                    .to_string();
                brace_count = 0;
                result.push_str(line);
                result.push('\n');
                continue;
            }
            
            if in_function {
                brace_count += line.matches('{').count() as i32;
                brace_count -= line.matches('}').count() as i32;
                
                if brace_count == 0 && !used_functions.contains(&current_function) {
                    in_function = false;
                    continue;
                }
                
                if brace_count == 0 {
                    in_function = false;
                }
            }
            
            result.push_str(line);
            result.push('\n');
        }
        
        result
    }
}

impl Default for Minifier {
    fn default() -> Self {
        Self::new()
    }
}
