use crate::prelude::*;

/// Hook for localStorage persistence
pub fn use_local_storage<T>(_key: &str, _initial_value: T) -> (T, Box<dyn Fn(T)>) {
    (unimplemented!(), Box::new(|_| {}))
}

/// Hook for sessionStorage persistence
pub fn use_session_storage<T>(_key: &str, _initial_value: T) -> (T, Box<dyn Fn(T)>) {
    (unimplemented!(), Box::new(|_| {}))
}

/// Persistence manager
pub struct PersistenceManager;

impl PersistenceManager {
    pub fn new() -> Self {
        PersistenceManager
    }
    
    pub fn set_item<T>(&self, _key: &str, _value: T) {
    }
    
    pub fn get_item<T>(&self, _key: &str) -> Option<T> {
        None
    }
    
    pub fn remove_item(&self, _key: &str) {
    }
    
    pub fn clear(&self) {
    }
}
