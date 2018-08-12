//
//  GameScene.swift
//  FlappyBird
//
//  Created by 内山和也 on 2018/08/06.
//  Copyright © 2018年 kazuya.uchiyama. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {      //クラス＝画面、という認識で良い？
    
    var scrollNode:SKNode!
    var wallNode:SKNode!        //viewみたいなもの　属性を持っていない
    var bird:SKSpriteNode!      //SKNodeとSKSpriteNodeの違いは？動きがあるかないか？かな？　スプライトは画面を効率よく表示させる
    var itemNode:SKNode!
    var audioPlayer:AVAudioPlayer!  //音を入れるインスタンス
    
    //衝突判定カテゴリー             //そういえばこれってどこで使ったの？？
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let pointCategory: UInt32 = 1 << 4

    //スコア
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard   //スコア保存用？　別のUserDefaultsを作るとどうなる？
    //let pointUserDefaults:UserDefaults = UserDefaults.standard   //ポイント保存用

    //アイテムポイント
    var point = 0
    var pointLabelNode:SKLabelNode!
    var bestPointLabelNode:SKLabelNode!
    
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(red:0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード     親ノードって何？
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //アイテム用のノード
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        
        //ラベル表示用
        setupScoreLabel()
        
    }
    
    func setupGround() {
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground") //imageとimagenamedの違いは？
        groundTexture.filteringMode = .nearest      //多少画質が荒くても処理速度を高める設定。linearで画質優先
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2  // sizeとsize()の違いは？　仕様の違い　メソッドなのか変数なのかの違い　変数の場合の方が多い
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロール　→元の位置　→左にスクロールと無限に切り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {               //このfor文の意味がよくわからない　needNumberは何を計算しているの？
             //テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトを表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),     //CGFloatってなに？　型
                y: groundTexture.size().height * 0.5
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設置する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚文スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)

        //左にスクロール　→元の位置　→左にスクロールと無限に切り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 //一番後ろにくる
            
            //スプライトを表示する位置を指定
            sprite.position = CGPoint(
                x: cloudTexture.size().width * (CGFloat(i) + 0.5),
                y: self.size.height - cloudTexture.size().height * 0.5
            )
            
            //スプライトにアニメーションを設定
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加
            scrollNode.addChild(sprite)
        }
    }
    
    //アイテムを表示する
    func setupItem() {
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + (itemTexture.size().width * 2))    // x2しないと足りないのはなぜ？
        
        //画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 8.0)

        //自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()        //これは戻すんじゃなくて消すの？
        
        //2つのアニメーションを順に実行するアクションを作成     リピートじゃなくて順に実行？
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        //itemを生成するアクションを作成
        let createItemAnimation = SKAction.run({
            
            //itemを乗せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width, y: 0.0)
            item.zPosition = 0
            
            //アイテムを表示させる高さの下限値
            let under_item_lowest_y = UInt32(self.frame.height / 4)
            //壁のy軸を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.height / 2
            //ランダムな高さを生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して下の壁のY座標を決定
            let under_item_y = CGFloat(under_item_lowest_y + random_y)
            
            //アイテムを作成
            let showItem = SKSpriteNode(texture: itemTexture)
            showItem.position = CGPoint(x: 0.0, y: under_item_y)
            
            //ここに物理演算を記述
            //物理演算を設定
            showItem.physicsBody = SKPhysicsBody(circleOfRadius: showItem.size.height / 2.0)
            //衝突した時に回転させないようにする
            showItem.physicsBody?.allowsRotation = false
            showItem.physicsBody?.isDynamic = false
            showItem.physicsBody?.categoryBitMask = self.pointCategory
            showItem.physicsBody?.contactTestBitMask = self.birdCategory

            item.addChild(showItem)
            
            item.run(itemAnimation)
            self.itemNode.addChild(item)
            //print("testtesttest")

        })
        
        //次の壁作成までの待ち時間のアクション作成
        let waitAnimation = SKAction.wait(forDuration: 1)
        
        //壁を作成　→待ち時間　→壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        itemNode.run(repeatForeverAnimation)

    }
    
    //壁を追加する
    func setupWall() {
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()        //これは戻すんじゃなくて消すの？
        
        //2つのアニメーションを順に実行するアクションを作成     リピートじゃなくて順に実行？
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({    //定数の中に定数を記述・・・？　これは変数。関数を値として持っている。
            //壁関連のノードを載せるのーどを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            //壁のy軸を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.height / 4
            //下の壁のy軸の下限     UInt32とは？
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2 )       //なんでこうなる？
            //1~random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 4
            
            //下の壁を作成
            let under = SKSpriteNode(texture: wallTexture)  //ここで画像を持ったスプライトノードを作っている
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            
            //スプライトに物理演算を設定する      この位置にしなければいけないのはなんで？
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を設定する      この位置にしなければいけないのはなんで？
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false

            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2)      //どこの位置を指している？
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
        })
        
        //次の壁作成までの待ち時間のアクション作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成　→待ち時間　→壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // ２種類のテクスチャを交互に表示させるアニメーションを作成
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame:0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させないようにする
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory        //バードカテゴリーだけは位置指定しなくても重なってる？＊＊＊
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory      //跳ね返る動作の設定
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | pointCategory    //これは？　didbeginを呼ぶ
        
        //アニメーション設定
        bird.run(flap)
        
        //スプライトを追加
        addChild(bird)
        
    }
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            //鳥の速度を０にする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }
    
    // SKPhisicsContactDelegateのメソッド　衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {            //衝突した時に、はSKPhysicsContactで指定してる？
        //ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        print("score:\(scoreCategory)")
        print("point:\(pointCategory)")
        print("contact:\(contact.bodyA.categoryBitMask & scoreCategory)")
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコアようの物体と衝突した     bodyA, bodyBって何？    単純に、 == じゃダメなの？＊＊＊
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"      //ここも記述統一した方が良くない？
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")    //BESTという名前でどっかに保存？KEYを指定する理由は？bestScoreっていう変数名で保存すればいい気がするけど
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()      //すぐに保存するためらしい
            }
        } else if (contact.bodyA.categoryBitMask & pointCategory) == pointCategory || (contact.bodyB.categoryBitMask & pointCategory) == pointCategory {
            
            //効果音再生
            playSound(name: "sound1")       //再生するタイミングで一瞬止まる。重い。＊＊＊
            
            //pointup用の物体と衝突した
            print("PointUp")
            point += 1
            pointLabelNode.text = "Point:\(point)"
                
            //ベストスコア更新か確認する
            var bestPoint = userDefaults.integer(forKey: "ITEM")
            if point > bestPoint {
                bestPoint = point
                bestPointLabelNode.text = "Best Point:\(bestPoint)"
                userDefaults.set(bestPoint, forKey: "ITEM")
                userDefaults.synchronize()
            }
            //アイテムを消す
            contact.bodyB.node?.removeFromParent()
            //itemNode.removeFromParent()
            print("アイテム衝突確認")
            
       } else {
            //壁か地面と衝突
            print("GameOver")
            //スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory     //?がついてる時とついてない時の違いは？
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)       //鳥をひっくり返す計算。中身を理解したい
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    //音声を再生する関数
    func playSound(name: String) {
        guard let soundFilePath = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        let sound:URL = URL(fileURLWithPath: soundFilePath)
        audioPlayer = try! AVAudioPlayer(contentsOf: sound, fileTypeHint: nil)
        audioPlayer.play()

    }
    
    //リスタートの関数
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        point = 0
        pointLabelNode.text = String("Point:\(point)")

        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)    //初期位置はsetupBirdと共通化した方がいいんじゃ？
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        itemNode.removeAllChildren()

        bird.speed = 1
        scrollNode.speed = 1
    }
    
    //スコア表示用
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x:10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")    //ここでBESTを取り出してる？
        bestScoreLabelNode.text = "BEST Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        //ポイント表示用
        point = 0
        pointLabelNode = SKLabelNode()
        pointLabelNode.fontColor = UIColor.black
        pointLabelNode.position = CGPoint(x:10, y: self.frame.size.height - 120)
        pointLabelNode.zPosition = 100
        pointLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        pointLabelNode.text = "Point:\(point)"
        self.addChild(pointLabelNode)
        
        bestPointLabelNode = SKLabelNode()
        bestPointLabelNode.fontColor = UIColor.black
        bestPointLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
        bestPointLabelNode.zPosition = 100
        bestPointLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestPoint = userDefaults.integer(forKey: "ITEM")
        bestPointLabelNode.text = "BEST Point:\(bestPoint)"
        self.addChild(bestPointLabelNode)

    }


}









