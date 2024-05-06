--Pearlgate Converguard
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Converguard.EnableConvergence(c)
	--Summon Proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e1:HOPT()
	e1:SetCondition(ref.spcon)
	e1:SetOperation(ref.spop)
	c:RegisterEffect(e1)
	--Power Copy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(ref.atktg)
	e2:SetOperation(ref.atkop)
	c:RegisterEffect(e2)
	
end

--Summon Proc
function ref.spcfilter(c)
	return Converguard.Is(c) and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function ref.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.spcfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,c)
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.spcfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

--Negate
function ref.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
end
function ref.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g1=g:Select(tp,1,1,nil)
	local tc1=g1:GetFirst()
	local tc2=(g-g1):GetFirst()
	if tc2:IsImmuneToEffect(e) then return end
	local opt=0
	if tc1:IsDefenseAbove(0) then opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	if opt==0 then e1:SetValue(tc1:GetAttack()) else e1:SetValue(tc1:GetDefense()) end
	tc2:RegisterEffect(e1)
end
