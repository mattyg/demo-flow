// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Flow} from "rain.flow/concrete/basic/Flow.sol";
import {CloneFactory} from "rain.factory/src/concrete/CloneFactory.sol";
import {EvaluableConfigV3} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {RainterpreterExpressionDeployerNPE2, RainterpreterExpressionDeployerNPE2ConstructionConfig, CONSTRUCTION_META_HASH} from "rain.interpreter/src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {RainterpreterParserNPE2} from "rain.interpreter/src/concrete/RainterpreterParserNPE2.sol";
import {RainterpreterStoreNPE2} from "rain.interpreter/src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterNPE2} from "rain.interpreter/src/concrete/RainterpreterNPE2.sol";

contract CloneFlow is Script {
    function run() public {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();

        bytes memory constructionMeta = vm.readFileBinary("lib/rain.interpreter/meta/RainterpreterExpressionDeployerNPE2.rain.meta");
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
             RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(interpreter), address(store), address(parser), constructionMeta
            )
        );

        EvaluableConfigV3[] memory evaluableConfig = new EvaluableConfigV3[](3);

        string memory depositRain = vm.readFile("rain/deposit-rain.txt");
        (bytes memory depositBytecode, uint256[] memory depositConstants) = parser.parse(bytes(depositRain));
        evaluableConfig[0] = EvaluableConfigV3(
            deployer,
            depositBytecode,
            depositConstants
        );

        string memory closeRain = vm.readFile("rain/close-rain.txt");
        (bytes memory closeBytecode, uint256[] memory closeConstants) = parser.parse(bytes(closeRain));
        evaluableConfig[1] = EvaluableConfigV3(
            deployer,
            closeBytecode,
            closeConstants
        );

        string memory claimRain = vm.readFile("rain/claim-rain.txt");
        (bytes memory claimBytecode, uint256[] memory claimConstants) = parser.parse(bytes(claimRain));
        evaluableConfig[2] = EvaluableConfigV3(
            deployer,
            claimBytecode,
            claimConstants
        );


        Flow flow = new Flow();

        CloneFactory cloneFactory = new CloneFactory();
        address flowClone = cloneFactory.clone(
            address(flow),
            abi.encode(evaluableConfig)
        );

        console2.log("clone address");
        console2.log(flowClone);
    }
}
