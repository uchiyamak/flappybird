//
//  ViewController.swift
//  FlappyBird
//
//  Created by 内山和也 on 2018/08/06.
//  Copyright © 2018年 kazuya.uchiyama. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // SKView型に変換する
        let skView = self.view as! SKView
        
        // ノードの壁を表示
        skView.showsPhysics = true
        
        // FPSを表示する　FPSは画面が１秒間に何回更新されているかを表示
        skView.showsFPS = true
        
        // ノード数を表示する　ノードは画面処理の本数？　viewと同じもの
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する      シーンは世界
        let scene = GameScene(size:skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    

}










