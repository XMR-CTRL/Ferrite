use std::path::Path;
use std::collections::HashSet;

pub struct TreeShaker {
    used_components: HashSet<String>,
    all_components: HashSet<String>,
}

impl TreeShaker {
    pub fn new() -> Self {
        TreeShaker {
            used_components: HashSet::new(),
            all_components: HashSet::new(),
        }
    }
    
    pub fn analyze_usage(&mut self, entry_point: &str) {
        self.used_components.insert(entry_point.to_string());
    }
    
    pub fn scan_directory(&mut self, dir: &Path) {
        if let Ok(entries) = std::fs::read_dir(dir) {
            for entry in entries.flatten() {
                if let Ok(path) = entry.path().strip_prefix(dir) {
                    if let Some(name) = path.file_stem() {
                        let name_str = name.to_string_lossy().to_string();
                        if name_str != "index" {
                            self.all_components.insert(name_str);
                        }
                    }
                }
            }
        }
    }
    
    pub fn get_unused_components(&self) -> Vec<String> {
        self.all_components
            .difference(&self.used_components)
            .cloned()
            .collect()
    }
    
    pub fn remove_unused(&self, output_dir: &Path) -> Result<(), std::io::Error> {
        let unused = self.get_unused_components();
        
        for component in unused {
            let file_path = output_dir.join(format!("{}.luau", component));
            if file_path.exists() {
                std::fs::remove_file(&file_path)?;
                println!("Removed unused component: {}", component);
            }
        }
        
        Ok(())
    }
}

impl Default for TreeShaker {
    fn default() -> Self {
        Self::new()
    }
}
