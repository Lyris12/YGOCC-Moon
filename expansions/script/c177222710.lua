--Ancient Princess Warrior, Balancea
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,aux.FilterBoolFunctionEx(s.matcheck),4,2)
    c:EnableReviveLimit()
    --If your opponent controls 2 Neutral monsters with the same Level, you can also Xyz Summon this card using those monsters as material.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.xyzcon)
    e1:SetTarget(s.xyztg)
    e1:SetOperation(s.xyzop)
    e1:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e1)
    --Neutral monsters your opponent controls cannot attack this card.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atklimit)
    c:RegisterEffect(e2)
    --If this card is targeted for an attack by a Positive or Negative monster: you can detach 1 Material from this card; negate the attack, and if you do, inflict damage to your opponent equal to that monster's ATK/DEF (whichever is higher).
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.matcheck(c)
	return c:IsPositive() or c:IsNegative()
end

function s.xyzfilter(c,tp)
    return c:IsFaceup() and c:IsNeutral() and c:IsControler(1-tp) and c:IsCanBeXyzMaterial(nil,tp) and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,0,LOCATION_MZONE,1,c,tp,c:GetLevel())
end

function s.xyzfilter2(c,tp,level)
    return c:IsFaceup() and c:IsNeutral() and c:IsControler(1-tp) and c:IsCanBeXyzMaterial(nil,tp) and c:IsLevel(level)
end

function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,0,LOCATION_MZONE,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    return true
end

function s.fselect(g)
	return g:GetClassCount(Card.GetLevel)==1
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
    local mg=Duel.GetMatchingGroup(s.xyzfilter,tp,0,LOCATION_MZONE,nil,tp)
    local sg=aux.SelectUnselectGroup(mg,e,tp,2,2,s.fselect,1,tp,HINTMSG_XMATERIAL)
    if #sg>0 then
        Duel.Overlay(c,sg)
    end
end

function s.atklimit(e,c)
    return c:IsNeutral()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and (bc:IsPositive() or bc:IsNegative())
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if bc and Duel.NegateAttack() then
        local atk=bc:GetAttack()
        local def=bc:GetDefense()
        local dam=math.max(atk,def)
        Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
end
