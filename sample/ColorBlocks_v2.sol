// SPDX-License-Identifier: NOLICENSE
// CC0 NFT Project
// Using hex * 16

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

    string[] private hexColors = {
        "00", "0F", "1F", "2F", "3F", "4F", "5F", "6F", "7F", "8F", "9F"
        "AF", "BF", "CF", "DF", "EF", "FF"
    }

    string public description;

    constructor() ERC721("Dot Squiggle", "DOTSQUIGGLE") {
        console.log("This is NFT");
    }

    function _random(string memory _input) internal pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(_input)));
    }


    function dataURI(uint256 tokenId, string memory attributes) public view returns(string memory){
        string memory stringTokenId = tokenId.toString();

        string memory name = string(
            abi.encodePacked('Dot Squiggle #', stringTokenId)
        );

        string memory attributes = string(
            abi.encodePacked('[',_generateProp(),']') 
        )
        
        string memory image = Base64.encode(_generateBlock(tokenId));

        return string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(abi.encodePacked(
                '{"name":"', name,
                '", "description": "', description,
                '", "image" : "data:image/svg+xml;base64,', image,
                '", "attributes":' attributes,
                '"}'
            )))
            )
        );
    }

    function _getNumber(uint256 seed) internal pure returns (uint256) {
        return seed / 1000;
    }

    /**
     * @notice ?????????????????????
     * @return 2???5
     */
    function _getNumberOfColors(uint256 seed) internal pure returns (uint256) {
        return uint256(seed % 4 + 2);
    }

    function _getRGB(uint256 seed) internal pure returns (uint256[3] memory) {
        uint256[3] memory rgb;

        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = seed % hexColors.length;
            seed = _getNumber(seed);
        }

        return rgb;
    } 
    function _generateColors(uint256 tokenId, uint256 seed) internal pure returns(string[5] memory) {        
        string[5] memory colors;
        uint[5] memory rgbProp;
        string[5] memory hexProp;

        string[] memory parts;
        part[0] = '{"display_type": "number", "trait_type": "Color ';
        part[1] = ', "value":';
        part[2] = '}';

        // string(abi.encodePacked('{"display_type": "number", "trait_type": "Color 1 B", "value": 2}'));
        // string(abi.encodePacked('{"trait_type": "Color 1", "value": "#AAAAAA"}'));

        for (uint256 i = 0 ; i < 5; i++) {
            uint256[3] memory rgb =  _getRGB(seed);
            hexProp[i] = string(abi.encodePacked(hexColors(rgb[0]), hexColors(rgb[2]), hexColors(rgb[3])))
            
            colors[i] = string(abi.encodePacked('<path fill="#', hexProp[i],')" '));
            seed = _getNumber(seed);
        }
        return colors;
    }

    function _generateGrad(uint256 seed) internal pure returns(string[5] memory) {        
        string[5] memory colors;
        uint256[3] memory end = _generateRGB(seed);
        uint256[3] memory first = _generateRGB(seed / 10000);
        uint256[5] memory value;
        
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
        uint256 color_len = _getNumberOfColors(seed); //??????????????????????????????

        bytes memory pack = abi.encodePacked('<svg width="1024" height="1024" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">');

        string[5] memory colors = _generateColors(tokenId, seed);

        if (seed % 5 == 0) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[0], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[1], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>',
                colors[1], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>'
            );
        } else if (seed % 5 == 1) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>'
            );
        } else if (seed % 5 == 2) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>',
                colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>'
            );
        } else if (seed % 5 == 3) {
            pack = abi.encodePacked(
                pack, 
                colors[0], 'd="m16,19 3.46 2v3L16 26l-3.46-2v-3z"/>',
                colors[1], 'd="m16,16 3.46 2v3L16 23l-3.46-2v-3z"/>',
                colors[2], 'd="m16,13 3.46 2v3L16 20l-3.46-2v-3z"/>',
                colors[3], 'd="m16,10 3.46 2v3L16 17l-3.46-2v-3z"/>',
                colors[4], 'd="m16,7 3.46 2v3L16 14l-3.46-2v-3z"/>'
            );
        }
        
        pack = abi.encodePacked(pack, '</svg>');

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