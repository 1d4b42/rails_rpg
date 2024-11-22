class GameController < ApplicationController

  def index
    session[:game_end_flag] = false
    # セッションからプレイヤーと敵の状態を読み込む
    if session[:player_hp] && session[:player_mp] && session[:player_status]
      @player = Player.new(
        session[:player_name], 
        session[:player_is_bot], 
        session[:player_hp], 
        session[:player_mp], 
        session[:player_status],
        session[:player_dark_count]
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
        session[:enemy_status],
        session[:enemy_dark_count]
      )
    else
      @enemy = Player.new("Enemy", true)
    end

    @message = "ゲームを開始しましょう！\n"
  end

  def action
    if session[:game_end_flag]
      return
    end

    # セッションからプレイヤーと敵の状態を復元
    @player = Player.new(
      session[:player_name] || "Player", 
      session[:player_is_bot] || false, 
      session[:player_hp] || 300, 
      session[:player_mp] || 50, 
      session[:player_status] || "normal",
      session[:player_dark_count] || 0

    )
    
    @enemy = Player.new(
      session[:enemy_name] || "Enemy", 
      session[:enemy_is_bot] || true, 
      session[:enemy_hp] || 300, 
      session[:enemy_mp] || 50, 
      session[:enemy_status] || "normal",
      session[:enemy_dark_count] || 0
    )

    @player.turn_start
  
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
      while @action_result["attribute"] == "none"
        @action_result = @player.action(action_name)
      end
    end
    
    # 敵にダメージを与える
    @enemy.damage(@action_result["damage"], @action_result["attribute"])
    

    if action_name!="healing_mp" && action_name!="healing_hp"
      @message = "#{@player.name}が#{@enemy.name}に#{@action_result["damage"]}ダメージ(状態: #{@action_result["attribute"]})を与えた\n"
    elsif action_name=="healing_mp"
      @message = "#{@player.name}はMPを回復した! MPが#{@action_result["heal_mp"]}回復した!\n"
    elsif action_name=="healing_hp"
      @message = "#{@player.name}はHPを回復した! HPが#{@action_result["heal_hp"]}回復した!\n"
    end
    
  
    # ターン終了処理
    @player.turn_end

    # 勝敗判定
    if @player.hp <= 0
      @message = "ゲームオーバー！ 敵の勝利\n"
      session[:game_end_flag]=true
    elsif @enemy.hp <= 0
      @message = "勝利！ 敵を倒しました\n"
      session[:game_end_flag]=true
    end
  
    # セッションにプレイヤーと敵のインスタンス変数を保存
    session[:player_name] = @player.name
    session[:player_hp] = @player.hp
    session[:player_mp] = @player.mp
    session[:player_status] = @player.status
    session[:player_is_bot] = @player.is_bot
    session[:player_dark_count] = @player.dark_count
  
    session[:enemy_name] = @enemy.name
    session[:enemy_hp] = @enemy.hp
    session[:enemy_mp] = @enemy.mp
    session[:enemy_status] = @enemy.status
    session[:enemy_is_bot] = @enemy.is_bot
    session[:enemy_dark_count] = @enemy.dark_count

    action_enemy
  
    render :index
  end

  def action_enemy
    # セッションからプレイヤーと敵の状態を復元
    @player = Player.new(
      session[:player_name] || "Player", 
      session[:player_is_bot] || false, 
      session[:player_hp] || 300, 
      session[:player_mp] || 50, 
      session[:player_status] || "normal",
      session[:player_dark_count] || 0

    )
    
    @enemy = Player.new(
      session[:enemy_name] || "Enemy", 
      session[:enemy_is_bot] || true, 
      session[:enemy_hp] || 300, 
      session[:enemy_mp] || 50, 
      session[:enemy_status] || "normal",
      session[:enemy_dark_count] || 0
    )

    @enemy.turn_start

    # 敵のアクションをランダムに選択
    enemy_actions = ["punch", "kick", "fire", "blackhole", "healing_mp", "healing_hp"]
    enemy_action = enemy_actions.sample  # ランダムで選択

    # 敵のアクション実行
    @enemy_action_result = @enemy.action(enemy_action)

    # MPが足りない場合
    if @enemy_action_result["attribute"] == "none"
      while @enemy_action_result["attribute"] == "none"
        enemy_action = enemy_actions.sample  # ランダムで選択
        @enemy_action_result = @enemy.action(enemy_action)
      end
    end

    # プレイヤーに敵のダメージを与える
    if @enemy_action_result["attribute"] != "none"
      @player.damage(@enemy_action_result["damage"], @enemy_action_result["attribute"])
    end

    if enemy_action!="healing_mp" && enemy_action!="healing_hp"
      @message += "#{@enemy.name}が#{@player.name}に#{@enemy_action_result["damage"]}ダメージ(状態: #{@enemy_action_result["attribute"]})を与えた\n"
    elsif enemy_action=="healing_mp"
      @message += "#{@enemy.name}はMPを回復した! MPが#{@enemy_action_result["heal_mp"]}回復した!\n"
    elsif enemy_action=="healing_hp"
      @message += "#{@enemy.name}はHPを回復した! HPが#{@enemy_action_result["heal_hp"]}回復した!\n"
    end

    @enemy.turn_end

    # 勝敗判定
    if @player.hp <= 0
      @message = "ゲームオーバー！ 敵の勝利\n"
      session[:game_end_flag]=true
    elsif @enemy.hp <= 0
      @message = "勝利！ 敵を倒しました\n"
      session[:game_end_flag]=true
    end
  
    # セッションにプレイヤーと敵のインスタンス変数を保存
    session[:player_name] = @player.name
    session[:player_hp] = @player.hp
    session[:player_mp] = @player.mp
    session[:player_status] = @player.status
    session[:player_is_bot] = @player.is_bot
    session[:player_dark_count] = @player.dark_count
  
    session[:enemy_name] = @enemy.name
    session[:enemy_hp] = @enemy.hp
    session[:enemy_mp] = @enemy.mp
    session[:enemy_status] = @enemy.status
    session[:enemy_is_bot] = @enemy.is_bot
    session[:enemy_dark_count] = @enemy.dark_count

  end

    

  def reset
    # セッションのデータをクリアして新しいゲームを開始
    session[:player_name] = nil
    session[:player_hp] = nil
    session[:player_mp] = nil
    session[:player_status] = nil
    session[:player_is_bot] = nil
    session[:player_dark_count] = nil
  
    session[:enemy_name] = nil
    session[:enemy_hp] = nil
    session[:enemy_mp] = nil
    session[:enemy_status] = nil
    session[:enemy_is_bot] = nil
    session[:enemy_dark_count] = nil

    # ゲームをリセットして最初から
    redirect_to game_index_path
  end
end
