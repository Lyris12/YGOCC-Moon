--created & coded by Lyris, art from Shadowverse's "Vyrmedea, Synthetic Voice"
--人造の波動拳
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Hadouken")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sptcost)
	e1:SetTarget(s.spttg)
	e1:SetOperation(s.sptop)
	c:RegisterEffect(e1)
end
function s.sptcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.filter(c,e,tp)
	local res=false
	if not (c:IsType(TYPE_SPATIAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPATIAL,tp,false,false)) then return res end
	local et=global_card_effect_table[c]
	for _,ef in ipairs(et) do if ef:GetCode()==EFFECT_SPSUMMON_PROC then
		local ev=ef:GetValue()
		local ec=ef:GetCondition()
		if ev and ev==SUMMON_TYPE_SPATIAL and (not ec or ec(ef,c)) then res=true end
	end end
	return res
end
function s.xfilter(c)
	return c:IsSetCard("Hadouken") and c:IsType(TYPE_MONSTER)
end
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=dcount+1
	local thcard=nil
	for tc in aux.Next(g) do if tc:GetSequence()<seq then
		seq=tc:GetSequence()
		thcard=tc
	end end
	if seq>dcount then
		for p=0,1 do Duel.ConfirmCards(p,Duel.GetFieldGroup(tp,LOCATION_DECK,0),true) end
		return
	end
	local tg=Group.CreateGroup()
	for i=0,seq do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		if seq<6 then for p=0,1 do Duel.ConfirmCards(p,tc,true) end end
		tg:AddCard(tc)
	end
	if seq>5 then for p=0,1 do Duel.ConfirmCards(p,tg,true) end end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	thcard:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"Hadouken"))
	Duel.RegisterEffect(e2,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc then
		Duel.BreakEffect()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_MUST_BE_SPACE_MATERIAL)
		e3:SetRange(LOCATION_DECK)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		thcard:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)	
		e4:SetCode(EVENT_SPSUMMON)
		e4:SetOperation(function(_,p,sg) e1:Reset() e2:Reset() e3:Reset() e4:Reset() end)
		Duel.RegisterEffect(e4,tp)
		local e5=e4:Clone()
		e5:SetCode(EVENT_CHAIN_SOLVED)
		Duel.RegisterEffect(e5,tp)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
		Duel.SpecialSummonRule(tp,sc)
	end
end
function s.mattg(e,c)
	return c:IsSetCard("Hadouken") and c:IsLocation(LOCATION_HAND) or c==e:GetLabelObject()
end
