--[[
Curseflame Reaper Baroge
Mietitore Fiammaledetta Baroge
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase, if this card is in your hand while your opponent controls a face-up card with a Curseflame Counter (Quick Effect): You can remove 2 Curseflame counters from anywhere on the field, OR discard 1 other "Curseflame" card; Special Summon this card, but return it to the hand during the End Phase. Immediately after this effect resolves, your opponent must shuffle into the Deck as many cards they control with a Curseflame Counter as possible.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.condition,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--Each time a face-up card(s) that has a Curseflame counter(s) leaves the field, inflict 300 damage to your opponent for each of those cards.
	aux.RegisterCountersBeforeLeavingField(c,COUNTER_CURSEFLAME,LOCATION_MZONE,nil,id)
	aux.RegisterMaxxCEffect(c,id+100,nil,LOCATION_MZONE,EVENT_LEAVE_FIELD,s.damcon,s.damopOUT,s.damopIN,s.flaglabel)
end
--E1
function s.ctfilter(c)
	return c:IsFaceup() and c:HasCounter(COUNTER_CURSEFLAME)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExists(false,s.ctfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.rmfilter(c,tp)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsDiscardable() and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetMZoneCount(tp)>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,2,REASON_COST)
	local b2=Duel.IsExists(false,s.rmfilter,tp,LOCATION_HAND,0,1,c,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,2,b1,b2)
	if opt==0 then
		Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,2,REASON_COST)
	elseif opt==1 then
		Duel.DiscardHand(tp,s.rmfilter,1,1,REASON_COST,c)
	end
end
function s.tdfilter(c,p)
	return c:HasCounter(COUNTER_CURSEFLAME) and c:IsAbleToDeck() and Duel.IsPlayerCanSendtoDeck(p)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.tdfilter,tp,0,LOCATION_ONFIELD,nil,1-tp)
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and #g>0
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	aux.ApplyEffectImmediatelyAfterResolution(s.tdop,c,e,tp,eg,ep,ev,re,r,rp)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	if not c:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoHand(e:GetOwner(),nil,REASON_EFFECT)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tdfilter,tp,0,LOCATION_ONFIELD,nil,1-tp)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,1-tp)
	end
end

--E2
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.HasFlagEffect,1,nil,id)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.HasFlagEffect,nil,id)
end
function s.damopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:FilterCount(Card.HasFlagEffect,nil,id)
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
function s.damopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id+100)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end