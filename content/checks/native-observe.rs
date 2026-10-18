//! Observe a checked type and generated host separately for documentation checks.
use ash::{
    build::{BuildConfiguration, build_prepared, prepare_program},
    driver::{RunConfiguration, compile_path},
    module::ModuleRoots,
};
use std::{env, fs, path::PathBuf, process::Command};

fn observe() -> Result<(), String> {
    let arguments: Vec<_> = env::args_os().skip(1).collect();
    if !(4..=5).contains(&arguments.len()) {
        return Err("expected library root, entry, fresh output directory, cache, [target]".into());
    }
    let library = PathBuf::from(&arguments[0]);
    let entry = PathBuf::from(&arguments[1]);
    let directory = PathBuf::from(&arguments[2]);
    fs::create_dir(&directory).map_err(|error| format!("fresh observation directory: {error}"))?;
    let roots =
        ModuleRoots::new([("ffi", library)]).map_err(|error| format!("library root: {error:?}"))?;
    let compiled = compile_path(RunConfiguration { entry, roots })
        .map_err(|error| format!("source compilation: {error:?}"))?;
    let executable = directory.join("program");
    let mut configuration = BuildConfiguration::new(executable.clone());
    configuration.cargo_target_directory = Some(PathBuf::from(&arguments[3]));
    if let Some(target) = arguments.get(4) {
        configuration.target = target.to_string_lossy().into_owned();
    }
    let prepared = prepare_program(&compiled, configuration)
        .map_err(|error| format!("native preparation: {error:?}"))?;
    build_prepared(prepared).map_err(|error| {
        let log = error
            .build_log()
            .and_then(|path| fs::read_to_string(path).ok());
        format!("native build: {error:?}\n{}", log.unwrap_or_default())
    })?;
    let output = Command::new(executable)
        .output()
        .map_err(|error| format!("native execution: {error}"))?;
    for (name, bytes) in [
        (
            "result.type",
            format!("{}\n", compiled.type_display()).into_bytes(),
        ),
        ("result.stdout", output.stdout),
        ("result.stderr", output.stderr),
        (
            "result.status",
            format!("{}\n", output.status.code().unwrap_or(-1)).into_bytes(),
        ),
    ] {
        fs::write(directory.join(name), bytes)
            .map_err(|error| format!("observation {name}: {error}"))?;
    }
    Ok(())
}

fn main() -> std::process::ExitCode {
    match observe() {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}
