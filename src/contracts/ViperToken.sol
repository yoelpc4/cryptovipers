// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract ViperToken is ERC721 {
    using SafeMath for uint256;

    uint constant VARIATIONS_COUNT = 6;

    struct Viper {
        uint8 genes;
        uint256 matronId;
        uint256 sireId;
    }

    Viper[] public vipers;

    event Birth(address owner, uint256 viperId, uint256 matronId, uint256 sireId, uint8 genes);

    constructor() ERC721("Vipers", "VPR") {

    }

    receive() external payable {

    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function generateViperGenes(uint256 matron, uint256 sire) internal pure returns (uint8) {
        return uint8(matron.add(sire) % VARIATIONS_COUNT + 1);
    }

    function createViper(uint256 matron, uint256 sire, address viperOwner) internal returns (uint) {
        require(viperOwner != address(0));

        uint8 newGenes = generateViperGenes(matron, sire);

        Viper memory newViper = Viper({
        genes: newGenes,
        matronId: matron,
        sireId: sire
        });

        vipers.push(newViper);

        uint256 newViperId = vipers.length - 1;

        super._mint(viperOwner, newViperId);

        emit Birth(viperOwner, newViperId, newViper.matronId, newViper.sireId, newViper.genes);

        return newViperId;
    }

    function buyViper() external payable returns (uint256) {
        require(msg.value == 0.02 ether);

        return createViper(random() % VARIATIONS_COUNT, random() % VARIATIONS_COUNT, msg.sender);
    }

    function breedVipers(uint256 matronId, uint256 sireId) external payable returns (uint256) {
        require(msg.value == 0.05 ether);

        return createViper(matronId, sireId, msg.sender);
    }

    function getViperDetails(uint256 viperId) external view returns (uint256, uint8, uint256, uint256) {
        Viper storage viper = vipers[viperId];

        return (viperId, viper.genes, viper.matronId, viper.sireId);
    }

    function ownedVipers() external view returns(uint256[] memory) {
        uint256 viperCount = balanceOf(msg.sender);

        if (viperCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](viperCount);

            uint256 totalVipers = vipers.length;

            uint256 resultIndex = 0;

            uint256 viperId = 0;

            while (viperId < totalVipers) {
                if (ownerOf(viperId) == msg.sender) {
                    result[resultIndex] = viperId;
                }

                viperId = viperId.add(1);
            }

            return result;
        }
    }
}
