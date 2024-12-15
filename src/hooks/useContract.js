// src/hooks/useContract.js
import { sepolia } from 'viem/chains';
import {useReadContract, useWriteContract } from 'wagmi';
import { formatEther } from 'viem';
import React, { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';

const CONTRACT_ADDRESS = process.env.REACT_APP_CONTRACT_ADDRESS;
const ABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_nftFactoryAddress",
          "type": "address"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "inputs": [],
      "name": "EnforcedPause",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "ExpectedPause",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "OwnableInvalidOwner",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "OwnableUnauthorizedAccount",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "ReentrancyGuardReentrantCall",
      "type": "error"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "concertName",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "artistName",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "venue",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "date",
          "type": "uint256"
        }
      ],
      "name": "ConcertAdded",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        }
      ],
      "name": "ConcertCancelled",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "Paused",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "recipient",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "RefundIssued",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        }
      ],
      "name": "TicketListedForResale",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "buyer",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "_ticketClassIndex",
          "type": "uint256"
        }
      ],
      "name": "TicketPurchased",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "seller",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "buyer",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        }
      ],
      "name": "TicketResold",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "Unpaused",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "RESALE_FEE_PERCENTAGE",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "_concertIds",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_ticketClassIndex",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_quantity",
          "type": "uint256"
        }
      ],
      "name": "addCart",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_concertName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_description",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_artistName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_venue",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "_date",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_symbol",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "_startBuy",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_endBuy",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "baseIPFSHash",
          "type": "string"
        },
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "quantity",
              "type": "uint256"
            },
            {
              "internalType": "bool",
              "name": "isResellable",
              "type": "bool"
            },
            {
              "internalType": "uint256",
              "name": "maxResalePrice",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "thumbnailUrl",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "backgroundUrl",
              "type": "string"
            }
          ],
          "internalType": "struct ConcertTicketSystem.TicketClass[]",
          "name": "_ticketClasses",
          "type": "tuple[]"
        }
      ],
      "name": "addConcert",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "buyResoldTicket",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_ticketClassIndex",
          "type": "uint256"
        }
      ],
      "name": "buyTicket",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        }
      ],
      "name": "cancelConcert",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "claimRefund",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "concertCancelled",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "concertNFTs",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "concerts",
      "outputs": [
        {
          "internalType": "string",
          "name": "concertName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "description",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "artistName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "venue",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "date",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "symbol",
          "type": "string"
        },
        {
          "internalType": "bool",
          "name": "isActive",
          "type": "bool"
        },
        {
          "internalType": "uint256",
          "name": "startBuy",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "endBuy",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bool",
          "name": "isActive",
          "type": "bool"
        }
      ],
      "name": "getAllConcerts",
      "outputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "concertName",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "description",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "artistName",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "venue",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "date",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "symbol",
              "type": "string"
            },
            {
              "internalType": "bool",
              "name": "isActive",
              "type": "bool"
            },
            {
              "internalType": "uint256",
              "name": "startBuy",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "endBuy",
              "type": "uint256"
            },
            {
              "components": [
                {
                  "internalType": "string",
                  "name": "name",
                  "type": "string"
                },
                {
                  "internalType": "uint256",
                  "name": "price",
                  "type": "uint256"
                },
                {
                  "internalType": "uint256",
                  "name": "quantity",
                  "type": "uint256"
                },
                {
                  "internalType": "bool",
                  "name": "isResellable",
                  "type": "bool"
                },
                {
                  "internalType": "uint256",
                  "name": "maxResalePrice",
                  "type": "uint256"
                },
                {
                  "internalType": "string",
                  "name": "thumbnailUrl",
                  "type": "string"
                },
                {
                  "internalType": "string",
                  "name": "backgroundUrl",
                  "type": "string"
                }
              ],
              "internalType": "struct ConcertTicketSystem.TicketClass[]",
              "name": "ticketClasses",
              "type": "tuple[]"
            }
          ],
          "internalType": "struct ConcertTicketSystem.Concert[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        }
      ],
      "name": "getConcertNFT",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        }
      ],
      "name": "getConcertTicketClasses",
      "outputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "quantity",
              "type": "uint256"
            },
            {
              "internalType": "bool",
              "name": "isResellable",
              "type": "bool"
            },
            {
              "internalType": "uint256",
              "name": "maxResalePrice",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "thumbnailUrl",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "backgroundUrl",
              "type": "string"
            }
          ],
          "internalType": "struct ConcertTicketSystem.TicketClass[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "getTicketClass",
      "outputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "quantity",
              "type": "uint256"
            },
            {
              "internalType": "bool",
              "name": "isResellable",
              "type": "bool"
            },
            {
              "internalType": "uint256",
              "name": "maxResalePrice",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "thumbnailUrl",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "backgroundUrl",
              "type": "string"
            }
          ],
          "internalType": "struct ConcertTicketSystem.TicketClass",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "getTicketClassIndex",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "nftFactory",
      "outputs": [
        {
          "internalType": "contract NFTFactory",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "pause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "paused",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_price",
          "type": "uint256"
        }
      ],
      "name": "resellTicket",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "ticketDetails",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "ticketClassIndex",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "isValid",
          "type": "bool"
        },
        {
          "internalType": "uint256",
          "name": "purchaseDate",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "isUsed",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "ticketResalePrices",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "unpause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "userCarts",
      "outputs": [
        {
          "internalType": "string",
          "name": "concertName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "artistName",
          "type": "string"
        },
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "quantity",
              "type": "uint256"
            },
            {
              "internalType": "bool",
              "name": "isResellable",
              "type": "bool"
            },
            {
              "internalType": "uint256",
              "name": "maxResalePrice",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "thumbnailUrl",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "backgroundUrl",
              "type": "string"
            }
          ],
          "internalType": "struct ConcertTicketSystem.TicketClass",
          "name": "ticketClass",
          "type": "tuple"
        },
        {
          "internalType": "uint256",
          "name": "quantity",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_concertId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_attendee",
          "type": "address"
        }
      ],
      "name": "verifyTicket",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
];

export function useGetAllConcerts() {
  const { data, isLoading, error } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'getAllConcerts',
    args: [true],
    chainId: sepolia.id,
    onError: (error) => {
      console.error('Error fetching concerts:', error);
    }
  });

  return {
    concerts: data || [],
    isLoading,
    error
  };
}

export function useGetConcertDetail(concertId) {
  const { data: concertData, isLoading: isConcertLoading, error: concertError } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'concerts',
    args: [concertId],
    chainId: sepolia.id,
    watch: false,
    onError: (error) => {
      console.error('Error fetching concert:', error);
    }
  });

  const { data: ticketClasses, isLoading: isTicketClassesLoading, error: ticketClassesError } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'getConcertTicketClasses',
    args: [concertId],
    chainId: sepolia.id,
    watch: false,
    onError: (error) => {
      console.error('Error fetching ticket classes:', error);
    }
  });

  const isLoading = isConcertLoading || isTicketClassesLoading;
  const error = concertError || ticketClassesError;

  // console.log('Raw concert data:', concertData); // Debug log
  // console.log('Raw ticket classes:', ticketClasses); // Debug log

  const formattedConcert = React.useMemo(() => {
    if (!concertData || !ticketClasses) return null;
    
    return {
      id: concertId,
      name: concertData[0],
      description: concertData[1],
      artistName: concertData[2],
      venue: concertData[3],
      date: Number(concertData[4]),
      symbol: concertData.symbol || 'NFT TOKEN',
      isActive: concertData[6],
      startBuy: Number(concertData[7]),
      endBuy: Number(concertData[8]),
      ticketClasses: ticketClasses.map((ticketClass) => ({
        name: ticketClass.name,
        price: Number(ticketClass.price),
        quantity: Number(ticketClass.quantity),
        isResellable: ticketClass.isResellable,
        maxResalePrice: Number(ticketClass.maxResalePrice),
        thumbnailUrl: ticketClass.thumbnailUrl,
        backgroundUrl: ticketClass.backgroundUrl
      }))
    };
  }, [concertId, concertData, ticketClasses]);

  console.log('Formatted concert:', formattedConcert); // Debug log

  return {
    concert: formattedConcert,
    isLoading,
    error
  };
}

export function useGetTicketClasses(concertId) {
  const { data: ticketClasses, isLoading, error } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'getConcertTicketClasses',
    args: [concertId],
    chainId: sepolia.id,
  });

  console.log('Ticket classes:', ticketClasses);

  const { data: concertData } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'concerts',
    args: [concertId],
    chainId: sepolia.id,
  });

  console.log('Concert data:', concertData);

  const formattedTickets = ticketClasses && concertData ? ticketClasses.map((ticket, index) => ({
    type: ticket.name,
    price: formatEther(ticket.price),
    quantity: Number(ticket.quantity),
    isResellable: ticket.isResellable,
    maxResalePrice: formatEther(ticket.maxResalePrice),
    thumbnailUrl: ticket.thumbnailUrl,
    backgroundUrl: ticket.backgroundUrl,
    isHot: index === 1
  })) : [];

  console.log('Formatted tickets:', formattedTickets);

  const concertInfo = concertData ? {
    id: concertId,
    name: concertData[0],
    description: concertData[1],
    artistName: concertData[2],
    venue: concertData[3],
    date: Number(concertData[4]),
    symbol: concertData.symbol || 'NFT TOKEN',
    isActive: concertData[6],
    startBuy: Number(concertData[7]),
    endBuy: Number(concertData[8]),
    ticketClasses: formattedTickets
  } : null;

  return {
    tickets: formattedTickets,
    concertInfo,
    isLoading,
    error
  };
}

// useContract.js
export function useAddToCart() {
  const navigate = useNavigate();
  const { writeContract, isPending, isError } = useWriteContract({
    mutation: {
      onSuccess: (hash) => {
        // Hash adalah transaction hash yang kita dapat saat transaksi berhasil dikirim
        console.log('Transaction sent! Hash:', hash);
      },
      onSettled: async(hash, error, variables) => {
        if (error) {
          console.log('Transaction failed:', error);
        } else {
          console.log('Transaction settled! Hash:', hash);
          // Ambil concertId dari arguments yang dikirim
          const [concertId] = variables.args;
          await new Promise((resolve) => setTimeout(resolve, 5000));
          navigate(`/concert-checkout/${concertId}`);
        }
      }
    }
  });

  const addToCart = async (concertId, ticketClassIndex, quantity = 1) => {
    try {
      await writeContract({
        address: CONTRACT_ADDRESS,
        abi: ABI,
        functionName: 'addCart',
        args: [concertId, ticketClassIndex, quantity],
      });
    } catch (error) {
      console.error('Error initiating transaction:', error);
      throw error;
    }
  };

  return {
    addToCart,
    isPending,
    isError
  };
}

export function useGetCart(address, concertId) {
  const { data: cartData, isLoading, error } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ABI,
    functionName: 'userCarts',
    args: [address, concertId],
    chainId: sepolia.id,
    watch: false, // Tambahkan ini untuk mencegah polling terus-menerus
  });

  const formattedCart = useMemo(() => {
    if (!cartData) return null;
    
    return {
      concertName: cartData[0],
      artistName: cartData[1],
      ticketClass: {
        name: cartData[2].name,
        price: formatEther(cartData[2].price),
        quantity: cartData[2].quantity,
        isResellable: cartData[2].isResellable,
        maxResalePrice: formatEther(cartData[2].maxResalePrice)
      },
      quantity: Number(cartData[3])
    };
  }, [cartData]);

  return {
    cart: formattedCart,
    isLoading,
    error
  };
}

// Hook untuk membeli tiket
export function useBuyTicket() {
  const { writeContract, isError, isPending, isSuccess } = useWriteContract();

  const buyTicket = async (concertId, ticketClassIndex, totalValue) => {
    try {
      await writeContract({
        address: CONTRACT_ADDRESS,
        abi: ABI,
        functionName: 'buyTicket',
        args: [concertId, ticketClassIndex],
        value: totalValue,
      });
    } catch (error) {
      console.error('Error purchasing ticket:', error);
      throw error;
    }
  };

  return {
    buyTicket,
    isError,
    isPending,
    isSuccess
  };
}