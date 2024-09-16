const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("EscrowManagerModule", (m) => {
  const contract = m.contract("EscrowManager");

  return { contract };
});
