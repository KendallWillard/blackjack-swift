//
//  Bank.swift
//  BlackJack
//
//  Created by James Tyner on 3/4/17.
//  Copyright © 2017 James Tyner. All rights reserved.
//
import SpriteKit
import UIKit
import Foundation
let youloseText = SKLabelNode(text: "Sorry, you are out of money. Trashcan")

class Bank {
    var balance = 500
    
    init() {
        
   }
    
    func resetBalance(){
        
        balance = 500
    }
    
    func addMoney(amount: Int){
        balance += amount
    }
    
    func subtractMoney(amount: Int){
        balance -= amount
        if(balance <= 0){
            // this is a cheap way lets see what else we can do ->resetBalance()
        }
    }
    
    func getBalance()->Int{
        return balance
    }
  }
