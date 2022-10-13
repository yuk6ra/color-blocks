// SPDX-License-Identifier: NOLICENSE
// CC0 NFT Project

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract ColorBlocks is ERC721URIStorage, Ownable {

    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    string public description;

    constructor() ERC721("Dot Squiggle", "DOTSQUIGGLE") {
        console.log("This is NFT");
    }

    function _random(string memory _input) internal pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(_input)));
    }


    function dataURI(uint256 tokenId) public view returns(string memory){
        string memory stringTokenId = tokenId.toString();

        string memory name = string(
            abi.encodePacked('Dot Squiggle #', stringTokenId)
        );
        
        string memory image = Base64.encode(_generateBlock(tokenId));

        return string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(abi.encodePacked(
                '{"name":"', name,
                '", "description": "', description,
                '", "image" : "data:image/svg+xml;base64,', image,
                '"}'
            )))
            )
        );
    }

    function _getNumber(uint256 seed) internal pure returns (uint256) {
        return seed / 1000;
    }

    /**
     * @notice 色の数を決める
     * @return 2～5
     */
    function _getNumberOfColors(uint256 seed) internal pure returns (uint256) {
        return uint256(seed % 4 + 2);
    }

    /**
     * @notice RGBのカラーを生み出す
     * @dev あとでRGBを16進数変換する
     */
    function _generateRGB(uint256 seed) internal pure returns (uint256[3] memory) {
        uint256[3] memory rgb;

        // ランダム
        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = seed % 256;
            seed = _getNumber(seed);
        }

        // return string(abi.encodePacked('rgb(', rgb[0].toString(), ',', rgb[1].toString(), ',', rgb[2].toString(), ')'));
        return rgb;
    } 

    function _generateColors(uint256 tokenId, uint256 seed) internal pure returns(string[5] memory) {        
        string[5] memory colors;

        for (uint256 i = 0 ; i < 5; i++) {
            uint256[3] memory rgb =  _generateRGB(seed);
            colors[i] = string(abi.encodePacked('<path fill="rgb(',rgb[0].toString(), ',', rgb[1].toString(), ',', rgb[2].toString(),')" '));
            seed = _getNumber(seed);
        }
        return colors;
    }

    function _generateGrad(uint256 seed) internal pure returns(string[5] memory) {        
        string[5] memory colors;
        uint256[3] memory end = _generateRGB(seed);
        uint256[3] memory first = _generateRGB(seed / 10000);
        
        colors[0] = string(abi.encodePacked('<path fill="rgb(',first[0].toString(), ',', first[1].toString(), ',', first[2].toString(),')" '));

        for (uint256 i = 1; i < 4; i++) {
            colors[i] = string(abi.encodePacked(
                '<path fill="rgb(',
                ((end[0] * i + (first[0] * (4 - i))) / 4).toString(), ',',
                ((end[1] * i + (first[1] * (4 - i))) / 4).toString(), ',',
                ((end[2] * i + (first[2] * (4 - i))) / 4).toString(),')" '));
        }
        colors[4] = string(abi.encodePacked('<path fill="rgb(',end[0].toString(), ',', end[1].toString(), ',', end[2].toString(),')" '));

        return colors;
    }
            

    function _generateBlock(uint256 tokenId) internal pure returns(bytes memory) {
        uint256 center = 16;
        uint256 seed = _random(tokenId.toString());
        uint256 length = 7;
        uint256 color_len = _getNumberOfColors(seed); //色の層の厚さを決める

        string[5] memory colors = _generateColors(tokenId, seed);
        // string[5] memory colors = _generateGrad(seed);

        bytes memory pack = abi.encodePacked('<svg width="1024" height="1024" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">');

        if (seed % 3 == 1) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>'
                );
        } else if (seed % 3 == 2) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>',
                colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>'
                );
        } else if (seed % 3 == 3) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>',
                colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>',
                colors[4], 'd="m16,7 3.46 2v3L16 14l-3.46-2v-3z"/>'
                );
        }
        // pack = abi.encodePacked(pack, colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>');
        // seed = _getNumber(seed);
        // pack = abi.encodePacked(pack, colors[4], 'd="m16,7 3.46 2v3L16 14l-3.46-2v-3z"/>');
        pack = abi.encodePacked(pack, '</svg>');
        // } else {
        // pack = abi.encodePacked(pack, colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>');
        // seed = _getNumber(seed);
        // pack = abi.encodePacked(pack, colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>');
        // seed = _getNumber(seed);
        // pack = abi.encodePacked(pack, colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>');
        // seed = _getNumber(seed);
        // pack = abi.encodePacked(pack, colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>');
        // seed = _getNumber(seed);
        // pack = abi.encodePacked(pack, colors[4], 'd="m16,7 3.46 2v3L16 14l-3.46-2v-3z"/>');
        // pack = abi.encodePacked(pack, '</svg>');
        // }
        return pack;
    }


    function mintNFT() public returns(uint256) {
        uint256 newItemId = _tokenIds.current() + 2000;

        console.log(dataURI(newItemId));

        _safeMint(msg.sender, newItemId);
        _tokenIds.increment();
        return newItemId;
    }

    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return dataURI(tokenId);
    }

}