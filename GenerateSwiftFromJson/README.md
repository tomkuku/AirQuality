This **Swift** script utilizes **Stencil** templates to generate **Swift** code from **JSON** input files.

### Compilation

Call in terminal:
```
swift build
```

Next, execute: 
```
cp GenerateSwiftFromJson/.build/arm64-apple-macosx/release/GenerateSwiftFromJson GenerateSwiftFromJson/run
```
`run` is a binary, executable file. This file should be tracked by git to use it in CI pipeline which make it faster by skipping unnecessary compilation each time.

### Execution

```
GenerateSwiftFromJson/run \
    --json-input <json-input-file> \
    --stencil-template <stencil-file> \
    --swift-output <swift-output-file>
```
