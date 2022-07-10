--Paintress Goghi
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
    aux.EnablePendulumAttribute(c)

        --atk up
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(cid.atktg)
    e1:SetValue(300)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

   --extra summon
       local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_PZONE)
    e4:SetTarget(cid.target)
    e4:SetTargetRange(1,0)
    e4:SetValue(2)
    c:RegisterEffect(e4)
  
    
end

function cid.atktg(e,c)
    return not c:IsType(TYPE_EFFECT)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
    if c:IsSetCard(0xc50) or c:IsType(TYPE_NORMAL) then return false end
    return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function cid.costfilter(c)
    return  c:IsSetCard(0xc50) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_SZONE,0,1,nil) end
    local g=Duel.GetMatchingGroup(cid.costfilter,tp,LOCATION_SZONE,0,nil)
    Duel.Release(g,REASON_COST)
end

    
function cid.target(e,c)
    return c:IsSetCard(0xc50) or c:IsType(TYPE_NORMAL)
end
