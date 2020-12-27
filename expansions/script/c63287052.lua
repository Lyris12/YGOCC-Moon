--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x6) and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	if Duel.CheckEvent(EVENT_CHAINING) then tg=eg:GetFirst() end
	if chk==0 then return true end
	Duel.SetTargetCard(tg)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst():GetBattleTarget()
	return bc and bc:IsControler(tp) and bc:IsSetCard(0x6)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,1,nil)
	if not (Duel.CheckEvent(EVENT_CHAINING) and Duel.NegateActivation(ev) or Duel.NegateAttack())
		or not (#g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler())) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.BreakEffect()
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT) end
end
