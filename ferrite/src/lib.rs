pub use ferrite_macros::{component, view, script};

pub struct UiNode;

pub struct State<T> {
    value: T,
    _reducer: Option<Box<dyn Fn(T, T) -> T>>,
}

impl<T: Clone> Clone for State<T> {
    fn clone(&self) -> Self {
        State {
            value: self.value.clone(),
            _reducer: None, // Can't clone functions, so reset to None
        }
    }
}

impl<T: Clone> State<T> {
    pub fn get(&self) -> T {
        self.value.clone()
    }
    
    pub fn set(&mut self, new_val: T) {
        self.value = new_val;
    }
}

pub fn use_state<T, F>(init: F) -> State<T> 
where
    F: FnOnce() -> T
{
    State {
        value: init(),
        _reducer: None,
    }
}

// Effect hook for side effects
pub struct Effect {
    cleanup: Option<Box<dyn Fn()>>,
}

pub fn use_effect<F>(effect: F) -> Effect
where
    F: Fn() -> Box<dyn Fn()> + 'static
{
    Effect {
        cleanup: Some(effect()),
    }
}

impl Effect {
    pub fn cleanup(&mut self) {
        if let Some(cleanup) = self.cleanup.take() {
            cleanup();
        }
    }
}

// Ref hook for persistent references
pub struct Ref<T> {
    pub current: T,
}

pub fn use_ref<T>(initial: T) -> Ref<T> {
    Ref {
        current: initial,
    }
}

// Memo hook for memoization
pub fn use_memo<T, F>(factory: F, _deps: &[&dyn std::any::Any]) -> T
where
    F: FnOnce() -> T,
{
    factory()
}

// Callback hook for memoizing callbacks
pub fn use_callback<F, Args>(callback: F, _deps: &[&dyn std::any::Any]) -> F
where
    F: Fn(Args),
{
    callback
}

// Context types
pub struct Context<T> {
    pub value: T,
}

impl<T> Context<T> {
    pub fn new(value: T) -> Self {
        Self { value }
    }
}

pub fn use_context<T>(_context: &Context<T>) -> &T {
    // This will be implemented by the macro to extract from context stack
    panic!("use_context must be used within a Provider")
}

// Reducer hook for complex state
pub fn use_reducer<S, R>(initial: S, reducer: R) -> State<S>
where
    S: Clone,
    R: Fn(S, S) -> S + 'static,
{
    State {
        value: initial,
        _reducer: Some(Box::new(reducer)),
    }
}

pub mod prelude {
    pub use crate::{component, view, script, UiNode, use_state, State, use_effect, use_ref, use_memo, use_callback, use_context, Context, use_reducer, Effect, Ref};
}

pub mod counter;
pub mod redundant;
pub mod test_simple;
pub mod context;
pub mod portal;
pub mod components;
pub mod error_boundary;
pub mod suspense;
pub mod lazy;
pub mod error_handler;
pub mod animations;
pub mod theme;
pub mod layout;
pub mod router;
pub mod data_fetching;
pub mod persistence;
pub mod responsive;
pub mod accessibility;
pub mod forms;
pub mod i18n;

pub mod counter_app;
pub mod todo_app;
pub mod login_form;
pub mod dashboard;
pub mod settings_panel;
pub mod animation_demo;
pub mod bad_code_app;
pub mod examples;
pub mod animated_card;
pub mod test_guis;
