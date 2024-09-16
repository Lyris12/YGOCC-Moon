--[[
Dynastygian Suppression Field
Campo di Soppressione Dinastigiano
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
if not GLITCHYCORE_LOADED then
	Duel.LoadScript("glitchylib_core.lua")
end
function s.initial_effect(c)
	--[[Activate 1 of the following effects, depending on who the owner of this card is.
	● You: All monsters your opponent currently controls lose 500 ATK/DEF for each face-up "Dynastygian" monster you control.
	If you did not control a DARK "Number" Xyz Monster at activation, these changes last until the end of the turn.
	● Your opponent: Negate the activated effects and effects on the field of all face-up Special Summoned monsters you control, whose original ATK/DEF is 2500 or higher,
	until the 2nd Standby Phase after this effect resolves.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this Set card in your opponent's Spell & Trap Zone is sent to the GY: You can choose 1 of their occupied Main Monster Zones or Spell & Trap Zones;
	your opponent must return the card in that zone to the hand, then that zone cannot be used until the end of the next turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.disfilter(c)
	return aux.NegateMonsterFilter(c) and c:IsSpecialSummoned() and math.max(c:GetBaseAttack(),c:GetBaseDefense())>=2500
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local p=c:GetOwner()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if chk==0 then
		if p==tp then
			local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
			local val=#g*-500
			return #g>0 and Duel.IsExists(false,Card.IsCanUpdateStats,tp,0,LOCATION_MZONE,1,nil,val,val,e,tp,REASON_EFFECT)
		elseif p==1-tp then
			return true
		else
			return false
		end
	end
	if p==tp then
		local param=Duel.IsExists(false,s.cfilter2,tp,LOCATION_MZONE,0,1,nil) and 1 or 3
		Duel.SetTargetParam(param)
		e:SetCategory(CATEGORIES_ATKDEF)
		local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
		local val=#g*-500
		local sg=Duel.Group(Card.IsCanUpdateStats,tp,0,LOCATION_MZONE,nil,val,val,e,tp,REASON_EFFECT)
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,sg,#sg,0,0,val)
	elseif p==1-tp then
		Duel.SetTargetParam(2)
		e:SetCategory(CATEGORY_DISABLE)
		local sg=Duel.Group(s.disfilter,tp,LOCATION_MZONE,0,nil)
		if #sg>0 then
			Duel.SetCardOperationInfo(sg,CATEGORY_DISABLE)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local param=Duel.GetTargetParam()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if param&1==1 then
		local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		local val=#g*-500
		local sg=Duel.Group(Card.IsCanUpdateStats,tp,0,LOCATION_MZONE,nil,val,val,e,tp,REASON_EFFECT)
		local reset=param==1 and 0 or RESET_PHASE|PHASE_END
		for tc in aux.Next(sg) do
			tc:UpdateATKDEF(val,val,reset,{c,true})
		end
	elseif param==2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.distg)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY,2)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_CREATED)
		e2:SetOperation(s.regop)
		e2:SetReset(RESET_PHASE|PHASE_STANDBY,2)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVING)
		e3:SetCondition(s.discon)
		e3:SetOperation(s.disop)
		e3:SetReset(RESET_PHASE|PHASE_STANDBY,2)
		Duel.RegisterEffect(e3,tp)
		Duel.RegisterHint(tp,id,RESET_PHASE|PHASE_STANDBY,2,id,1,nil,e1)
	end
end
function s.distg(e,c)
	return c:IsSpecialSummoned() and math.max(c:GetBaseAttack(),c:GetBaseDefense())>=2500 and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local p,loc,pos=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
	if re:IsActiveType(TYPE_MONSTER) and p==tp and loc==LOCATION_MZONE and pos&POS_FACEUP>0 and rc:IsSpecialSummoned() and math.max(rc:GetBaseAttack(),rc:GetBaseDefense())>=2500 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_CHAIN,0,0,ev)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffectLabel(tp,id+100,ev)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5 and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.thfilter(c,p,dzones)
	return c:GetSequence()<5 and Duel.IsPlayerCanSendtoHand(p,c) and (c:GetZone(p)<<16)&dzones==0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.thfilter,tp,0,LOCATION_ONFIELD,nil,1-tp,Duel.GetDisabledZones(1-tp)<<16)
	if chk==0 then
		return #g>0
	end
	local exczones=0
	for tc in aux.Next(g) do
		local zone=tc:GetZone(1-tp)<<16
		exczones=exczones|zone
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local zone=Duel.SelectField(tp,1,0,LOCATION_MZONE|LOCATION_SZONE,(~exczones)|(0x60<<16))
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.SetTargetParam(zone)
	local loc=zone>>24~=0 and LOCATION_SZONE or LOCATION_MZONE
	local g=loc==LOCATION_MZONE and Duel.GetCardsInZone(zone>>16,1-tp,loc) or Duel.GetCardsInZone(zone>>24,1-tp,loc)
	local tc=g:GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TOHAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=Duel.GetTargetParam()
	local loc=zone>>24~=0 and LOCATION_SZONE or LOCATION_MZONE
	local g=loc==LOCATION_MZONE and Duel.GetCardsInZone(zone>>16,1-tp,loc) or Duel.GetCardsInZone(zone>>24,1-tp,loc)
	local tc=g:GetFirst()
	if tc and Duel.IsPlayerCanSendtoHand(1-tp,tc) and Duel.SendtoHand(tc,nil,REASON_RULE,1-tp)>0 and tc:IsLocation(LOCATION_HAND) and zone&(Duel.GetDisabledZones(1-tp)<<16)==0 then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(zone)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end