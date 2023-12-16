const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contractPath = path.resolve(__dirname, 'contracts', 'Driverchain.sol');
const buildPath = path.resolve(__dirname, 'build');

// Read the contract file
const source = fs.readFileSync(contractPath, 'utf8');

// Compile the contract
const input = {
    language: 'Solidity',
    sources: {
        'Drivechain.sol': {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input), 1));

// Delete the build directory if it exists
if (fs.existsSync(buildPath)) {
    fs.rmSync(buildPath, { recursive: true, force: true });
}

// Create the build directory
fs.mkdirSync(buildPath);

// Write the contract's ABI and bytecode to the build directory
for (let contractName in output.contracts['Drivechain.sol']) {
    fs.writeFileSync(
        path.resolve(buildPath, `${contractName}.json`),
        JSON.stringify(output.contracts['Drivechain.sol'][contractName])
    );
}