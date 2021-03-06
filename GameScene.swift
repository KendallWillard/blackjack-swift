import SpriteKit
import GameplayKit

var busted = false;
class GameScene: SKScene {
    let moneyContainer = SKSpriteNode(color: .clear, size: CGSize(width:250, height: 150))
    let dealBtn = SKSpriteNode(imageNamed: "deal_btn")
    let hitBtn = SKSpriteNode(imageNamed: "hit_btn")
    let standBtn = SKSpriteNode(imageNamed: "stand_btn")
    let doubleBtn = SKSpriteNode(imageNamed: "doubleDown_btn")
    let money10 = Money(moneyValue: .ten)
    let money25 = Money(moneyValue: .twentyFive)
    let money50 = Money(moneyValue: .fifty)
    let pot = Pot()
    let player1 = Player(hand: Hand(), bank: Bank())
    let dealer = Dealer(hand: Hand())
    var allCards = [Card]()
    let dealerCardsY = 930 // y position of dealer cards
    let playerCardsY = 200 // y position of player cards
    var currentPlayerType: GenericPlayer = Player(hand: Hand(), bank: Bank())
    let deck = Deck()
    var playerBalance: SKLabelNode!
    var score = 0 {
        didSet {
            playerBalance.text = "balance: \(player1.bank.getBalance())"
            print("bal", player1.bank.getBalance())
        }
    }
    let instructionText = SKLabelNode(text: "Place your bet")
    let playerBusted = SKLabelNode(text: "Sorry, you are out of money, trashcan")
    override func didMove(to view: SKView) {
        setupTable()
        setupMoney()
        setupButtons()
        setupLabels()
        currentPlayerType = player1
    }
    func setupTable(){
        let table = SKSpriteNode(imageNamed: "table")
        addChild(table)
        table.position = CGPoint(x: size.width/2, y: size.height/2)
        table.zPosition = -1
        addChild(moneyContainer)
        moneyContainer.anchorPoint = CGPoint(x:0, y:0)
        moneyContainer.position = CGPoint(x:size.width/2 - 125, y:size.height/2)
        instructionText.fontColor = UIColor.black
        addChild(instructionText)
        instructionText.position = CGPoint(x: size.width/2, y: 200)
        deck.new()
    }
    
    func setupMoney(){
        addChild(money10)
        money10.position = CGPoint(x:200, y: 40)
        
        addChild(money25)
        money25.position = CGPoint(x:250, y:40)
        
        addChild(money50)
        money50.position = CGPoint(x:300, y:40)
    }
    
    func setupLabels(){
        playerBalance = SKLabelNode(fontNamed: "Chalkduster")
        playerBalance.text = "Balance: \(player1.bank.getBalance())"
        playerBalance.horizontalAlignmentMode = .right
        playerBalance.position = CGPoint(x:600, y: 90)
        addChild(playerBalance)
    }
    
    
    func setupButtons(){
        dealBtn.name = "dealBtn"
        addChild(dealBtn)
        dealBtn.position = CGPoint(x:400, y:40)
        
        hitBtn.name = "hitBtn"
        addChild(hitBtn)
        hitBtn.position = CGPoint(x:350, y:40)
        hitBtn.isHidden = true
        
        standBtn.name = "standBtn"
        addChild(standBtn)
        standBtn.position = CGPoint(x:500, y:40)
        standBtn.isHidden = true
        
        doubleBtn.name = "doubleBtn"
        addChild(doubleBtn)
        doubleBtn.setScale(0.22)
        doubleBtn.position = CGPoint(x:200, y:40)
        doubleBtn.isHidden = true
        
        
        
        
        
//        playerBalance.name = "The number is \(player1.bank.getBalance())"
//        addChild(playerBalance)
//        playerBalance.position = CGPoint(x:400, y:40)
//        playerBalance.isHidden = false;
//        print("balance", player1.bank.getBalance())
//        playerBalance.name = String (player1.bank.getBalance())
//        addChild(playerBalance)
//        playerBalance.position = CGPoint(x:400, y:40)
//        playerBalance.isHidden = false
        
        
        
    }
    
    
    func bet(betAmount: MoneyValue ) {
        print("player money", player1.bank.getBalance())
        if(betAmount.rawValue > player1.bank.getBalance()) {
            print("Trying to bet more than you have. Go to the bank of Willard to pay debts")
            return
        }else {
            pot.addMoney(amount: betAmount.rawValue)
            print("pot money", pot.getMoney())

            //remove players money from balance when making a bet
            player1.bank.subtractMoney(amount: betAmount.rawValue)
            playerBalance.text = "Balance    : \(player1.bank.getBalance())"
            let tempMoney = Money(moneyValue: betAmount)
            tempMoney.anchorPoint = CGPoint(x:0, y:0)
            moneyContainer.addChild(tempMoney)
            tempMoney.position = CGPoint(x:CGFloat(arc4random_uniform(UInt32(moneyContainer.size.width - tempMoney.size.width))), y:CGFloat(arc4random_uniform(UInt32(moneyContainer.size.height - tempMoney.size.height))))
            dealBtn.isHidden = false;
        }
    }
    
    func deal() {
        instructionText.text = "Dealing..."
        money10.isHidden = true;
        money25.isHidden = true;
        money50.isHidden = true;
        dealBtn.isHidden = true;
        standBtn.isHidden = false;
        hitBtn.isHidden = false;
        doubleBtn.isHidden = false;
        let tempCard = Card(suit: "card_front", value: 0)
        tempCard.position = CGPoint(x:400, y:700)
        addChild(tempCard)
        tempCard.zPosition = 50
             
        let newCard = deck.getTopCard()
        var whichPosition = playerCardsY
        var whichHand = player1.hand
        if(self.currentPlayerType is Player){
            whichHand = player1.hand
            whichPosition = playerCardsY;
        } else {
            whichHand = dealer.hand
            whichPosition = dealerCardsY;
        }
             
        whichHand.addCard(card: newCard)
        print("new card")
        let xPos = 250 + (whichHand.getLength()*35)
        let moveCard = SKAction.move(to: CGPoint(x:xPos, y: whichPosition),duration: 0.5)
        tempCard.run(moveCard, completion: { [unowned self] in
        self.player1.setCanBet(canBet: true)
            print("past turnover")
            
            
        if(self.currentPlayerType is Dealer && self.dealer.hand.getLength() == 1){
            self.dealer.setFirstCard(card: newCard)
            self.allCards.append(tempCard)
            tempCard.zPosition = 0
        } else {
            tempCard.removeFromParent()
            self.allCards.append(newCard)
            self.addChild(newCard)
            newCard.position = CGPoint( x: xPos, y: whichPosition)
            newCard.zPosition = 100
        }
        if(self.dealer.hand.getLength() < 2){ 
            if(self.currentPlayerType is Player){
                self.currentPlayerType = self.dealer
            }else{
                self.currentPlayerType = self.player1
            }
            self.deal()
        }else if (self.dealer.hand.getLength() == 2 && self.player1.hand.getLength() == 2) {
            if(self.player1.hand.getValue() == 21 || self.dealer.hand.getValue() == 21){
                self.doGameOver(hasBlackJack: true)
            } else {
                self.standBtn.isHidden = false;
                self.hitBtn.isHidden = false;
                self.doubleBtn.isHidden = false;

            }
        }
                 
        if(self.dealer.hand.getLength() >= 3 && self.dealer.hand.getValue() < 17){
            self.deal();
        } else if(self.player1.isYeilding() && self.dealer.hand.getValue() >= 17){
            self.standBtn.isHidden = true
            self.hitBtn.isHidden = true
            self.doGameOver(hasBlackJack: false)
        }
        if(self.player1.hand.getValue() > 21){ // player busts
            self.standBtn.isHidden = true;
            self.hitBtn.isHidden = true;
            self.doubleBtn.isHidden = true;
            self.doGameOver(hasBlackJack: false);
        }
                 
        })
    }
    
        func doGameOver(hasBlackJack: Bool){
            hitBtn.isHidden = true
            standBtn.isHidden = true
            let tempCardX = allCards[1].position.x
            let tempCardY = allCards[1].position.y
            let tempCard = dealer.getFirstCard()
            addChild(tempCard)
            allCards.append(tempCard)
            tempCard.position = CGPoint(x:tempCardX,y:tempCardY)
            tempCard.zPosition = 0
            var winner:GenericPlayer = player1
                 
            if(hasBlackJack){
                if(player1.hand.getValue() > dealer.hand.getValue()){
                    //Add to players Bank Here (pot value * 1.5)
                    player1.bank.addMoney(amount: pot.getMoney() * 3)
                    instructionText.text = "You Got BlackJack!";
                    playerBalance.text = "Balance: \(player1.bank.getBalance())" //update balance
                    moveMoneyContainer(position: playerCardsY)
                }else{
                    //Subtract from players bank here
                    player1.bank.subtractMoney(amount: pot.getMoney())
                    instructionText.text = "Dealer got BlackJack!";
                    moveMoneyContainer(position: dealerCardsY)
                }
                return
            }
                 
            if (player1.hand.getValue() > 21){
                instructionText.text = "You Busted!"
                //subtract money. Player loses
                playerBalance.text = "Balance: \(player1.bank.getBalance())" //update balance
                winner = dealer
            }else if (dealer.hand.getValue() > 21){
                //Add to players bank
                player1.bank.addMoney(amount: pot.getMoney() * 2)
                playerBalance.text = "Balance: \(player1.bank.getBalance())" // update balance
                instructionText.text = "Dealer Busts. You Win!"
                winner = player1
            }else if (dealer.hand.getValue() > player1.hand.getValue()){
                //Subtract from players bank
                playerBalance.text = "Balance: \(player1.bank.getBalance())" // update balance
                instructionText.text = "You Lose!"
                winner = dealer
            }else if (dealer.hand.getValue() == player1.hand.getValue()){
                 //add from players bank
                player1.bank.addMoney(amount: pot.getMoney())
                playerBalance.text = "Balance: \(player1.bank.getBalance())" // update balance
                instructionText.text = "Push!"
                winner = player1
            }else if (dealer.hand.getValue() < player1.hand.getValue()){
                //Add to players bank
                player1.bank.addMoney(amount: pot.getMoney() * 2)
                playerBalance.text = "Balance: \(player1.bank.getBalance())" // update balance
                instructionText.text="You Win!";
                winner = player1
            }
                 
            if(winner is Player){
                moveMoneyContainer(position: playerCardsY)
            }else{
                moveMoneyContainer(position: dealerCardsY)
            }
            pot.reset()
        }
    
    func moveMoneyContainer(position: Int){
        let moveMoneyContainer = SKAction.moveTo(y: CGFloat(position), duration: 3.0)
        moneyContainer.run(moveMoneyContainer, completion: { [unowned self] in
                self.resetMoneyContainer()
        });
    }
    
    func resetMoneyContainer(){
        moneyContainer.removeAllChildren()
        moneyContainer.position.y = size.height/2
        newGame()
    }
    
    func newGame(){
    currentPlayerType = player1
    deck.new()
    instructionText.text = "PLACE YOUR BET";
    money10.isHidden = false;
    money25.isHidden = false;
    money50.isHidden = false;
    dealBtn.isHidden = false
    player1.hand.reset()
    dealer.hand.reset()
    player1.setYielding(yields: false)
         
    for card in allCards{
        card.removeFromParent()
    }
    allCards.removeAll()
    }
    func hit(){
        if(player1.getCanBet()){
            currentPlayerType = player1
            deal()
            player1.setCanBet(canBet: false)
        }
    }
    
    func doubleDown(){
        var winner:GenericPlayer = player1
        player1.bank.subtractMoney(amount: pot.getMoney())
        pot.addMoney(amount: pot.getMoney())
        let tempCard = Card(suit: "card_front", value: 0)
        tempCard.position = CGPoint(x:400, y:700)
        addChild(tempCard)
        tempCard.zPosition = 50
        let newCard = deck.getTopCard()
        print("top card", deck.getTopCard())
        let whichPosition = playerCardsY
        let whichHand = player1.hand
        whichHand.addCard(card: newCard)
        print("new card")
        let xPos = 250 + (whichHand.getLength()*35)
        let moveCard = SKAction.move(to: CGPoint(x:xPos, y: whichPosition),duration: 0.5)
        tempCard.run(moveCard, completion: { [unowned self] in
        self.player1.setCanBet(canBet: true)
        })
        
        print("player hand: ", player1.hand)
        if(player1.hand.getValue() > 21 ) {
            playerBalance.text = "Balance: \(player1.bank.getBalance())" //update balance
            winner = dealer
        }
        else {
        stand()

        }
    }
     
    func stand(){
        player1.setYielding(yields: true)
        standBtn.isHidden = true
        hitBtn.isHidden = true
        if(dealer.hand.getValue() < 17){
            currentPlayerType = dealer
            deal();
        }else{
            doGameOver(hasBlackJack: false)
        }
    }
    
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       guard let touch = touches.first else {
           return
       }
            
       let touchLocation = touch.location(in: self)
       let touchedNode = self.atPoint(touchLocation)
            
       if(touchedNode.name == "money"){
           let money = touchedNode as! Money
           bet(betAmount: money.getValue())
       }
            
       if(touchedNode.name == "dealBtn"){
           deal()
       }
            
       if(touchedNode.name == "hitBtn"){
           hit()
       }
        
    if(touchedNode.name == "doubleBtn"){
        print("yo")
        doubleDown()
    }
    
       if(touchedNode.name == "standBtn"){
           stand()
       }
   }
}
