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

    function _generateGradInitial(uint256 seed) internal pure returns (uint[3] memory, uint[3] memory) {
        uint256[3] memory first;
        uint256[3] memory end;

        // first
        for (uint256 i = 0 ; i < 3; i++) {
            first[i] = seed % 256;
            seed = _getNumber(seed);
        }
        // end
        for (uint256 i = 0 ; i < 3; i++) {
            end[i] = seed % 256;
            seed = _getNumber(seed*2);
        }

        return (first, end);
    }

    function _generateColors(uint256 seed) internal pure returns(string[5] memory) {        
        // uint256 color_len = _getNumberOfColors(seed); //色の層の厚さを決める
        uint256 color_len = 5; //色の層の厚さを決める
        uint256[3] memory first;
        uint256[3] memory end;
        // (first, end) = _generateGradInitial(seed);

        uint256[] memory r;
        uint256[] memory g;
        uint256[] memory b;

        string[5] memory colors;

        // ランダムなのか、グラデーションなのか？

        uint256 f = color_len - 1; // color_len = 4, f=3

        for (uint256 i = 0; i < f; i++) {
            if ()
            r[i] = uint256((end[0] * i + first[0] * (f - i)) / f);
            b[i] = uint256((end[1] * i + first[1] * (f - i)) / f);
            g[i] = uint256((end[2] * i + first[2] * (f - i)) / f);
        }
            
        // colors[0] = string(abi.encodePacked('<path fill="rgb(',first[0],',',first[0],',',first[0],'")'));

        for (uint256 i = 0 ; i < color_len-1; i++) {
            colors[i] = string(abi.encodePacked('<path fill="rgb(',r[i],',',g[i],',',b[i],'")'));
        }
        // colors[color_len-1] = string(abi.encodePacked('<path fill="rgb(',end[color_len-1],',',end[color_len-1],',',end[color_len-1],'") '));

        return colors;
    }
    
    function _generateBlock(uint256 tokenId) internal pure returns(bytes memory) {
        uint256 seed = _random(tokenId.toString());

        string[5] memory colors = _generateColors(seed);

        return _generateSVG(colors, seed);
    }

    /**
     * @notice SVGをつくる関数
     */
    function _generateSVG(string[5] memory colors, uint256 seed) internal pure returns (bytes memory) {
        uint256 center = 16;
        uint256 pos = 0;

        bytes memory pack = abi.encodePacked('<svg width="1024" height="1024" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">');
                
        for (uint256 i = 0; i < 5; i++){
            pos = center - i*2;
            pack = abi.encodePacked(pack, colors[i], 'd="m16,',pos.toString(),' 3.46 2v4L16 ',(pos+8).toString(),'l-3.46-2v-4z"/>');
            seed = _getNumber(seed);
        }

        pack = abi.encodePacked(pack, '</svg>');

        return pack;
    }

    function mintNFT() public returns(uint256) {
        uint256 newItemId = _tokenIds.current();

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