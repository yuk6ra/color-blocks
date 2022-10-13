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

    string[] private colors;

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
    function _generateRGB(uint256 seed) internal pure returns (string memory) {
        uint256[3] memory rgb;

        // ランダム
        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = seed % 256;
            seed = _getNumber(seed);
        }

        return string(abi.encodePacked('rgb(', rgb[0].toString(), ',', rgb[1].toString(), ',', rgb[2].toString(), ')'));
    } 


    /**
     * @notice 最初だけ。
     * @dev あとでRGBを16進数変換する
     */
    function _generateFirst(uint256 seed) internal pure returns (uint[3] rgb) {
        uint256[3] memory rgb;

        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = seed % 256;
            seed = _getNumber(seed);
        }

        return rgb;
    } 

    function _gradationRGB(uint256 r, uint256 g, uint256 b) internal pure returns (uint256, uint256, uint256) {        
        uint256[3] memory rgb;
        string[5] memory colors; // 5つ揃える

        for (uint256 i = 0 ; i < 3; i++) {
            rgb[i] = seed % 256;
            seed = _getNumber(seed);
        }



        return (r, g, b);
    }

    function _gradation1(uint256 x, uint[3] memory rgb, uint256 conb, uint256 len, uint256 seed) internal pure returns (string[5] memory) {        
        string[5] memory colors; // 5つ揃える
        
        uint256[5] x = 0; //変動するカラー

        uint256 diff = _getNumber(seed) % 50; // 差分をプラスする

        for (uint256 i = 0 ; i < 5; i++) { // 層の厚さMAX回す
            x[i] = seed % 256;
            seed = _getNumber(seed);
        }



        return 
    }

    function _generateColors(uint256 tokenId, uint256 seed) internal pure returns(string[5] memory) {        
        uint256 color_conb = seed % 10; // 固定する色を決める R,G,B RG, GB, BR

        uint256 color_len = _getNumberOfColors(seed); //色の層の厚さを決める
        string[5] memory colors;

        uint256[3] init_rgb = _generateFirst(seed); //最初のカラー

        // ランダムなのか、グラデーションなのか？
        if (color_conb == 0) { // R動かす r=222, g=32, b=134
            colors = _gradationRGB(init_rgb[0], init_rgb, color_conb, color_len, seed);
        } else if (color_conb == 1) {// G動かす

        } else if (color_conb == 2) {// B動かす

        } else if (color_conb == 3) {// RG動かす

        } else if (color_conb == 4) {// GB動かす

        } else if (color_conb == 5) {// BR動かす

        } else { // ランダム

        }

        // ランダム
        if (seed % 2 == 0){
            for (uint256 i = 0 ; i < 5; i++) {
                colors[i] = string(abi.encodePacked('<path fill="', _generateRGB(seed),'" '));
                seed = _getNumber(seed);
            }
        } else {
            uint256[3] rgb = _generateFirst(seed);
            colors[0] = string(abi.encodePacked('rgb(', rgb[0].toString(), ',', rgb[1].toString(), ',', rgb[2].toString(), ')'));

            for (uint256 i = 1 ; i < 5; i++) {
                colors[i] = string(abi.encodePacked('<path fill="', _generateGrad(seed, fixed_color),'" '));
            }

        }
        return colors;
    }
    
    function _generateBlock(uint256 tokenId) internal pure returns(bytes memory) {
        uint256 center = 16;
        uint256 pos = 0;
        uint256 seed = _random(tokenId.toString());

        uint256 length = 7;

        string[5] memory colors = _generateColors(tokenId, seed);

        return _generateSVG(colors);
    }

    /**
     * @notice SVGをつくる関数
     */
    function _generateSVG(string[5] colors) internal pure returns () {
        bytes memory pack = abi.encodePacked('<svg width="1024" height="1024" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">');
                
        for (uint256 i = 0; i < length; i++){
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