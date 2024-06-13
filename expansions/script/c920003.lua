--[[
Curseflame Noble Loake
Nobile Fiammaledetta Loake
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If your opponent Summons a monster(s) face-up (Quick Effect): You can reveal this card in your hand, then either remove 2 Curseflame Counters from anywhere on the field, OR discard 1 other "Curseflame" card; Special Summon this card, and if you do, place 1 Curseflame Counter on each of those Summoned monsters.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIPSUMMON_SUCCESS},s.cfilter,id,LOCATION_HAND,nil,nil,nil,id+100)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--During the Standby Phase (Quick Effect): You can Tribute this card; negate the effects of all face-up cards your opponent currently controls until the end of this turn, and if you do, inflict 100 damage to your opponent for each Curseflame Counter on the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(TIMING_STANDBY_PHASE)
	e2:SetFunctions(aux.StandbyPhaseCond(),aux.TributeSelfCost,s.distg,s.disop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
function s.rmfilter(c,tp)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsDiscardable() and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetMZoneCount(tp)>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,2,REASON_COST)
	local b2=Duel.IsExists(false,s.rmfilter,tp,LOCATION_HAND,0,1,c,tp)
	if chk==0 then
		return not c:IsPublic() and (b1 or b2)
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
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and eg:IsExists(Card.IsCanAddCounter,1,nil,COUNTER_CURSEFLAME,1)
	end
	local g=aux.SelectSimultaneousEventGroup(eg,id+100,1)
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,#g,0,COUNTER_CURSEFLAME)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetTargetCards():Filter(Card.IsCanAddCounter,nil,COUNTER_CURSEFLAME,1)
		for tc in aux.Next(g) do
			tc:AddCounter(COUNTER_CURSEFLAME,1)
		end
	end
end

--E2
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	local ct=Duel.GetMatchingGroupCount(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME)
	Duel.SetConditionalOperationInfo(ct>0,0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g==0 then return end
	if Duel.Negate(g,e,RESET_PHASE|PHASE_END,false,false,TYPE_NEGATE_ALL)>0 then
		local ct=Duel.GetMatchingGroupCount(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME)
		Duel.Damage(Duel.GetTargetPlayer(),ct*100,REASON_EFFECT)
	end
end