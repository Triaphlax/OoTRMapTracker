function has(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count == amount
  end
end

function has_at_least(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count >= amount
  end
end

function has_bombchus()
  if has("setting_logic_chus_yes") then
    return Tracker:ProviderCountForCode("bombchu")
  else
    return Tracker:ProviderCountForCode("bombs")
  end
end

function has_explosives()
  local bombs = Tracker:ProviderCountForCode("bombs")
  local has_bombchus = has_bombchus()
  local chus = Tracker:ProviderCountForCode("bombchu")
  if bombs > 0 then
    return bombs
  elseif has_bombchus > 0 then
    return has_bombchus
  elseif chus > 0 then
    return chus, AccessibilityLevel.SequenceBreak
  else
    return 0
  end
end

function can_blast(age)
  if not (age == "child") and has("sword2") and has("hammer") then
    return 1 
  else
    return has_explosives()
  end
end

function can_child_attack()
  if has("sling")
  or has("boomerang")
  or has("sticks")
  or has("sword1")
  or (has("dinsfire") and has("magic")) 
  then
    return 1
  else
    return has_explosives()
  end
end

function can_stun_deku()
  if has("sword2")
  or has("nuts")
  or has("shield1")
  then
    return 1
  else
    return can_child_attack()
  end
end

function can_LA()
  if has("sword2")
  and has("magic")
  and has("bow")
  and has("lightarrow")
  then
    return 1
  else
    return 0
  end
end

function has_fire()
  if has("sword2")
  and has("magic")
  and has("bow")
  and has("firearrow")
  or 
  has("dinsfire") 
  and has("magic")
  then
    return 1
  else
    return 0
  end
end

function can_see_with_lens()
  if has("setting_lens_wasteland") 
  or has("lens") 
  and has("magic") then
    return 1, AccessibilityLevel.Normal
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function has_goron_tunic()
  if has("setting_fewer_tunics_yes") 
  or has("redtunic") 
  then
    return 1
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function has_zora_tunic()
  if has("setting_fewer_tunics_yes") 
  or has("bluetunic") 
  then
    return 1
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function can_leave_forest()
  if has("open_forest")
  or has("closed_deku")
  or has("sling") and has("sword1") 
  then
    return 1
  else
    return 0
  end
end

function gerudo_bridge()
  if has("sword2", 0) then
    return 0
  elseif has("longshot")
  or has("ocarina") and has("epona")
  or has("gerudo_fortress_open")
  then
    return 1, AccessibilityLevel.Normal
  elseif has("ocarina") 
  and has("requiem") 
  then
    return 1, AccessibilityLevel.SequenceBreak
  else
    return 0
  end
end

function gerudo_card()
  if has("gerudocard")
  then
    return 1, AccessibilityLevel.Normal
  end
  return 0
  -- if has("setting_shuffle_card_yes") then
  --   return card
  -- else
  --   local level = (card and AccessibilityLevel.Normal) or AccessibilityLevel.SequenceBreak
  --   return 1, level
  -- end
end

function quicksand()
  if has("longshot")
  or has("hoverboots")
  then
    return 1, AccessibilityLevel.Normal
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function wasteland_forward()
  if has("setting_lens_chest")
  or has("lens") and has("magic")
  then
    return 1
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function wasteland_reverse()
  return 1, AccessibilityLevel.SequenceBreak
end

function wasteland()
  local count = 0
  local level = AccessibilityLevel.Normal
  
  local bridge_count, bridge_level = gerudo_bridge()
  local card_count, card_level = gerudo_card()
  local _, quicksand_level = quicksand()

  if card_count > 0 and bridge_count > 0
  then
    count = 1

    if bridge_level == AccessibilityLevel.SequenceBreak
    or card_level == AccessibilityLevel.SequenceBreak
    or quicksand_level == AccessibilityLevel.SequenceBreak
    then
      level = AccessibilityLevel.SequenceBreak
    else
      return 1, AccessibilityLevel.Normal
    end
  end

  if count == 0
  and has("ocarina")
  and has("requiem")
  then
    return wasteland_reverse()
  end

  return count, level
end

function colossus(age)
  if has("ocarina")
  and has("requiem")
  then
    return 1
  end

  if has("setting_tot_location_dc", 1)
  and has("sword2", 1)
  and not (age == "child")
  then
    return 1
  end

  if has("setting_wm_location_dc", 1)
  and access_through_mill() == 1
  and not (age == "child")
  then
    return 1
  end

  local c_sptreg, l_sptreg = colossus_through_sptreg(age)
  if l_sptreg == AccessibilityLevel.Normal then
    return 1
  end

  local c_sptmq, l_sptmq = colossus_through_sptmq(age)
  if l_sptmq == AccessibilityLevel.Normal then
    return 1
  end

  local c_fortress, l_fortress = colossus_through_fortress(age)
  if l_fortress == AccessibilityLevel.Normal then
    return 1
  end

  if c_sptreg == 1 or c_sptmq == 1 or c_fortress == 1 then
    return 1, AccessibilityLevel.SequenceBreak
  else
    return 0
  end
end

function colossus_through_sptreg(age)
  local level
  local bombcount, bomblevel = has_explosives()
  if has("spirit_reg") then
    if has("erd_spirit_c") and not (age == "adult") then
      if bombcount == 1 then
        if has_at_least("spirit_small_keys", 5) then
          if bomblevel == AccessibilityLevel.SequenceBreak then
            level = AccessibilityLevel.SequenceBreak
          else
            return 1, AccessibilityLevel.Normal
          end
        end
        if has_at_least("spirit_small_keys", 2) then
          level = AccessibilityLevel.SequenceBreak
        end
      end
    end
    if has("erd_spirit_a") and not (age == "child") then
      if has("lift2") then
        if has_at_least("spirit_small_keys", 5) then
          return 1, AccessibilityLevel.Normal
        end
        if bombcount == 1 then
          if has_at_least("spirit_small_keys", 4) and has("lift2") then
            if bomblevel == AccessibilityLevel.SequenceBreak then
              level = AccessibilityLevel.SequenceBreak
            else
              return 1, AccessibilityLevel.Normal
            end
          end
          if has_at_least("spirit_small_keys", 3) and has("longshot") then
            if bomblevel == AccessibilityLevel.SequenceBreak then
              level = AccessibilityLevel.SequenceBreak
            else
              return 1, AccessibilityLevel.Normal
            end
          end
          if has_at_least("spirit_small_keys", 2) then
            level = AccessibilityLevel.SequenceBreak
          end
        end
      end
    end
  end
  if level == AccessibilityLevel.SequenceBreak then
    return 1, level
  else
    return 0
  end
end

function colossus_through_sptmq(age)
  local level
  local lenscount, lenslevel = can_see_with_lens()
  if has("spirit_mq") then
    if has("erd_spirit_c") and not (age == "adult") then
      if has("bombchu") and has("ocarina") and has("time") then
        if has_at_least("spirit_small_keys", 7) then
          return 1, AccessibilityLevel.Normal
        end
        if has_at_least("spirit_small_keys", 3) then
          level = AccessibilityLevel.SequenceBreak
        end
      end
    end
    if has ("erd_spirit_a") and not (age == "child") then
      if has("bombchu") and has("longshot") and has("lift2") then
        if has_at_least("spirit_small_keys", 7) then
          return 1, AccessibilityLevel.Normal
        end
        if has_at_least("spirit_small_keys", 4) and has("ocarina") and has("time") then
          if lenslevel == AccessibilityLevel.Normal then
            return 1, AccessibilityLevel.Normal
          else
            level = AccessibilityLevel.SequenceBreak
          end
        end
        if has_at_least("spirit_small_keys", 1) then
          level = AccessibilityLevel.SequenceBreak
        end
      end
    end
  end
  if level == AccessibilityLevel.SequenceBreak then
    return 1, level
  else
    return 0
  end
end

function colossus_through_fortress(age)
  if has("sword2", 1) and not (age == "child") then
    local bridge = gerudo_bridge()
    if bridge == 0 then
      return 0
    end
    local card_count, card_level = gerudo_card()
    if card_count == 0 then
      return 0
    end
    level = card_level

    if has("hoverboots", 0)
    and has("longshot", 0)
    then
      level = AccessibilityLevel.SequenceBreak
    end

    if has("setting_lens_chest", 0) 
    and (has("lens", 0) 
    or has("magic", 0)) 
    then
      level = AccessibilityLevel.SequenceBreak
    end

    return 1, level
  end
end

function access_through_mill()
  if has("sword2", 1)
  and has("erg_dampe_a", 1)
  and has("ocarina", 1)
  and has("time", 1)
  then
    return 1
  end
  return 0
end

function link_the_goron()
  if has("sword2") then
    if 
    (
      has("lift1")
      or
      has("bow")
    )
    then
      return 1
    else
      return has_explosives()
    end
  end
  return 0
end

function dmc_central()
  if has("sword2") then
    if
    has("ocarina") and has("bolero")
    or
    has("hammer") and has("hoverboots")
    or
    has("setting_wm_location_dms") and access_through_mill() and has("hoverboots")
    then
      return 1
    else
      if has("hoverboots") or has("hookshot") then
        return link_the_goron()
      end
    end
  end
  return 0
end

function child_fountain()
  local level = AccessibilityLevel.Normal
  if has("king_zora_moved_yes", 0) 
  and has("open_fountain", 0) 
  then
    return 0
  end

  if has("scale1") or has("setting_lh_location_zora") then
    return 1, level
  else
    local explo_count, explo_level = has_explosives()
    if explo_count == 0 then
      return 0
    else
      if explo_level == AccessibilityLevel.SequenceBreak then
        level = AccessibilityLevel.SequenceBreak
      end
      
      if has("ocarina", 0)
      or has("lullaby", 0)
      then
        level = AccessibilityLevel.SequenceBreak
      end
      return 1, level
    end
  end
end

function adult_fountain()
  if has("sword2", 0) then
    return 0
  end

  if has("setting_wm_location_foun", 1)
  and access_through_mill()
  then
    return 1
  end

  local level = AccessibilityLevel.Normal
  if has("setting_tot_location_zora", 0) then
    if has("ocarina", 0)
    or has("lullaby", 0)
    then
      if has("hoverboots", 0) then
        return 0
      else
        level = AccessibilityLevel.SequenceBreak
      end
    end
  end

  if has("open_fountain") then
    return 1, level
  end

  local child_count, child_level = child_fountain()
  if child_count > 0 then
    if child_level == AccessibilityLevel.SequenceBreak then
      level = AccessibilityLevel.SequenceBreak
    end
    return 1, level
  end
  return 0
end

function rainbow_bridge()
  if has("sword2", 0) then
    return 0
  elseif has("bridge_open", 1)
  or (has("bridge_vanilla", 1) and has("lacs_meds", 2) and has("lightarrow", 1))
  or (has("bridge_stones", 1) and has("stones", 3))
  or (has("bridge_medallions", 1) and medallions())
  or (has("bridge_dungeons", 1) and medallions() and has("stones", 3))
  or (has("bridge_100gs", 1) and has("token", 100))
  then
    return 1
  end
  return 0
end

function medallions()
  if has("forestmed", 1) and has("noct_meds:2", 1) and has("lacs_meds", 2) and has("lightmed", 1) then
    return 1
  end
  return 0
end

function has_bottle()
  local bottles = Tracker:ProviderCountForCode("bottle")
  local ruto = Tracker:ProviderCountForCode("ruto")
  local bigpoe = Tracker:ProviderCountForCode("bigpoe")
  local kz_count, kz_level = child_fountain()
  local level = AccessibilityLevel.Normal
  
  local usable_bottles = bottles - ruto - bigpoe

  if has("sword2") then
    usable_bottles = usable_bottles + bigpoe
  end

  if kz_count > 0
  and ruto > 0 then
    if usable_bottles == 0 then  
      level = kz_level
    end
    usable_bottles = usable_bottles + ruto
  end
  
  return usable_bottles, level
end

function has_projectile(age)
  local explo = has_explosives() > 0
  local sling = has("sling")
  local rang = has("boomerang")
  local bow = has("bow")
  local hook = has("hookshot")

  if age == "child" then
    return explo or sling or rang
  elseif age == "adult" then
    return explo or bow or hook
  elseif age == "both" then
    return explo or (bow or hook) and (sling or rang)
  else
    return explo or (bow or hook) or (sling or rang)
  end
end

function spirit_wall()
  if has("longshot")
  or 
  has("bombchu")
  or 
  (
    (
      has("bombs")
      or 
      has("nuts")
      or 
      (
        has("dinsfire")
        and 
        has("magic")
      )
    )
    and 
    (
      has("bow")
      or 
      has("hookshot")
      or 
      has("hammer")
    )
  )
  then
    return 1
  else
    return 1, AccessibilityLevel.SequenceBreak
  end
end

function hintable()
  if 
  has("setting_hints_on")
  or
  has("setting_hints_truth") and has("maskoftruth")
  or
  has("setting_hints_agony") and has("agony")
  then
    return 1
  else
    return 0
  end
end