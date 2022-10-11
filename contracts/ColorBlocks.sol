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

    string public description = "NFT";

    constructor() ERC721("Dot Squiggle", "DOTSQUIGGLE") {
        console.log("THis is NFT.");
    }


    function _random(uint256 _input) internal pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(_input)));
    }

    function dataURI(uint256 tokenId) public view returns(string memory){
        string memory stringTokenId = tokenId.toString();
        string memory name = string(
            abi.encodePacked('Dot Squiggle #', stringTokenId)
        );

        string memory image = Base64.encode(_generateSVG(tokenId));

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

    function _generateSVG(uint256 tokenId) internal pure returns(bytes memory){
        bytes memory image;
        uint256 seed = _random(tokenId);

        string[9] memory ao =["#0528F2", "#0540F2", "#056CF2", "#0F9BF2", "#27DEF2", "#0F9BF2", "#056CF2", "#0540F2", "#0528F2"];
        string[9] memory orange =["#FFE989", "#FFD664", "#FFBB40", "#FF9B1C", "#FF7700", "#FF9B1C", "#FFBB40", "#FFD664", "#FFE989"];
        string[9] memory rainbow =["#e60000", "#f39800", "#fff100", "#009944", "#0068b7", "#1d2088", "#920783", "#e60000", "#f39800"];
        string[9] memory dango =["#F2BDC7", "#D3D9A7", "#F2F1DF", "#F2D5A0", "#F2BFAC", "#F2BDC7", "#D3D9A7", "#F2F1DF", "#F2D5A0"];

        if (seed % 4 == 1){
            image = _generateBlock(tokenId, orange);
        } else if (seed % 4 == 2) {
            image = _generateBlock(tokenId, rainbow);
        } else if (seed % 4 == 3) {
            image = _generateBlock(tokenId, ao);
        } else {
            image = _generateBlock(tokenId, dango);
        }
        return abi.encodePacked(image);
    }

    function _generateRGB(uint256 seed) internal pure returns(string memory) {
        uint256[3] memory rgb;
        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = _random(seed) % 256;
            seed = _random(seed);
        }
        return string(abi.encodePacked('rgb(', rgb[0].toString(), ',', rgb[1].toString(), ',', rgb[2].toString(), ')'));
    }

    function _generateColor(uint256 tokenId, string[9] memory color) internal pure returns(string[7] memory){
        uint256 reset;
        uint256 length = 7;
        uint256 color_len = 9;
        uint256 color_pos;
        uint256 seed = _random(tokenId) % 9;
        string[7] memory colors;

        string memory rgb = _generateRGB(seed); // 一層目
        
        colors[0] = rgb;

        for (uint256 i=1; i < length; i++){    
            color_pos = seed + i - reset;
            
            if (color_pos < color_len){
                colors[i] = color[color_pos];                

            } else if (color_pos == color_len){
                colors[i] = color[0];
                seed = 0;
                reset = i;
            }
        }

        return colors;
    }

    function _generateBlock(uint256 tokenId, string[9] memory color) internal pure returns(bytes memory) {
        uint256 length = 7;
        uint256 center = 16;
        uint256 pos;

        string[7] memory colors = _generateColor(tokenId, color);

        bytes memory pack;

        for (uint256 i = 0; i < length; i++){
            pos = center - i*2;
            if (i==0){
                pack = abi.encodePacked('<svg width="1024" height="1024" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">');
            }
            pack = abi.encodePacked(pack, '<>'
                '<path fill="',colors[i],'" d="m16,',pos.toString(),' 3.46 2v4L16 ',(pos+8).toString(),'l-3.46-2v-4z"/>'
            );
        }
        pack = abi.encodePacked(pack, '</svg>');

        return pack;

    }


    function mintNFT() public returns(uint256) {
        uint256 newItemId = _tokenIds.current();

        console.log(dataURI(newItemId));

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, dataURI(newItemId));

        _tokenIds.increment();
        return newItemId;
    }

    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }

}