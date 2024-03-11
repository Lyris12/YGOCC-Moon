--[[
Dread Bastille's Overture
Overtura della Bastiglia dell'Angoscia
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Counter settings
	c:EnableCounterPermit(COUNTER_SOULFLAME,LOCATION_HAND|LOCATION_ONFIELD)
	c:SetCounterLimit(COUNTER_SOULFLAME,12)
	--You can only control 1 "Dread Bastille's Overture".
	c:SetUniqueOnField(1,0,id)
	--[[When this card resolves, place 4 Soulflame Counters on it.]]
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_COUNTER)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e0x:SetCode(EVENT_ACTIVATED_DIRECTLY)
	e0x:SetOperation(s.activate1)
	c:RegisterEffect(e0x)
	--[[Each time a Level 8 or higher Rock monster(s) that can be Normal Summoned/Set is sent to your GY, place 1 Soulflame Counter on this card (max 12).]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	--[[Once per turn: You can remove Soulflame Counters from this card in multiples of 4; apply the following effects in sequence based on the amount removed.
	● 4+: Add 1 "Dread Bastille" monster from your Deck to your hand.
	● 8+: Special Summon 1 Level 8 or higher Rock monster from your hand or GY.
	● 12: Banish, face-down, 1 monster your opponent controls with less ATK than the highest DEF among Rock monsters you control.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetCost(aux.DummyCost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
--E0
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_SOULFLAME,4,false,LOCATION_SZONE) end
	local p,loc=c:GetControler(),c:GetLocation()
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,p,loc)
	Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER,c,1,p,loc,COUNTER_SOULFLAME,4)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_SOULFLAME,4) then
		c:AddCounter(COUNTER_SOULFLAME,4)
	end
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_SOULFLAME,4) then
		c:AddCounter(COUNTER_SOULFLAME,4)
	end
end

--E1
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsLevelAbove(8) and c:IsSummonableCard()
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(COUNTER_SOULFLAME,1,true)
	end
end

--E2
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsLevelAbove(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmfilter(c,tp,def)
	return c:IsFaceup() and c:IsAttackBelow(def) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.defilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:HasDefense()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local _,def=Duel.Group(s.defilter,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetDefense)
	local b1=c:IsCanRemoveCounter(tp,COUNTER_SOULFLAME,4,REASON_COST) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=c:IsCanRemoveCounter(tp,COUNTER_SOULFLAME,8,REASON_COST) and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	local b3=def and c:IsCanRemoveCounter(tp,COUNTER_SOULFLAME,12,REASON_COST) and Duel.IsExists(false,s.rmfilter,tp,0,LOCATION_MZONE,1,nil,tp,def-1)
	if chk==0 then
		return e:IsCostChecked() and (b1 or b2 or b3)
	end
	e:SetCategory(0)
	local nums={}
	if b1 then
		table.insert(nums,4)
	end
	if b2 then
		table.insert(nums,8)
	end
	if b3 then
		table.insert(nums,12)
	end
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	local a=c:GetCounter(COUNTER_SOULFLAME)
	if c:RemoveCounter(tp,COUNTER_SOULFLAME,ct,REASON_COST) then
		a=a-c:GetCounter(COUNTER_SOULFLAME)
	end
	Duel.SetTargetParam(a)
	if a>=4 then
		e:SetCategory(CATEGORIES_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if a>=8 then
		e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	end
	if a>=12 then
		e:SetCategory(e:GetCategory()|CATEGORY_REMOVE)
		local rg=Duel.Group(s.rmfilter,tp,0,LOCATION_MZONE,nil,tp,def-1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_MZONE)
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetTargetParam()
	if not a then return end
	local brk=false
	if a>=4 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup():Filter(aux.PLChk,nil,tp,LOCATION_HAND)
			if #og>0 then
				Duel.ConfirmCards(1-tp,og)
				Duel.ShuffleHand(tp)
			end
			Duel.ShuffleDeck(tp)
			brk=true
		end
	end
	if a>=8 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			if brk then
				Duel.BreakEffect()
			end
			if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
				brk=true
			end
		end
	end
	if a>=12 then
		local _,def=Duel.Group(s.defilter,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetDefense)
		if not def then return end
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,def)
		if #g>0 then
			Duel.HintSelection(g)
			if brk then
				Duel.BreakEffect()
			end
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end