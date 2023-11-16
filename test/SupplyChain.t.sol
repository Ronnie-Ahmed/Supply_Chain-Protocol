// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;
import {Test, console2} from "forge-std/Test.sol";
import {SupplyChain} from "../src/SupplyChain.sol";

contract SupplyChainTest is Test {
    SupplyChain public supplyChain;
    address contractOwner;

    function setUp() external {
        supplyChain = new SupplyChain();
        contractOwner = address(this);
    }

    function testOwner() external {
        address owner = supplyChain.checkOwner();
        assertEq(contractOwner, owner);
    }

    function testGetData() external {
        address _owner = address(10);
        address _deliveredAddress = address(13);
        uint256 _price = 123;
        string memory _productInfo = "asdasd";
        string memory location = "asdasdasd";
        string memory _OwnerNationalId = "3123123123";

        vm.startPrank(contractOwner);
        (uint256 _id, bytes32 productHash) = supplyChain.created(
            _owner,
            _price,
            _productInfo,
            location,
            _OwnerNationalId,
            _deliveredAddress
        );

        SupplyChain.Product memory product = supplyChain.getInfo(_id);
        assertEq(product.productOwner, _owner, "Owner check");
        assertEq(product._productId, _id);
        assertEq(product.price, _price * 1 ether);
        assertEq(product.productData, productHash);
        assertEq(
            product.deliveredAddress,
            _deliveredAddress,
            "Delivered address check"
        );
        supplyChain.startShipping(_id);
        vm.stopPrank();
        vm.startPrank(_deliveredAddress);
        deal(_deliveredAddress, (_price * 2) * 1 ether);
        console2.log("Balance: ", _deliveredAddress.balance);
        bool success = supplyChain.delivered{value: _price * 1 ether}(_id);
        assertEq(success, true);
    }

    function testEth() external {
        vm.startPrank(address(1));
        deal(address(1), 123);
        console2.log("Balance is : ", address(1).balance);
    }
}
