class Player
  attr_accessor :name, :hp, :mp, :status, :is_bot, :dark_count, :max_hp, :max_mp


  ACTIONS = {
    "punch" => { "attribute" => "normal", "damage" => 10, "heal_hp" => 0, "heal_mp" => 0, "cost" => 0 },
    "kick" => { "attribute" => "normal", "damage" => 20, "heal_hp" => 0, "heal_mp" => 0, "cost" => 5 },
    "fire" => { "attribute" => "fire", "damage" => 20, "heal_hp" => 0, "heal_mp" => 0, "cost" => 10 },
    "blackhole" => { "attribute" => "dark", "damage" => 0, "heal_hp" => 0, "heal_mp" => 0, "cost" => 20 },
    "insufficient_mp" => { "attribute" => "none", "damage" => 0, "heal_hp" => 0, "heal_mp" => 0, "cost" => 0 },
    "healing_mp" => { "attribute" => "normal", "damage" => 0, "heal_hp" => 0, "heal_mp" => 20, "cost" => 0 },
    "healing_hp" => { "attribute" => "normal", "damage" => 0, "heal_hp" => 50, "heal_mp" => 0, "cost" => 0 },
  }

  def initialize(name = "noname", is_bot = false, hp = 300, mp = 50, status = "normal", dark_count = 0)
    @name = name
    @hp = hp
    @mp = mp
    @status = status
    @is_bot = is_bot
    @dark_count = dark_count
    @max_hp = 300
    @max_mp = 50
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
    if action_name=="healing_mp"
      @mp = @mp + act["heal_mp"]
      @mp=100 if @mp>=100
    elsif action_name=="healing_hp"
      @hp = @hp + act["heal_hp"]
      @hp=300 if @hp>=300
    end
    
    if @mp < act["cost"]
      return ACTIONS["insufficient_mp"]
    else
      @mp -= act["cost"]
      return act
    end
    
  end
  def turn_start
    if @dark_count>=5
      @status = "normal"
      @dark_count = 0
    end
  end


  def turn_end
    case @status
    when "fire"
      @hp -= 10
    when "dark"
      rate = rand(1..100)
      @hp = 0 if rate >= 99
      @dark_count = @dark_count + 1
    end
    if @hp<0
      @hp=0
    end
  end
end
