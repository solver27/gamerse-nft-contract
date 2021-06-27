//** Artify Migration Scrtip */
//** Author Alex Hong : Artify 2021.6 */

const Migrations = artifacts.require("Migrations");
const ArtifyNifty = artifacts.require("ArtifyNifty");
const ArtifyNftPool = artifacts.require("ArtifyNftPool");

module.exports = async function (deployer) {
  await deployer.deploy(Migrations);
  await deployer.deploy(ArtifyNifty, "Artify Nifty", "ART");
  const ArityNiftyIns = await ArtifyNifty.deployed();
  await deployer.deploy(ArtifyNftPool, ArityNiftyIns.address);
};
