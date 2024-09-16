--[[
Number i212: Dynastygian Behemoth - "World Eater"
Numero i212: Behemoth Dinastigiano - "Divoratore di Mondi"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 10 monsters
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	--Must first be Xyz Summoned
	c:MustFirstBeSummoned(SUMMON_TYPE_XYZ)
	--[[If this card is Xyz Summoned: You can detach as many materials from this card as possible, then choose that same number of your opponent's occupied Main Monster Zones and Spell & Trap Zones;
	return all cards in those zones to the hand, also, if those zones are unoccupied, they cannot be used while this card remains face-up on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		aux.DummyCost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[Your opponent's monsters cannot target for attacks, and your opponent cannot target with card effects, any monster you control, except "Number i212: Dynastygian Behemoth - "World Eater"".]]
	c:CannotTargetForAttacksField(s.limit,LOCATION_MZONE,0,LOCATION_MZONE,nil,nil,EFFECT_FLAG_SET_AVAILABLE)
	c:CannotBeTargetedByEffectsField(aux.tgoval,LOCATION_MZONE,LOCATION_MZONE,0,s.limit,nil,EFFECT_FLAG_SET_AVAILABLE)
end
aux.xyz_number[id]=212

--E1
function s.thfilter(c,p,dzones)
	return c:GetSequence()<5 and Duel.IsPlayerCanSendtoHand(p,c) and (c:GetZone(p)<<16)&dzones==0
end
function s.zonechk(c,tp,zones)
	return c:GetZone(tp)&zones~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.thfilter,tp,0,LOCATION_ONFIELD,nil,1-tp,Duel.GetDisabledZones(1-tp)<<16)
	local n=0
	local ct=c:GetOverlayCount()
	for i=ct,1,-1 do
		if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
			n=i
			break
		end
	end
	if chk==0 then
		return e:IsCostChecked() and n~=0 and #g>=n
	end
	local detached=c:RemoveOverlayCard(tp,n,n,REASON_COST)
	local exczones=0
	for tc in aux.Next(g) do
		local zone=tc:GetZone(1-tp)<<16
		exczones=exczones|zone
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local zones=Duel.SelectField(tp,detached,0,LOCATION_MZONE|LOCATION_SZONE,(~exczones)|(0x60<<16))
	Duel.Hint(HINT_ZONE,tp,zones)
	Duel.SetTargetParam(zones)
	local sg=g:Filter(s.zonechk,nil,tp,zones)
	if #sg>0 then
		Duel.SetCardOperationInfo(sg,CATEGORY_TOHAND)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,p)
	local c=e:GetHandler()
	local zones=Duel.GetTargetParam()
	local g=Duel.Group(s.thfilter,tp,0,LOCATION_ONFIELD,nil,1-tp,Duel.GetDisabledZones(1-tp)<<16)
	local sg=g:Filter(s.zonechk,nil,tp,zones)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_RULE,1-tp)
	end
	local freezones=zones&~(Duel.GetDisabledZones(1-tp)<<16)
	local exczones=0
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE|LOCATION_SZONE)
	for tc in aux.Next(fg) do
		local zone=tc:GetZone(1-tp)<<16
		exczones=exczones|zone
	end
	freezones=freezones&~exczones
	if freezones~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(freezones)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

--E2
function s.limit(e,c)
	return c:IsFacedown() or not c:IsCode(id)
end