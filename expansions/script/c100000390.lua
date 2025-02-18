--[[
Voidictator Servant - Vassal of Corvus
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[If this card is Normal or Special Summoned: You can banish 1 "Voidictator Servant" monster from your hand or GY, except "Voidictator Servant - Vassal of Corvus"; negate the effects of 1
	face-up card your opponent controls until the end of this turn]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.BanishCost(s.cfilter,LOCATION_HAND|LOCATION_GRAVE),
		s.distg,
		s.disop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is banished because of a "Voidictator" card you own, except "Voidictator Servant - Vassal of Corvus": You can banish 1 "Voidictator" card from your GY; Special Summon this card,
	but shuffle it into the Deck when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.BanishCost(aux.Filter(Card.IsSetCard,ARCHE_VOIDICTATOR),LOCATION_GRAVE))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and not c:IsCode(id)
end
function s.disfilter(c,e)
	return aux.NegateAnyFilter(c) and (not e or c:IsCanBeDisabledByEffect(e))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.Group(s.disfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DISABLE,false,tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e)
	if Duel.Highlight(g) then
		Duel.Negate(g:GetFirst(),e,RESET_PHASE|PHASE_END)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if not (rc and rc:IsOwner(tp)) then return false end
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid,code1,code2=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		if rc:IsRelateToChain(ch) then
			return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
		else
			return s.TriggeringSetcode[cid] and code1~=id and (not code2 or code2~=id)
		end
	else
		return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP,nil,LOCATION_DECKSHF)
	end
end