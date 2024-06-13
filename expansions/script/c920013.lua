--[[
Curseflame Ancient Relia
Antica Fiammaledetta Relia
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),2)
	--If this card is Link Summoned: You can shuffle as many banished cards as possible into the Decks, and if you do, distribute a number of Curseflame Counters among face-up cards on the field, equal to the number of cards shuffled into the Deck by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1)
	--Cards on the field with a Curseflame Counter cannot apply or activate their effects, except during their owner's turn. This effect does not apply to "Curseflame" cards you control.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_APPLY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.applim)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_CANNOT_TRIGGER)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
end

--E1
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	if chk==0 then
		local cg=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		return #g>0 and cg:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME),1,#cg,#g)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,#g,tp,COUNTER_CURSEFLAME)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetBanishment():Filter(Card.IsAbleToDeck,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
		if ct>0 then
			local cg=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			if #cg>0 then
				Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,ct,cg,id)
			end
		end
	end
end

--E2
function s.applim(e,rc)
	local tp=e:GetHandlerPlayer()
	return rc:HasCounter(COUNTER_CURSEFLAME) and not (rc:IsSetCard(ARCHE_CURSEFLAME) and rc:IsControler(tp)) and Duel.GetTurnPlayer()~=rc:GetOwner()
end