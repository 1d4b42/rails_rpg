class Player
  attr_accessor :name, :hp, :mp, :status, :is_bot

  ACTIONS = {
    "punch" => { "attribute" => "normal", "damage" => 10, "cost" => 0 },
    "kick" => { "attribute" => "normal", "damage" => 20, "cost" => 5 },
    "fire" => { "attribute" => "fire", "damage" => 20, "cost" => 10 },
    "blackhole" => { "attribute" => "dark", "damage" => 0, "cost" => 20 },
    "insufficient_mp" => { "attribute" => "none", "damage" => 0, "cost" => 0 }
  }

  def initialize(name = "noname", is_bot = false, hp = 300, mp = 50, status = "normal")
    @name = name
    @hp = hp
    @mp = mp
    @status = status
    @is_bot = is_bot
  end

  def damage(damage, status)
    @hp -= damage
    if @status == "normal"
      @status = status
    elsif @status == "fire" && status != "normal" && status != "none"
      @status = status
    end
  end

  def action(action_name)
    act = ACTIONS[action_name]
    if @mp < act["cost"]
      return ACTIONS["insufficient_mp"]
    else
      @mp -= act["cost"]
      return act
    end
  end

  def turn_end
    case @status
    when "fire"
      @hp -= 10
    when "dark"
      rate = rand(1..100)
      @hp = 0 if rate >= 99
    end
  end
end
