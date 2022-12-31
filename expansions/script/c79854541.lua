--[[1 Tuner + 2 or more non-Tuner monsters
Cannot be destroyed by card effects. Once per turn, during either player's turn, if your opponent 
activates a monster effect: You can banish 1 Plant-Type monster from your Graveyard; negate that 
effect, and if you do, place 1 New Shinji Counter on all monsters your opponent controls. If this 
card attacks an opponent's monster with a New Shinji Counter on it, make that monster's ATK 0, 
until the end of the Damage Step.]]

--Keddy was here~
function c79854541.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	--negatability
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79854541,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c79854541.discon)
	e1:SetCost(c79854541.discost)
	e1:SetTarget(c79854541.distg)
	e1:SetOperation(c79854541.disop)
	c:RegisterEffect(e1)
	--cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(79854541,0))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(c79854541.poscon)
    e3:SetOperation(c79854541.posop)
    c:RegisterEffect(e3)
end
--negatability
function c79854541.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function c79854541.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
function c79854541.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c79854541.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c79854541.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c79854541.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c79854541.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for tc in aux.Next(g) do
			tc:AddCounter(0x1770,1)
			tc=g:GetNext()
		end
	end
end

--Reduce ATK
function c79854541.poscon(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler()==Duel.GetAttacker() then return end
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:GetCounter(0x1770)>0 and bc:IsControler(1-tp)
end
function c79854541.posop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if bc and bc:IsControler(1-tp) and bc:GetCounter(0x1770)>0 then
        if c:GetFlagEffect(79854541)~=0 then return end
        local ae=Effect.CreateEffect(c)
        ae:SetType(EFFECT_TYPE_SINGLE)
        ae:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ae:SetCode(EFFECT_SET_ATTACK_FINAL)
        ae:SetValue(0)
        ae:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
        bc:RegisterEffect(ae)
        c:RegisterFlagEffect(79854541,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE,0,1)
    end
end
