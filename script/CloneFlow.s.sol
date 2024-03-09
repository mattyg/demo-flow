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
        vm.writeFile("deployments/latest/RainterpreterParserNPE2", vm.toString(address(parser)));

        RainterpreterStoreNPE2 store = new RainterpreterStoreNPE2();
        vm.writeFile("deployments/latest/RainterpreterStoreNPE2", vm.toString(address(store)));

        RainterpreterNPE2 interpreter = new RainterpreterNPE2();
        vm.writeFile("deployments/latest/RainterpreterNPE2", vm.toString(address(interpreter)));

        bytes memory constructionMeta = vm.readFileBinary("lib/rain.interpreter/meta/RainterpreterExpressionDeployerNPE2.rain.meta");
        RainterpreterExpressionDeployerNPE2 deployer = new RainterpreterExpressionDeployerNPE2(
             RainterpreterExpressionDeployerNPE2ConstructionConfig(
                address(interpreter), address(store), address(parser), constructionMeta
            )
        );
        (bytes memory bytecode, uint256[] memory constants) = parser.parse(bytes(":;"));

        EvaluableConfigV3[] memory evaluableConfig = new EvaluableConfigV3[](1);
        evaluableConfig[0] = EvaluableConfigV3(
            deployer,
            bytecode,
            constants
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
