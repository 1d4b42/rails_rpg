class GameController < ApplicationController
  def index
    # セッションからプレイヤーと敵の状態を読み込む
    if session[:player_hp] && session[:player_mp] && session[:player_status]
      @player = Player.new(
        session[:player_name], 
        session[:player_is_bot], 
        session[:player_hp], 
        session[:player_mp], 
        session[:player_status]
      )
    else
      @player = Player.new("Player", false)
    end

    if session[:enemy_hp] && session[:enemy_mp] && session[:enemy_status]
      @enemy = Player.new(
        session[:enemy_name], 
        session[:enemy_is_bot], 
        session[:enemy_hp], 
        session[:enemy_mp], 
        session[:enemy_status]
      )
    else
      @enemy = Player.new("Enemy", true)
    end

    @message = "ゲームを開始しましょう！"
  end

  def action


    # セッションからプレイヤーと敵の状態を復元
    @player = Player.new(
      session[:player_name] || "Player", 
      session[:player_is_bot] || false, 
      session[:player_hp] || 300, 
      session[:player_mp] || 50, 
      session[:player_status] || "normal"
    )
    
    @enemy = Player.new(
      session[:enemy_name] || "Enemy", 
      session[:enemy_is_bot] || true, 
      session[:enemy_hp] || 300, 
      session[:enemy_mp] || 50, 
      session[:enemy_status] || "normal"
    )
  
    # プレイヤーのアクション名を取得
    action_name = params[:command]
  
    # アクションが無効でないか確認
    if !Player::ACTIONS.key?(action_name)
      @message = "無効なアクションです。再度選択してください。"
      render :index and return
    end
  
    # プレイヤーのアクション実行
    @action_result = @player.action(action_name)
  
    # MPが足りない場合
    if @action_result["attribute"] == "none"
      @message = "MPが不足しています。別のコマンドを選んでください。"
    else
      # 敵にダメージを与える
      @enemy.damage(@action_result["damage"], @action_result["attribute"])
    end

    @message = "#{@player.name}が#{@enemy.name}に#{@action_result["damage"]}ダメージ(状態: #{@action_result["attribute"]})を与えた"
    
  
    # ターン終了処理
    @player.turn_end
    

    # 敵のアクションをランダムに選択
    enemy_actions = ["punch", "kick", "fire", "blackhole"]
    enemy_action = enemy_actions.sample  # ランダムで選択

    # 敵のアクション実行
    @enemy_action_result = @enemy.action(enemy_action)

    # プレイヤーに敵のダメージを与える
    if @enemy_action_result["attribute"] != "none"
      @player.damage(@enemy_action_result["damage"], @enemy_action_result["attribute"])
    end

    @message = "#{@enemy.name}が#{@player.name}に#{@enemy_action_result["damage"]}ダメージ(状態: #{@enemy_action_result["attribute"]})を与えた"

    @enemy.turn_end

    # 勝敗判定
    if @player.hp <= 0
      @message = "ゲームオーバー！ 敵の勝利です。"
    elsif @enemy.hp <= 0
      @message = "勝利！ 敵を倒しました。"
    end
  
    # セッションにプレイヤーと敵のインスタンス変数を保存
    session[:player_name] = @player.name
    session[:player_hp] = @player.hp
    session[:player_mp] = @player.mp
    session[:player_status] = @player.status
    session[:player_is_bot] = @player.is_bot
  
    session[:enemy_name] = @enemy.name
    session[:enemy_hp] = @enemy.hp
    session[:enemy_mp] = @enemy.mp
    session[:enemy_status] = @enemy.status
    session[:enemy_is_bot] = @enemy.is_bot
  
    render :index
  end
  def reset
    # セッションのデータをクリアして新しいゲームを開始
    session[:player_name] = nil
    session[:player_hp] = nil
    session[:player_mp] = nil
    session[:player_status] = nil
    session[:player_is_bot] = nil
  
    session[:enemy_name] = nil
    session[:enemy_hp] = nil
    session[:enemy_mp] = nil
    session[:enemy_status] = nil
    session[:enemy_is_bot] = nil

    # ゲームをリセットして最初から
    redirect_to game_index_path
  end
end
