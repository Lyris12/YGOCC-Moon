--Golden Carat Kartdriver
--Kartdriver Carato Dorato
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[(Quick Effect): You can discard this card, then activate 1 of these effects;
	● Increase or decrease the Energy of an Engaged monster by up to 4.
	● Increase or decrease the Level of an Engaged monster by up to 4 (even after it is Summoned/Set).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can make the Level of all Engaged monsters become equal to their current respective Energies (even after they are Summoned/Set).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetEngagedCards()
	if chk==0 then
		if g:IsExists(Card.HasLevel,1,nil) then return true end
		for i=-4,4 do
			if g:IsExists(Card.IsCanUpdateEnergy,1,nil,i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
	local b1=false
	for i=-4,4 do
		if i~=0 and g:IsExists(Card.IsCanUpdateEnergy,1,nil,i,tp,REASON_EFFECT) then
			b1=true
			break
		end
	end
	local b2=g:IsExists(Card.HasLevel,1,nil)
	local opt=aux.Option(tp,id,1,b1,b2)
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetEngagedCards()
	if #g<=0 then return end
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt==0 then
		local n={}
		for i=-4,4 do
			if i~=0 and g:IsExists(Card.IsCanUpdateEnergy,1,nil,i,tp,REASON_EFFECT) then
				table.insert(n,i)
			end
		end
		Duel.HintMessage(tp,STRING_INPUT_ENERGY)
		local ct=Duel.AnnounceNumber(tp,table.unpack(n))
		Duel.HintMessage(tp,HINTMSG_ENERGY)
		local sg=g:FilterSelect(tp,Card.IsCanUpdateEnergy,1,1,nil,ct,tp,REASON_EFFECT)
		if #sg>0 then
			Duel.HintSelection(sg)
			sg:GetFirst():UpdateEnergy(ct,tp,REASON_EFFECT,true,c)
		end
		
	elseif opt==1 then
		local n={-4,-3,-2,-1,1,2,3,4}
		Duel.HintMessage(tp,STRING_INPUT_LEVEL)
		local ct=Duel.AnnounceNumber(tp,table.unpack(n))
		Duel.HintMessage(tp,HINGMSG_LVRANK)
		local sg=g:FilterSelect(tp,Card.HasLevel,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			local en=sg:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(ct)
			e1:SetCondition(aux.ResetIfNotEngaged(en:GetEngagedID()))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_UNION)
			en:RegisterEffect(e1)
		end
	end
end

function s.lvfilter(c)
	return c:HasLevel() and c:IsCanChangeEnergy(c:GetLevel(),tp,REASON_EFFECT)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetEngagedCards():IsExists(s.lvfilter,1,nil)
	end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetEngagedCards():Filter(s.lvfilter,nil)
	for en in aux.Next(g) do
		local ct=en:GetEnergy()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(ct)
		e1:SetCondition(aux.ResetIfNotEngaged(en:GetEngagedID()))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_UNION)
		en:RegisterEffect(e1)
	end
end