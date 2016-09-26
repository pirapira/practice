Script started on Mo 26 Sep 2016 13:49:09 CEST
]0;yh@sri: ~/src/practice/compare-tools/ensyh@sri:~/src/practice/compare-tools/ens$ cd ens/
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc -ver[K[K[K-version
solc, the solidity compiler commandline interface
Version: 0.4.2+commit.af6afb04.Linux.g++
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ emacs *[K& &[K[K[K([K&[K^[K$[K*.sol *[K([K&
[1] 8579
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc *.sol
HashRegistrar.sol:351:13: Error: Member "value" not found or not visible after argument-dependent lookup in function (uint256) returns () - did you forget the "payable" modifier?
            deedContract.setBalance.value(msg.value)(updatedPrice);
            ^---------------------------^
[1]+  Done                    emacs *.sol
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ emacs HashRegistrar.sol 
^C]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ emacs HashRegistrar.sol [14Psolc *.sol
Internal compiler error during compilation:
/build/solc-HZ0hws/solc-0.4.2/libsolidity/codegen/CompilerContext.cpp(76): Throw in function const dev::eth::Assembly& dev::solidity::CompilerContext::compiledContract(const dev::solidity::ContractDefinition&) const
Dynamic exception type: boost::exception_detail::clone_impl<dev::solidity::InternalCompilerError>
std::exception::what: std::exception
[dev::tag_comment*] = Compiled contract not found.
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc *.sol[K[K[K[K[K
#ENS.sol#                    FIFSRegistrar.sol            .gitignore                   HashRegistrar.sol            PublicResolver.sol           test/                        
ENS.sol                      .git                         HashRegistrarSimplified.sol  package.json                 README.md                    
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc ENS.sol
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc ENS.sol[K[K[K[K[Ks[KS.sol HashRegistrar.sol
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc ENS.sol HashRegistrar.sol PublicResolver.sol 
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ solc ENS.sol HashRegistrar.sol PublicResolver.sol HashRegistrarSimplified.sol 
Internal compiler error during compilation:
/build/solc-HZ0hws/solc-0.4.2/libsolidity/codegen/CompilerContext.cpp(76): Throw in function const dev::eth::Assembly& dev::solidity::CompilerContext::compiledContract(const dev::solidity::ContractDefinition&) const
Dynamic exception type: boost::exception_detail::clone_impl<dev::solidity::InternalCompilerError>
std::exception::what: std::exception
[dev::tag_comment*] = Compiled contract not found.
]0;yh@sri: ~/src/practice/compare-tools/ens/ensyh@sri:~/src/practice/compare-tools/ens/ens$ exit
exit

Script done on Mo 26 Sep 2016 13:52:09 CEST
