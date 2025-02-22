local logger = require("logger")

-- A pattern for sending garbage
AttackPattern =
  class(
  function(self, width, height, start, repeatDelay, attackCount, metal, chain)
    self.width = width
    self.height = height
    self.start = start
    self.attackCount = attackCount
    self.repeatDelay = repeatDelay and math.max(1, repeatDelay) or 1
    self.garbage = {width, height, metal or false, chain}
  end
)

-- An attack engine sends attacks based on a set of rules.
AttackEngine =
  class(
  function(self, target)
    self.target = target
    self.attackPatterns = {}
    self.clock = 0
  end
)

-- Adds an attack pattern that happens repeatedly on a timer.
-- width - the width of the attack
-- height - the height of the attack
-- start -- the CLOCK frame these attacks should start being sent
-- repeatDelay - the amount of time in between each attack after start
-- attackCount - the number of times to send the attack, nil for infinite
-- metal - if this is a metal block
-- chain - if this is a chain attack
function AttackEngine.addAttackPattern(self, width, height, start, repeatDelay, attackCount, metal, chain)
    local attackPattern = AttackPattern(width, height, start, repeatDelay, attackCount, metal, chain)
    self.attackPatterns[#self.attackPatterns+1] = attackPattern
end

-- 
function AttackEngine.run(self)
  local garbageToSend = {}
  for _, attackPattern in ipairs(self.attackPatterns) do
    local lastAttackTime
    if attackPattern.attackCount then
      lastAttackTime = attackPattern.start + ((attackPattern.attackCount-1) * attackPattern.repeatDelay)
    end
    if self.clock >= attackPattern.start and (attackPattern.attackCount == nil or self.clock <= lastAttackTime) then
      local difference = self.clock - attackPattern.start
      local remainder = difference % attackPattern.repeatDelay
      local origin_column = 17
      local origin_row = 11
      if remainder == 0 then
        if attackPattern.garbage[4] then
          for i = 1,  attackPattern.garbage[2], 1 do
            self.target.telegraph:push(attackPattern.garbage, origin_column, origin_row, self.target.CLOCK)
          end
          self.target.telegraph:chainingEnded(self.clock)
        else
          self.target.telegraph:push(attackPattern.garbage, origin_column, origin_row, self.target.CLOCK)
        end
      end
    end
  end

  self.clock = self.clock + 1
end
