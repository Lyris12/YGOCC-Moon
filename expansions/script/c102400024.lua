--created & coded by Lyris, art from Shadowverse's "Vyrmedea, Synthetic Voice"
--人造の波動拳
local s,id,o=GetID()
Card.IsHadoken=Card.IsHadoken or function(c) return c:GetCode()>102400019 and c:GetCode()<102400034 end
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCondition(s.sptcon)
	e1:SetCost(s.sptcost)
	e1:SetTarget(s.spttg)
	e1:SetOperation(s.sptop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local tp=c:GetControler()
	local ef=Effect.CreateEffect(c)
	ef:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ef:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ef:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	ef:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ef:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKBOTTOM,REASON_RULE)
		c5000.ops(ef,tp)
	end)
	Duel.RegisterEffect(ef,tp)
end
function s.sptcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)%2==0
end
function s.sptcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.HintSelection(Group.FromCards(c))
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.filter(c,e,tp)
	local res=false
	if not (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_SPATIAL)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPATIAL,tp,false,false)) then return res end
	local et=global_card_effect_table[c]
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c) or ev==SUMMON_TYPE_SPATIAL) and (not ec or ec(e,c)) then res=true end
		end
	end
	return res
end
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e1:SetTargetRange(0xfc,0)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
		e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsHadoken))
		Duel.RegisterEffect(e2,tp)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
		e1:Reset() e2:Reset()
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e1:SetTargetRange(0xfc,0)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
	e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsHadoken))
	Duel.RegisterEffect(e2,tp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	e1:Reset() e2:Reset()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if sc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e1:SetTargetRange(0xfc,0)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
		e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsHadoken))
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON)
		e3:SetOperation(function(ef,p,tg) if tg:GetFirst()~=sc then return end e1:Reset() e2:Reset() ef:Reset() end)
		Duel.RegisterEffect(e3,tp)
		Duel.SpecialSummonRule(tp,sc)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsHadoken,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsHadoken,tp,LOCATION_DECK,0,nil)
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
	if thcard:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(thcard,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,thcard)
		tg:RemoveCard(thcard)
		Duel.ShuffleHand(tp)
	end
	for i=1,#tg do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
