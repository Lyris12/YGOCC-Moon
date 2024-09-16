--created by Jake, coded by Lyris
--Essence Synthesizer
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,2,s.mchk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(s.aval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.dval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.mfilter(c)
	return c:IsPositive() or c:IsNegative()
end
function s.mchk(g)
	return g:IsExists(s.mfilter,1,nil)
end
function s.aval(e,c)
	local a=c:GetBaseAttack()
	if not c:IsDefenseAbove(0) then return math.ceil(a/2) end
	local d=c:GetBaseDefense()
	return a>d and -math.ceil(math.min(a,d)/2) or 0
end
function s.dval(e,c)
	local a,d=c:GetBaseAttack(),c:GetBaseDefense()
	return c:IsDefenseAbove(0) and d>a and -math.ceil(math.min(a,d)/2) or 0
end
function s.cfilter(c,tc)
	if not c:IsNeutral() then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return tc:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(tc:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())>0
	end
end
function s.condition(e,tp,eg)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandler())
end
function s.filter(c)
	return c:IsFaceup() and s.mfilter(c) and aux.NegateMonsterFilter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e)) or tc:IsFacedown() then return end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	Duel.AdjustInstantly()
	if not tc:IsDisabled() then return end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
	local _,a,_,d=g:GetMinGroup(Card.GetBaseAttack),g:GetMinGroup(Card.GetBaseDefense)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(a)
	tc:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e4:SetValue(d)
	tc:RegisterEffect(e4)
end
