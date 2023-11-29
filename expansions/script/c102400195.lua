--created by Lyris, art from Shadowverse's "Yuwan's Fury"
--真空波動拳
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Hadouken")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,"Hadouken","Shouryuken") and #g>0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,0,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	local g=Group.CreateGroup()
	for i=0,ct-1 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		if ct<6 then for p=0,1 do Duel.ConfirmCards(p,tc,true) end end
		g:AddCard(tc)
	end
	if ct>5 then for p=0,1 do Duel.ConfirmCards(p,g,true) end end
	local d=g:FilterCount(Card.IsSetCard,nil,"Hadouken","Shouryuken")
	local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,d,d,nil)
	for tc in aux.Next(dg) do
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_SET_ATTACK_FINAL)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		e0:SetValue(1000)
		tc:RegisterEffect(e0)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	for i=1,ct do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
