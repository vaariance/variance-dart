# Modular Accounts Structure

This directory contains the core module components for building with rhinestone modules. The structure is organized into several key categories to maintain clean separation of concerns and promote modular development.

## Directory Structure

```plaintext
modules/
├── executors/        # Module execution handlers
├── hooks/           # Module lifecycle and event hooks
└── validators/      # Module validation logic
```

## Components

### Validators

Located in validators/ , these components handle modules.type = validator:

- social_recovery.dart : Implements validation rules for social recovery mechanisms

### Executors

Found in executors/ , these components handle modules.type = executor:

- ownable_executor.dart : Implements ownership and permission-based execution logic

### Hooks

Stored in hooks/ , these components manage module.type = hook:

- registry_hook.dart : Allows querying of a Registry on module installation

### Fallbacks (comming soon)

## Creating New Modules

When creating a new module, consider implementing components in each of these categories as needed:

1. Validators : Implement validation logic according to the deployed contract and ensure module operations are valid
2. Executors : Define how your module's actions should be executed; define all relevant functions for interacting with the deployed module contract.
3. Hooks : Set up any necessary lifecycle events or state management if needed

## Best Practices

1. Keep each component focused on a single responsibility
2. Follow the established directory structure for consistency
3. Implement appropriate interfaces for each component type
4. Document your module's components and their interactions
5. Include proper error handling and validation

## Getting Started

To create a new module:

1. Identify which components your module needs
2. Create appropriate files in the respective directories
3. Implement the required interfaces
4. Register your module components with the system by calling `installModule` on the `SmartWallet` instance or `install` on the module.
For detailed implementation examples, refer to the existing modules in each directory.

### Module's InitData

each module must expose 2 static functions namely `getInitData` and `getAddress`. These are crucial to allow for the retrieval of the initdata and address of the module. without instantiating the module. Especially in the case where it is needed for pre-installation in the account during deployment.
Additionally a `setInitVars` function should be exposed to allow for the setting of the data needed to encode the initdata.

### Modules's ABI

add the module abi in the same folder as the module, following the naming convention `<moduleName>.abi.json`.
run the following command to generated a `<moduleName>.m.dart` contract file from the abi.

```bash
dart run build_runner build
```

each deployed module file should be used for encoding function calls to the module.
